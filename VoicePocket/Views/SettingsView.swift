//
//  SettingsView.swift
//  VoicePocket
//
//  Экран настроек приложения
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var thoughtManager: ThoughtManager
    @State private var apiKey: String = ""
    @State private var useGPT4: Bool = false
    @State private var showingSaved = false
    @State private var isExpanded = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // GPT-4 Integration Section
                        gpt4Section
                        
                        // Info Section
                        infoSection
                        
                        // About Section
                        aboutSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
    
    private var gpt4Section: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentPrimary, .accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("GPT-4 Интеграция")
                    .font(.title2())
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            Text("Используйте GPT-4 для более точного распознавания задач, дат и контекста")
                .font(.caption())
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
            
            // Toggle для включения GPT-4
            HStack {
                Text("Использовать GPT-4")
                    .font(.body())
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Toggle("", isOn: $useGPT4)
                    .tint(.accentPrimary)
                    .onChange(of: useGPT4) { _, newValue in
                        thoughtManager.useGPT4 = newValue
                    }
            }
            .padding(16)
            .liquidGlassCard(tintColor: .glassTint, cornerRadius: 16)
            
            // API Key Input
            if useGPT4 {
                VStack(alignment: .leading, spacing: 12) {
                    Text("OpenAI API Key")
                        .font(.caption())
                        .foregroundColor(.textSecondary)
                    
                    SecureField("sk-...", text: $apiKey)
                        .textFieldStyle(.plain)
                        .font(.body())
                        .foregroundColor(.textPrimary)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.glassTint)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.glassBorder, lineWidth: 1)
                                )
                        )
                    
                    Button(action: {
                        saveAPIKey()
                    }) {
                        HStack {
                            Image(systemName: showingSaved ? "checkmark.circle.fill" : "key.fill")
                            Text(showingSaved ? "Сохранено" : "Сохранить ключ")
                        }
                        .font(.body())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(
                            LinearGradient(
                                colors: showingSaved ? [.green, .green.opacity(0.8)] : [.accentPrimary, .accentSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .springyButton()
                    .disabled(apiKey.isEmpty)
                    
                    // Help Text
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                            Text("Как получить API ключ?")
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        }
                        .font(.caption())
                        .foregroundColor(.textSecondary)
                    }
                    
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. Перейдите на platform.openai.com")
                            Text("2. Войдите в аккаунт или зарегистрируйтесь")
                            Text("3. Откройте API Keys в настройках")
                            Text("4. Создайте новый ключ")
                            Text("5. Скопируйте и вставьте сюда")
                        }
                        .font(.caption())
                        .foregroundColor(.textTertiary)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.glassTint)
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(16)
                .liquidGlassCard(tintColor: .glassTint, cornerRadius: 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 24)
        .onAppear {
            let service = thoughtManager.getGPT4Service()
            apiKey = service.apiKey ?? ""
            useGPT4 = thoughtManager.useGPT4
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.orange)
                Text("Информация")
                    .font(.title3)
                    .foregroundColor(.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(
                    icon: "sparkles",
                    title: "Локальный парсер",
                    description: "Быстро, бесплатно, работает офлайн"
                )
                
                InfoRow(
                    icon: "brain",
                    title: "GPT-4 парсер",
                    description: "Точнее, умнее, понимает контекст"
                )
                
                InfoRow(
                    icon: "lock.shield.fill",
                    title: "Приватность",
                    description: "API ключ хранится локально на устройстве"
                )
            }
        }
        .padding(20)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 24)
    }
    
    private var aboutSection: some View {
        VStack(spacing: 12) {
            Text("Voice Pocket v1.0")
                .font(.body())
                .foregroundColor(.textSecondary)
            
            Text("iOS 2026 Design Language Edition")
                .font(.caption())
                .foregroundColor(.textTertiary)
            
            Link("GitHub Repository", destination: URL(string: "https://github.com/Vitalii-Karpenko80")!)
                .font(.caption())
                .foregroundColor(.accentPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 24)
    }
    
    private func saveAPIKey() {
        let service = thoughtManager.getGPT4Service()
        service.apiKey = apiKey.isEmpty ? nil : apiKey
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showingSaved = true
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showingSaved = false
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentPrimary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body())
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.caption())
                    .foregroundColor(.textSecondary)
                    .lineSpacing(2)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThoughtManager())
}
