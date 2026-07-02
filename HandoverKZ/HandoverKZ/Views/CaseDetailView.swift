import SwiftUI
import FieldDocsCore

struct CaseDetailView: View {
    @EnvironmentObject var store: AppStore
    @State var handoverCase: HandoverCase
    @State private var selectedPhase: Phase = .moveIn
    
    enum Phase: String, CaseIterable {
        case moveIn = "Заселение"
        case moveOut = "Выселение"
    }
    
    var body: some View {
        List {
            Section("Информация") {
                VStack(alignment: .leading, spacing: MSSpacing.sm) {
                    HStack {
                        Text("Залог:")
                            .font(MSFont.subheadline)
                            .foregroundColor(MSColor.textSecondary)
                        
                        Spacer()
                        
                        Text(MSCurrency.format(handoverCase.depositAmount))
                            .font(MSFont.headline)
                            .foregroundColor(MSColor.textPrimary)
                    }
                    
                    HStack {
                        Text("Арендодатель:")
                            .font(MSFont.subheadline)
                            .foregroundColor(MSColor.textSecondary)
                        
                        Spacer()
                        
                        Text(handoverCase.landlord.fullName)
                            .font(MSFont.body)
                            .foregroundColor(MSColor.textPrimary)
                    }
                    
                    HStack {
                        Text("Арендатор:")
                            .font(MSFont.subheadline)
                            .foregroundColor(MSColor.textSecondary)
                        
                        Spacer()
                        
                        Text(handoverCase.tenant.fullName)
                            .font(MSFont.body)
                            .foregroundColor(MSColor.textPrimary)
                    }
                }
            }
            
            Section("Фазы") {
                Picker("Фаза", selection: $selectedPhase) {
                    ForEach(Phase.allCases, id: \.self) { phase in
                        Text(phase.rawValue).tag(phase)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                if selectedPhase == .moveOut && !handoverCase.canAccessMoveOut {
                    Text("Выселение недоступно до завершения заселения")
                        .font(MSFont.caption)
                        .foregroundColor(MSColor.error)
                        .padding(MSSpacing.md)
                }
            }
            
            if selectedPhase == .moveIn || handoverCase.canAccessMoveOut {
                NavigationLink {
                    InspectionView(
                        handoverCase: $handoverCase,
                        phase: selectedPhase == .moveIn ? .moveIn : .moveOut
                    )
                    .onChange(of: handoverCase) { _, newValue in
                        store.saveCase(newValue)
                    }
                } label: {
                    HStack {
                        Text("Осмотр помещения")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }
            
            if selectedPhase == .moveIn {
                NavigationLink {
                    SignaturesView(
                        handoverCase: $handoverCase,
                        phase: .moveIn
                    )
                    .onChange(of: handoverCase) { _, newValue in
                        store.saveCase(newValue)
                    }
                } label: {
                    HStack {
                        Text("Подписи")
                        Spacer()
                        if !handoverCase.moveInSignatures.isEmpty {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(MSColor.success)
                        }
                    }
                }
                
                if handoverCase.moveInMeta.isCompleted {
                    Button {
                        exportPDF(phase: .moveIn)
                    } label: {
                        HStack {
                            Text("Экспорт PDF")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                } else {
                    Button {
                        completePhase(.moveIn)
                    } label: {
                        Text("Завершить заселение")
                            .foregroundColor(MSColor.primary)
                    }
                }
            } else {
                NavigationLink {
                    SignaturesView(
                        handoverCase: $handoverCase,
                        phase: .moveOut
                    )
                    .onChange(of: handoverCase) { _, newValue in
                        store.saveCase(newValue)
                    }
                } label: {
                    HStack {
                        Text("Подписи")
                        Spacer()
                        if !handoverCase.moveOutSignatures.isEmpty {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(MSColor.success)
                        }
                    }
                }
                
                if handoverCase.moveOutMeta.isCompleted {
                    Button {
                        exportPDF(phase: .moveOut)
                    } label: {
                        HStack {
                            Text("Экспорт PDF")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                } else if handoverCase.canAccessMoveOut {
                    Button {
                        completePhase(.moveOut)
                    } label: {
                        Text("Завершить выселение")
                            .foregroundColor(MSColor.primary)
                    }
                }
            }
            
            if handoverCase.canAccessComparison {
                Section("Сравнение") {
                    NavigationLink {
                        ComparisonView(handoverCase: handoverCase)
                    } label: {
                        HStack {
                            Text("Сравнение до/после")
                            Spacer()
                            if handoverCase.hasDeteriorations {
                                MSBadge(text: "⚠️ Ухудшения", color: MSColor.error)
                            }
                        }
                    }
                    
                    Button {
                        exportComparison()
                    } label: {
                        HStack {
                            Text("Экспорт сравнения (PDF)")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .navigationTitle(handoverCase.project.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func completePhase(_ phase: HandoverCase.Phase) {
        if phase == .moveIn {
            handoverCase.moveInMeta.isCompleted = true
            handoverCase.moveInMeta.completedAt = Date()
        } else {
            handoverCase.moveOutMeta.isCompleted = true
            handoverCase.moveOutMeta.completedAt = Date()
        }
        
        handoverCase.project.modifiedAt = Date()
        store.saveCase(handoverCase)
    }
    
    private func exportPDF(phase: HandoverCase.Phase) {
        let pdfDocument = handoverCase.makeAct(phase: phase == .moveIn ? "moveIn" : "moveOut")
        let renderer = PDFRenderer()
        let pdfData = renderer.render(pdfDocument)
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(handoverCase.project.name)_\(phase == .moveIn ? "Заселение" : "Выселение").pdf")
        
        do {
            try pdfData.write(to: tempURL)
            sharePDF(url: tempURL)
        } catch {
            print("Failed to save PDF: \(error)")
        }
    }
    
    private func exportComparison() {
        let pdfDocument = handoverCase.makeComparison()
        let renderer = PDFRenderer()
        let pdfData = renderer.render(pdfDocument)
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(handoverCase.project.name)_Сравнение.pdf")
        
        do {
            try pdfData.write(to: tempURL)
            sharePDF(url: tempURL)
        } catch {
            print("Failed to save PDF: \(error)")
        }
    }
    
    private func sharePDF(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
