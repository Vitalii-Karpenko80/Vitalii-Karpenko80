import SwiftUI
import FieldDocsCore

struct InspectionView: View {
    @Binding var handoverCase: HandoverCase
    let phase: HandoverCase.Phase
    
    @State private var showingAddRoom = false
    @State private var newRoomName = ""
    
    var body: some View {
        List {
            ForEach(handoverCase.rooms.indices, id: \.self) { index in
                Section {
                    NavigationLink {
                        RoomDetailView(
                            room: $handoverCase.rooms[index],
                            phase: phase,
                            photos: $handoverCase.photos,
                            repository: store.repository
                        )
                    } label: {
                        HStack {
                            Text(handoverCase.rooms[index].name)
                                .font(MSFont.headline)
                            
                            Spacer()
                            
                            Text("\(handoverCase.rooms[index].elements.count) элементов")
                                .font(MSFont.caption)
                                .foregroundColor(MSColor.textSecondary)
                        }
                    }
                }
            }
            .onDelete(perform: deleteRooms)
            
            Button {
                showingAddRoom = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Добавить комнату")
                }
                .foregroundColor(MSColor.primary)
            }
        }
        .navigationTitle(phase == .moveIn ? "Заселение" : "Выселение")
        .alert("Добавить комнату", isPresented: $showingAddRoom) {
            TextField("Название комнаты", text: $newRoomName)
            Button("Отмена", role: .cancel) {
                newRoomName = ""
            }
            Button("Добавить") {
                addRoom()
            }
        }
    }
    
    @EnvironmentObject private var store: AppStore
    
    private func addRoom() {
        guard !newRoomName.isEmpty else { return }
        
        let newRoom = HandoverRoom(name: newRoomName)
        handoverCase.rooms.append(newRoom)
        handoverCase.project.modifiedAt = Date()
        newRoomName = ""
    }
    
    private func deleteRooms(at offsets: IndexSet) {
        handoverCase.rooms.remove(atOffsets: offsets)
        handoverCase.project.modifiedAt = Date()
    }
}

struct RoomDetailView: View {
    @Binding var room: HandoverRoom
    let phase: HandoverCase.Phase
    @Binding var photos: [UUID: Photo]
    let repository: HandoverRepository
    
    @State private var showingAddElement = false
    @State private var newElementName = ""
    
    var body: some View {
        List {
            ForEach(room.elements.indices, id: \.self) { index in
                NavigationLink {
                    ElementDetailView(
                        element: $room.elements[index],
                        phase: phase,
                        photos: $photos,
                        repository: repository
                    )
                } label: {
                    ElementRow(
                        element: room.elements[index],
                        phase: phase
                    )
                }
            }
            .onDelete(perform: deleteElements)
            
            Button {
                showingAddElement = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Добавить элемент")
                }
                .foregroundColor(MSColor.primary)
            }
        }
        .navigationTitle(room.name)
        .alert("Добавить элемент", isPresented: $showingAddElement) {
            TextField("Название элемента", text: $newElementName)
            Button("Отмена", role: .cancel) {
                newElementName = ""
            }
            Button("Добавить") {
                addElement()
            }
        }
    }
    
    private func addElement() {
        guard !newElementName.isEmpty else { return }
        
        let newElement = HandoverElement(name: newElementName)
        room.elements.append(newElement)
        newElementName = ""
    }
    
    private func deleteElements(at offsets: IndexSet) {
        room.elements.remove(atOffsets: offsets)
    }
}

struct ElementRow: View {
    let element: HandoverElement
    let phase: HandoverCase.Phase
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: MSSpacing.xs) {
                Text(element.name)
                    .font(MSFont.body)
                    .foregroundColor(MSColor.textPrimary)
                
                if let condition = (phase == .moveIn ? element.moveIn : element.moveOut) {
                    ConditionBadge(state: condition.state)
                } else {
                    Text("Не осмотрено")
                        .font(MSFont.caption)
                        .foregroundColor(MSColor.textTertiary)
                }
            }
            
            Spacer()
            
            if phase == .moveOut, let moveIn = element.moveIn {
                ConditionBadge(state: moveIn.state)
                    .opacity(0.5)
            }
        }
    }
}
