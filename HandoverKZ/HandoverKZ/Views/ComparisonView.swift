import SwiftUI
import FieldDocsCore

struct ComparisonView: View {
    let handoverCase: HandoverCase
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        List {
            if !handoverCase.canAccessComparison {
                Section {
                    Text("Сравнение недоступно. Завершите обе фазы.")
                        .foregroundColor(MSColor.textSecondary)
                }
            } else {
                Section("Итог") {
                    if handoverCase.hasDeteriorations {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(MSColor.error)
                            Text("Обнаружены ухудшения")
                                .font(MSFont.headline)
                                .foregroundColor(MSColor.error)
                        }
                        .padding(.vertical, MSSpacing.xs)
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(MSColor.success)
                            Text("Ухудшений не обнаружено")
                                .font(MSFont.headline)
                                .foregroundColor(MSColor.success)
                        }
                        .padding(.vertical, MSSpacing.xs)
                        
                        Text("Залог подлежит возврату в полном объёме")
                            .font(MSFont.subheadline)
                            .foregroundColor(MSColor.textSecondary)
                    }
                }
                
                ForEach(handoverCase.rooms) { room in
                    Section(room.name) {
                        ForEach(room.elements) { element in
                            if let moveIn = element.moveIn,
                               let moveOut = element.moveOut {
                                NavigationLink {
                                    ElementComparisonDetailView(
                                        element: element,
                                        photos: handoverCase.photos,
                                        repository: store.repository
                                    )
                                } label: {
                                    ComparisonRow(
                                        element: element,
                                        moveIn: moveIn,
                                        moveOut: moveOut
                                    )
                                }
                            }
                        }
                    }
                }
                
                if handoverCase.hasDeteriorations {
                    Section("К удержанию из залога") {
                        ForEach(handoverCase.deterioratedElements, id: \.room.id) { item in
                            VStack(alignment: .leading, spacing: MSSpacing.sm) {
                                Text(item.room.name)
                                    .font(MSFont.headline)
                                    .foregroundColor(MSColor.textPrimary)
                                
                                ForEach(item.elements) { element in
                                    if let moveIn = element.moveIn,
                                       let moveOut = element.moveOut {
                                        HStack {
                                            Image(systemName: "exclamationmark.circle.fill")
                                                .foregroundColor(MSColor.error)
                                            
                                            VStack(alignment: .leading, spacing: MSSpacing.xs) {
                                                Text(element.name)
                                                    .font(MSFont.body)
                                                
                                                HStack(spacing: MSSpacing.xs) {
                                                    ConditionBadge(state: moveIn.state)
                                                    Image(systemName: "arrow.right")
                                                        .font(.caption)
                                                        .foregroundColor(MSColor.textTertiary)
                                                    ConditionBadge(state: moveOut.state)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, MSSpacing.xs)
                        }
                        
                        HStack {
                            Text("Сумма залога:")
                                .font(MSFont.headline)
                            Spacer()
                            Text(MSCurrency.format(handoverCase.depositAmount))
                                .font(MSFont.title3)
                                .foregroundColor(MSColor.primary)
                        }
                        .padding(.vertical, MSSpacing.sm)
                    }
                }
            }
        }
        .navigationTitle("Сравнение")
    }
}

struct ComparisonRow: View {
    let element: HandoverElement
    let moveIn: ElementCondition
    let moveOut: ElementCondition
    
    var body: some View {
        VStack(alignment: .leading, spacing: MSSpacing.sm) {
            Text(element.name)
                .font(MSFont.body)
                .foregroundColor(MSColor.textPrimary)
            
            HStack(spacing: MSSpacing.md) {
                VStack(alignment: .leading, spacing: MSSpacing.xs) {
                    Text("Заселение")
                        .font(MSFont.caption)
                        .foregroundColor(MSColor.textTertiary)
                    ConditionBadge(state: moveIn.state)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(MSColor.textTertiary)
                
                VStack(alignment: .leading, spacing: MSSpacing.xs) {
                    Text("Выселение")
                        .font(MSFont.caption)
                        .foregroundColor(MSColor.textTertiary)
                    ConditionBadge(state: moveOut.state)
                }
                
                Spacer()
                
                if element.isDeteriorated {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(MSColor.error)
                }
            }
        }
        .padding(.vertical, MSSpacing.xs)
    }
}

struct ElementComparisonDetailView: View {
    let element: HandoverElement
    let photos: [UUID: Photo]
    let repository: HandoverRepository
    
    var body: some View {
        Form {
            Section("Изменение состояния") {
                if let moveIn = element.moveIn,
                   let moveOut = element.moveOut {
                    HStack {
                        VStack(alignment: .leading, spacing: MSSpacing.sm) {
                            Text("Заселение")
                                .font(MSFont.caption)
                                .foregroundColor(MSColor.textSecondary)
                            ConditionBadge(state: moveIn.state)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.title2)
                            .foregroundColor(MSColor.textTertiary)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: MSSpacing.sm) {
                            Text("Выселение")
                                .font(MSFont.caption)
                                .foregroundColor(MSColor.textSecondary)
                            ConditionBadge(state: moveOut.state)
                        }
                    }
                    .padding(.vertical, MSSpacing.sm)
                    
                    if element.isDeteriorated {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(MSColor.error)
                            Text("Состояние ухудшилось")
                                .font(MSFont.headline)
                                .foregroundColor(MSColor.error)
                        }
                        .padding(.vertical, MSSpacing.xs)
                    }
                }
            }
            
            if let moveIn = element.moveIn, !moveIn.note.isEmpty {
                Section("Заметка при заселении") {
                    Text(moveIn.note)
                        .font(MSFont.body)
                        .foregroundColor(MSColor.textPrimary)
                }
            }
            
            if let moveOut = element.moveOut, !moveOut.note.isEmpty {
                Section("Заметка при выселении") {
                    Text(moveOut.note)
                        .font(MSFont.body)
                        .foregroundColor(MSColor.textPrimary)
                }
            }
            
            Section("Фотографии") {
                if let moveIn = element.moveIn, !moveIn.photoIds.isEmpty {
                    VStack(alignment: .leading, spacing: MSSpacing.sm) {
                        Text("Заселение")
                            .font(MSFont.subheadline)
                            .foregroundColor(MSColor.textSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: MSSpacing.sm) {
                                ForEach(moveIn.photoIds, id: \.self) { photoId in
                                    if let photo = photos[photoId],
                                       let image = repository.loadPhoto(photo) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .cornerRadius(MSRadius.sm)
                                            .clipped()
                                    }
                                }
                            }
                        }
                    }
                }
                
                if let moveOut = element.moveOut, !moveOut.photoIds.isEmpty {
                    VStack(alignment: .leading, spacing: MSSpacing.sm) {
                        Text("Выселение")
                            .font(MSFont.subheadline)
                            .foregroundColor(MSColor.textSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: MSSpacing.sm) {
                                ForEach(moveOut.photoIds, id: \.self) { photoId in
                                    if let photo = photos[photoId],
                                       let image = repository.loadPhoto(photo) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .cornerRadius(MSRadius.sm)
                                            .clipped()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(element.name)
    }
}
