import SwiftUI
import FieldDocsCore
import PhotosUI

struct ElementDetailView: View {
    @Binding var element: HandoverElement
    let phase: HandoverCase.Phase
    @Binding var photos: [UUID: Photo]
    let repository: HandoverRepository
    
    @State private var selectedState: ConditionState = .good
    @State private var note: String = ""
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    var condition: Binding<ElementCondition?> {
        Binding(
            get: {
                phase == .moveIn ? element.moveIn : element.moveOut
            },
            set: { newValue in
                if phase == .moveIn {
                    element.moveIn = newValue
                } else {
                    element.moveOut = newValue
                }
            }
        )
    }
    
    var body: some View {
        Form {
            Section("Состояние") {
                if phase == .moveOut, let moveIn = element.moveIn {
                    HStack {
                        Text("При заселении:")
                            .font(MSFont.subheadline)
                            .foregroundColor(MSColor.textSecondary)
                        Spacer()
                        ConditionBadge(state: moveIn.state)
                    }
                    .padding(.vertical, MSSpacing.xs)
                }
                
                Picker("Состояние", selection: $selectedState) {
                    ForEach(ConditionState.allCases, id: \.self) { state in
                        Text(state.localizedName).tag(state)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Заметка") {
                TextEditor(text: $note)
                    .frame(minHeight: 100)
                    .font(MSFont.body)
            }
            
            Section("Фотографии") {
                if let currentCondition = condition.wrappedValue {
                    ForEach(currentCondition.photoIds, id: \.self) { photoId in
                        if let photo = photos[photoId],
                           let image = repository.loadPhoto(photo) {
                            HStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(MSRadius.sm)
                                    .clipped()
                                
                                VStack(alignment: .leading) {
                                    Text("Фото")
                                        .font(MSFont.subheadline)
                                    if let caption = photo.caption {
                                        Text(caption)
                                            .font(MSFont.caption)
                                            .foregroundColor(MSColor.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(role: .destructive) {
                                    deletePhoto(photoId)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
                
                Button {
                    showingCamera = true
                } label: {
                    Label("Сделать фото", systemImage: "camera.fill")
                }
                
                Button {
                    showingPhotoPicker = true
                } label: {
                    Label("Выбрать из галереи", systemImage: "photo.on.rectangle")
                }
            }
        }
        .navigationTitle(element.name)
        .onAppear {
            if let currentCondition = condition.wrappedValue {
                selectedState = currentCondition.state
                note = currentCondition.note
            } else {
                condition.wrappedValue = ElementCondition()
            }
        }
        .onChange(of: selectedState) { _, newValue in
            updateCondition()
        }
        .onChange(of: note) { _, newValue in
            updateCondition()
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                savePhoto(image)
            }
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotos, maxSelectionCount: 5)
        .onChange(of: selectedPhotos) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            savePhoto(image)
                        }
                    }
                }
                selectedPhotos = []
            }
        }
    }
    
    private func updateCondition() {
        var current = condition.wrappedValue ?? ElementCondition()
        current.state = selectedState
        current.note = note
        condition.wrappedValue = current
    }
    
    private func savePhoto(_ image: UIImage) {
        do {
            let photo = try repository.savePhoto(image, for: element.id)
            photos[photo.id] = photo
            
            var current = condition.wrappedValue ?? ElementCondition()
            current.photoIds.append(photo.id)
            condition.wrappedValue = current
        } catch {
            print("Failed to save photo: \(error)")
        }
    }
    
    private func deletePhoto(_ photoId: UUID) {
        if let photo = photos[photoId] {
            try? repository.deletePhoto(photo)
            photos.removeValue(forKey: photoId)
        }
        
        var current = condition.wrappedValue ?? ElementCondition()
        current.photoIds.removeAll { $0 == photoId }
        condition.wrappedValue = current
    }
}
