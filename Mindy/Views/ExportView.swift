//
//  ExportView.swift
//  Mindy
//
//  UI для экспорта задач в текстовый файл
//

import SwiftUI

struct ExportView: View {
    @EnvironmentObject var thoughtManager: ThoughtManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPeriod: ExportService.ExportPeriod = .today
    @State private var selectedFormat: ExportService.ExportFormat = .detailed
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    @State private var previewText = ""
    
    private let exportService = ExportService()
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Period Selection
                        periodSection
                        
                        // Format Selection
                        formatSection
                        
                        // Preview
                        previewSection
                        
                        // Export Button
                        exportButton
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Экспорт задач")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
            .onAppear {
                updatePreview()
            }
        }
    }
    
    private var periodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentPrimary, .accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("Период")
                    .font(.title3)
                    .foregroundColor(.textPrimary)
            }
            
            VStack(spacing: 12) {
                PeriodButton(period: .today, selected: $selectedPeriod) {
                    updatePreview()
                }
                PeriodButton(period: .tomorrow, selected: $selectedPeriod) {
                    updatePreview()
                }
                PeriodButton(period: .thisWeek, selected: $selectedPeriod) {
                    updatePreview()
                }
                PeriodButton(period: .all, selected: $selectedPeriod) {
                    updatePreview()
                }
            }
        }
        .padding(20)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 24)
    }
    
    private var formatSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentPrimary, .accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("Формат")
                    .font(.title3)
                    .foregroundColor(.textPrimary)
            }
            
            VStack(spacing: 12) {
                FormatButton(
                    format: .detailed,
                    title: "Подробный",
                    description: "С контекстом и статистикой",
                    selected: $selectedFormat
                ) {
                    updatePreview()
                }
                
                FormatButton(
                    format: .markdown,
                    title: "Markdown",
                    description: "С чекбоксами для GitHub/Notion",
                    selected: $selectedFormat
                ) {
                    updatePreview()
                }
                
                FormatButton(
                    format: .plain,
                    title: "Простой",
                    description: "Только задачи и даты",
                    selected: $selectedFormat
                ) {
                    updatePreview()
                }
            }
        }
        .padding(20)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 24)
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "eye")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentPrimary, .accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("Превью")
                    .font(.title3)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(previewText.count) символов")
                    .font(.caption())
                    .foregroundColor(.textTertiary)
            }
            
            ScrollView {
                Text(previewText.isEmpty ? "Нет задач для экспорта" : previewText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                    )
            }
            .frame(height: 200)
        }
        .padding(20)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 24)
    }
    
    private var exportButton: some View {
        Button(action: {
            exportTasks()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                Text("Экспортировать")
                    .font(.body())
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [.accentPrimary, .accentSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .softDepthShadow(color: .accentPrimary, radius: 20)
        }
        .springyButton()
        .disabled(previewText.isEmpty)
    }
    
    private func updatePreview() {
        previewText = exportService.exportTasks(
            thoughtManager.thoughts,
            period: selectedPeriod,
            format: selectedFormat
        )
    }
    
    private func exportTasks() {
        let content = exportService.exportTasks(
            thoughtManager.thoughts,
            period: selectedPeriod,
            format: selectedFormat
        )
        
        if let fileURL = exportService.createTextFile(content: content, period: selectedPeriod) {
            exportedFileURL = fileURL
            showingShareSheet = true
            
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Period Button

struct PeriodButton: View {
    let period: ExportService.ExportPeriod
    @Binding var selected: ExportService.ExportPeriod
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            selected = period
            action()
        }) {
            HStack {
                Text(period.title)
                    .font(.body())
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if selected == period {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentPrimary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected == period ? Color.accentPrimary.opacity(0.2) : Color.glassTint)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selected == period ? Color.accentPrimary : Color.glassBorder, lineWidth: 1)
                    )
            )
        }
        .springyButton()
    }
}

// MARK: - Format Button

struct FormatButton: View {
    let format: ExportService.ExportFormat
    let title: String
    let description: String
    @Binding var selected: ExportService.ExportFormat
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            selected = format
            action()
        }) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body())
                        .foregroundColor(.textPrimary)
                    
                    Text(description)
                        .font(.caption())
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if selected == format {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentPrimary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected == format ? Color.accentPrimary.opacity(0.2) : Color.glassTint)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selected == format ? Color.accentPrimary : Color.glassBorder, lineWidth: 1)
                    )
            )
        }
        .springyButton()
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView()
        .environmentObject(ThoughtManager())
}
