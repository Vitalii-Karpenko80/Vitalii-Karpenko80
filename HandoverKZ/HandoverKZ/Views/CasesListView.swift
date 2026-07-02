import SwiftUI
import FieldDocsCore

struct CasesListView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        Group {
            if store.cases.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(store.cases) { handoverCase in
                        NavigationLink {
                            CaseDetailView(handoverCase: handoverCase)
                        } label: {
                            CaseRow(handoverCase: handoverCase)
                        }
                    }
                    .onDelete(perform: deleteCases)
                }
            }
        }
    }
    
    private func deleteCases(at offsets: IndexSet) {
        for index in offsets {
            let handoverCase = store.cases[index]
            store.deleteCase(handoverCase)
        }
    }
}

struct CaseRow: View {
    let handoverCase: HandoverCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: MSSpacing.sm) {
            Text(handoverCase.project.name)
                .font(MSFont.headline)
                .foregroundColor(MSColor.textPrimary)
            
            Text(handoverCase.project.address)
                .font(MSFont.subheadline)
                .foregroundColor(MSColor.textSecondary)
            
            HStack(spacing: MSSpacing.sm) {
                if handoverCase.moveInMeta.isCompleted {
                    MSBadge(text: "✓ Заселение", color: MSColor.success)
                }
                
                if handoverCase.moveOutMeta.isCompleted {
                    MSBadge(text: "✓ Выселение", color: MSColor.success)
                } else if handoverCase.moveInMeta.isCompleted {
                    MSBadge(text: "Выселение ожидается", color: MSColor.warning)
                }
                
                if handoverCase.canAccessComparison {
                    MSBadge(text: "Сравнение готово", color: MSColor.primary)
                }
            }
            
            Text(formattedDate(handoverCase.project.modifiedAt))
                .font(MSFont.caption)
                .foregroundColor(MSColor.textTertiary)
        }
        .padding(.vertical, MSSpacing.xs)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: MSSpacing.lg) {
            Image(systemName: "doc.text")
                .font(.system(size: 64))
                .foregroundColor(MSColor.textTertiary)
            
            Text("Нет актов")
                .font(MSFont.title2)
                .foregroundColor(MSColor.textPrimary)
            
            Text("Создайте первый акт приёма-передачи")
                .font(MSFont.body)
                .foregroundColor(MSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(MSSpacing.xl)
    }
}
