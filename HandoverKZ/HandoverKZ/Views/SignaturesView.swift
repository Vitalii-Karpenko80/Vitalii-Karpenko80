import SwiftUI
import FieldDocsCore

struct SignaturesView: View {
    @EnvironmentObject var store: AppStore
    @Binding var handoverCase: HandoverCase
    let phase: HandoverCase.Phase
    
    var signatures: Binding<[UUID: Signature]> {
        Binding(
            get: {
                phase == .moveIn ? handoverCase.moveInSignatures : handoverCase.moveOutSignatures
            },
            set: { newValue in
                if phase == .moveIn {
                    handoverCase.moveInSignatures = newValue
                } else {
                    handoverCase.moveOutSignatures = newValue
                }
            }
        )
    }
    
    var body: some View {
        Form {
            Section("Подпись арендодателя") {
                SignatureBox(
                    partyName: handoverCase.landlord.fullName,
                    signature: signatures.wrappedValue[handoverCase.landlord.id],
                    onSave: { image in
                        saveSignature(image, for: handoverCase.landlord.id)
                    },
                    onClear: {
                        clearSignature(for: handoverCase.landlord.id)
                    },
                    repository: store.repository
                )
            }
            
            Section("Подпись арендатора") {
                SignatureBox(
                    partyName: handoverCase.tenant.fullName,
                    signature: signatures.wrappedValue[handoverCase.tenant.id],
                    onSave: { image in
                        saveSignature(image, for: handoverCase.tenant.id)
                    },
                    onClear: {
                        clearSignature(for: handoverCase.tenant.id)
                    },
                    repository: store.repository
                )
            }
        }
        .navigationTitle("Подписи")
    }
    
    private func saveSignature(_ image: UIImage, for partyId: UUID) {
        do {
            let signature = try store.repository.saveSignature(image, for: partyId)
            signatures.wrappedValue[partyId] = signature
            handoverCase.project.modifiedAt = Date()
        } catch {
            print("Failed to save signature: \(error)")
        }
    }
    
    private func clearSignature(for partyId: UUID) {
        if let signature = signatures.wrappedValue[partyId] {
            try? store.repository.deleteSignature(signature)
            signatures.wrappedValue.removeValue(forKey: partyId)
            handoverCase.project.modifiedAt = Date()
        }
    }
}

struct SignatureBox: View {
    let partyName: String
    let signature: Signature?
    let onSave: (UIImage) -> Void
    let onClear: () -> Void
    let repository: HandoverRepository
    
    @State private var showingSignaturePad = false
    
    var body: some View {
        VStack(spacing: MSSpacing.md) {
            if let signature = signature,
               let image = repository.loadSignature(signature) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .background(MSColor.tertiaryBackground)
                    .cornerRadius(MSRadius.sm)
                
                Button(role: .destructive) {
                    onClear()
                } label: {
                    Text("Очистить подпись")
                        .frame(maxWidth: .infinity)
                }
            } else {
                VStack(spacing: MSSpacing.sm) {
                    Image(systemName: "pencil.tip.crop.circle")
                        .font(.system(size: 48))
                        .foregroundColor(MSColor.textTertiary)
                    
                    Text("Подпись не добавлена")
                        .font(MSFont.subheadline)
                        .foregroundColor(MSColor.textSecondary)
                    
                    Button {
                        showingSignaturePad = true
                    } label: {
                        Text("Добавить подпись")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(MSColor.primary)
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(MSColor.tertiaryBackground)
                .cornerRadius(MSRadius.sm)
            }
        }
        .sheet(isPresented: $showingSignaturePad) {
            SignaturePadView(partyName: partyName) { image in
                onSave(image)
            }
        }
    }
}

struct SignaturePadView: View {
    let partyName: String
    let onSave: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var currentPath = Path()
    @State private var paths: [Path] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Распишитесь пальцем")
                    .font(MSFont.headline)
                    .padding(MSSpacing.md)
                
                Canvas { context, size in
                    for path in paths {
                        context.stroke(path, with: .color(.black), lineWidth: 3)
                    }
                    context.stroke(currentPath, with: .color(.black), lineWidth: 3)
                }
                .background(Color.white)
                .cornerRadius(MSRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: MSRadius.md)
                        .stroke(MSColor.separator, lineWidth: 1)
                )
                .padding(MSSpacing.md)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let point = value.location
                            if currentPath.isEmpty {
                                currentPath.move(to: point)
                            } else {
                                currentPath.addLine(to: point)
                            }
                        }
                        .onEnded { _ in
                            paths.append(currentPath)
                            currentPath = Path()
                        }
                )
                
                HStack(spacing: MSSpacing.md) {
                    Button {
                        paths.removeAll()
                        currentPath = Path()
                    } label: {
                        Text("Очистить")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        saveSignature()
                    } label: {
                        Text("Сохранить")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(MSColor.primary)
                    .disabled(paths.isEmpty)
                }
                .padding(MSSpacing.md)
            }
            .navigationTitle("Подпись: \(partyName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveSignature() {
        let renderer = ImageRenderer(content: signatureCanvas)
        renderer.scale = UIScreen.main.scale
        
        if let image = renderer.uiImage {
            onSave(image)
            dismiss()
        }
    }
    
    private var signatureCanvas: some View {
        Canvas { context, size in
            for path in paths {
                context.stroke(path, with: .color(.black), lineWidth: 3)
            }
        }
        .frame(width: 400, height: 200)
        .background(Color.white)
    }
}
