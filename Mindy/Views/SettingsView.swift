//
//  SettingsView.swift
//  Mindy
//
//  Расширенный экран настроек приложения с интеграциями
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var thoughtManager: ThoughtManager
    @StateObject private var cloudSync = CloudSyncService()
    @StateObject private var telegramService = TelegramIntegrationService()
    @StateObject private var calendarService = CalendarIntegrationService()
    
    @State private var apiKey: String = ""
    @State private var useGPT4: Bool = false
    @State private var showingSaved = false
    @State private var isGPT4Expanded = false
    
    @State private var telegramBotToken = ""
    @State private var telegramChatID = ""
    @State private var showingTelegramTest = false
    @State private var telegramTestResult = ""
    
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                
                VStack(spacing: 0) {
                    // Custom Tab Picker
                    tabPicker
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            switch selectedTab {
                            case 0: gpt4Section
                            case 1: syncSection
                            case 2: integrationsSection
                            case 3: aboutSection
                            default: EmptyView()
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.accentPrimary, .accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .springyButton()
                }
            }
        }
        .onAppear {
            loadSettings()
        }
    }
    
    // MARK: - Tab Picker
    
    private var tabPicker: some View {
        HStack(spacing: 8) {
            TabButton(title: "AI", icon: "brain.head.profile", isSelected: selectedTab == 0) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }
            
            TabButton(title: "Синхр.", icon: "icloud.fill", isSelected: selectedTab == 1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }
            
            TabButton(title: "Интегр.", icon: "link", isSelected: selectedTab == 2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 2
                }
            }
            
            TabButton(title: "О прил.", icon: "info.circle", isSelected: selectedTab == 3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 3
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - GPT-4 Section
    
    private var gpt4Section: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "brain.head.profile", title: "GPT-4 Интеграция")
            
            Text("Используйте GPT-4 для более точного распознавания задач, дат, приоритетов и контекста")
                .font(.caption())
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
            
            // Toggle для включения GPT-4
            ToggleCard(
                title: "Использовать GPT-4",
                isOn: $useGPT4,
                onChange: { thoughtManager.useGPT4 = $0 }
            )
            
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
                    
                    Button(action: saveAPIKey) {
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
                    
                    ExpandableInfo(
                        title: "Как получить API ключ?",
                        isExpanded: $isGPT4Expanded,
                        content: """
                        1. Перейдите на platform.openai.com
                        2. Войдите в аккаунт или зарегистрируйтесь
                        3. Откройте API Keys в настройках
                        4. Создайте новый ключ
                        5. Скопируйте и вставьте сюда
                        
                        Стоимость: ~$0.01-0.05 за заметку
                        """
                    )
                }
                .padding(16)
                .liquidGlassCard(tintColor: .glassTint, cornerRadius: 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Info Cards
            VStack(spacing: 12) {
                InfoCard(
                    icon: "sparkles",
                    title: "Локальный парсер",
                    description: "Быстро, бесплатно, работает офлайн",
                    color: .green
                )
                
                InfoCard(
                    icon: "brain",
                    title: "GPT-4 парсер",
                    description: "Точнее, умнее, понимает контекст",
                    color: .purple
                )
            }
        }
        .padding(20)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 24)
    }
    
    // MARK: - Sync Section
    
    private var syncSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(icon: "icloud.fill", title: "Синхронизация iCloud")
            
            // iCloud Status
            HStack(spacing: 12) {
                Image(systemName: cloudSync.iCloudAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(cloudSync.iCloudAvailable ? .green : .red)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(cloudSync.iCloudAvailable ? "iCloud доступен" : "iCloud недоступен")
                        .font(.body())
                        .foregroundColor(.textPrimary)
                    
                    if let error = cloudSync.syncError {
                        Text(error)
                            .font(.caption())
                            .foregroundColor(.red)
                    } else {
                        Text("Синхронизация между устройствами")
                            .font(.caption())
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .liquidGlassCard(tintColor: .glassTint, cornerRadius: 16)
            
            // Sync Toggle
            ToggleCard(
                title: "Включить синхронизацию",
                subtitle: "Автоматическая синхронизация задач через iCloud",
                isOn: Binding(
                    get: { cloudSync.syncEnabled },
                    set: { cloudSync.syncEnabled = $0 }
                )
            )
            .disabled(!cloudSync.iCloudAvailable)
            
            // Last Sync
            if let lastSync = cloudSync.lastSyncDate {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.textSecondary)
                    
                    Text("Последняя синхронизация:")
                        .font(.caption())
                        .foregroundColor(.textSecondary)
                    
                    Text(formatDate(lastSync))
                        .font(.caption())
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                }
                .padding(12)
                .liquidGlassCard(tintColor: .glassTint, cornerRadius: 12)
            }
            
            // Sync Now Button
            if cloudSync.syncEnabled {
                Button(action: {
                    Task {
                        await cloudSync.syncNow()
                    }
                }) {
                    HStack {
                        if cloudSync.isSyncing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        Text(cloudSync.isSyncing ? "Синхронизация..." : "Синхронизировать сейчас")
                    }
                    .font(.body())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [.accentPrimary, .accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                }
                .springyButton()
                .disabled(cloudSync.isSyncing)
            }
        }
        .padding(20)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 24)
    }
    
    // MARK: - Integrations Section
    
    private var integrationsSection: some View {
        VStack(spacing: 20) {
            SectionHeader(icon: "link", title: "Интеграции")
            
            // Telegram Integration
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                    Text("Telegram Bot")
                        .font(.title3)
                        .foregroundColor(.textPrimary)
                    Spacer()
                }
                
                ToggleCard(
                    title: "Включить Telegram",
                    subtitle: "Отправка задач в Telegram",
                    isOn: Binding(
                        get: { telegramService.enabled },
                        set: { telegramService.enabled = $0 }
                    )
                )
                
                if telegramService.enabled {
                    VStack(spacing: 12) {
                        TextField("Bot Token", text: $telegramBotToken)
                            .textFieldStyle(.plain)
                            .font(.caption())
                            .foregroundColor(.textPrimary)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.glassTint)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.glassBorder, lineWidth: 1)
                                    )
                            )
                        
                        TextField("Chat ID", text: $telegramChatID)
                            .textFieldStyle(.plain)
                            .font(.caption())
                            .foregroundColor(.textPrimary)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.glassTint)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.glassBorder, lineWidth: 1)
                                    )
                            )
                        
                        HStack(spacing: 12) {
                            Button(action: saveTelegramSettings) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Сохранить")
                                }
                                .font(.caption())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.accentPrimary)
                                .cornerRadius(10)
                            }
                            
                            Button(action: testTelegram) {
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                    Text("Тест")
                                }
                                .font(.caption())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.green)
                                .cornerRadius(10)
                            }
                        }
                        
                        if !telegramTestResult.isEmpty {
                            Text(telegramTestResult)
                                .font(.caption())
                                .foregroundColor(telegramTestResult.contains("✅") ? .green : .red)
                                .padding(8)
                        }
                        
                        ExpandableInfo(
                            title: "Как настроить Telegram?",
                            isExpanded: .constant(false),
                            content: telegramService.getChatIDInstructions()
                        )
                    }
                    .transition(.opacity)
                }
            }
            .padding(20)
            .liquidGlassCard(tintColor: .glassTint, cornerRadius: 20)
            
            // Calendar Integration
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                    Text("Календарь")
                        .font(.title3)
                        .foregroundColor(.textPrimary)
                    Spacer()
                }
                
                ToggleCard(
                    title: "Интеграция с календарем",
                    subtitle: "Автоматическое создание событий",
                    isOn: Binding(
                        get: { calendarService.calendarEnabled },
                        set: { _ in }
                    )
                )
                .disabled(true)
                
                ToggleCard(
                    title: "Напоминания",
                    subtitle: "Автоматическое создание напоминаний",
                    isOn: Binding(
                        get: { calendarService.remindersEnabled },
                        set: { _ in }
                    )
                )
                .disabled(true)
                
                Text("Настраивается автоматически при первом запуске")
                    .font(.caption())
                    .foregroundColor(.textSecondary)
                    .padding(.top, 4)
            }
            .padding(20)
            .liquidGlassCard(tintColor: .glassTint, cornerRadius: 20)
            
            // Email Export
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.red)
                    Text("Email экспорт")
                        .font(.title3)
                        .foregroundColor(.textPrimary)
                    Spacer()
                }
                
                Text("Доступен через кнопку экспорта на главном экране")
                    .font(.caption())
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Настроено автоматически")
                        .font(.caption())
                        .foregroundColor(.textPrimary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            .padding(20)
            .liquidGlassCard(tintColor: .glassTint, cornerRadius: 20)
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(spacing: 20) {
            // App Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.accentPrimary, .accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .padding(.top, 20)
            
            VStack(spacing: 8) {
                Text("Mindy")
                    .font(.title())
                    .foregroundColor(.textPrimary)
                
                Text("Version 1.0")
                    .font(.body())
                    .foregroundColor(.textSecondary)
                
                Text("iOS 2026 Design Edition")
                    .font(.caption())
                    .foregroundColor(.textTertiary)
            }
            
            Divider()
                .background(Color.glassBorder)
                .padding(.vertical, 8)
            
            VStack(spacing: 16) {
                FeatureRow(icon: "mic.fill", title: "Голосовой ввод", color: .blue)
                FeatureRow(icon: "brain.head.profile", title: "AI парсинг (GPT-4)", color: .purple)
                FeatureRow(icon: "icloud.fill", title: "iCloud синхронизация", color: .cyan)
                FeatureRow(icon: "chart.bar.fill", title: "Аналитика задач", color: .green)
                FeatureRow(icon: "link", title: "Интеграции (Telegram, Email)", color: .orange)
            }
            .padding(20)
            .liquidGlassCard(tintColor: .glassTint, cornerRadius: 20)
            
            Link("GitHub Repository", destination: URL(string: "https://github.com/Vitalii-Karpenko80")!)
                .font(.caption())
                .foregroundColor(.accentPrimary)
                .padding(12)
                .liquidGlassCard(tintColor: .glassTint, cornerRadius: 12)
            
            Text("© 2026 Mindy. Все права защищены.")
                .font(.caption())
                .foregroundColor(.textTertiary)
                .padding(.bottom, 20)
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadSettings() {
        let service = thoughtManager.getGPT4Service()
        apiKey = service.apiKey ?? ""
        useGPT4 = thoughtManager.useGPT4
        
        telegramBotToken = telegramService.botToken
        telegramChatID = telegramService.chatID
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
    
    private func saveTelegramSettings() {
        telegramService.botToken = telegramBotToken
        telegramService.chatID = telegramChatID
        telegramTestResult = "💾 Сохранено"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            telegramTestResult = ""
        }
    }
    
    private func testTelegram() {
        Task {
            let success = await telegramService.testConnection()
            telegramTestResult = success ? "✅ Подключение успешно!" : "❌ Ошибка: \(telegramService.errorMessage ?? "Неизвестная ошибка")"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.body(16))
                Text(title)
                    .font(.caption(11))
            }
            .foregroundColor(isSelected ? .white : .textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [.accentPrimary, .accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.glassTint
                    }
                }
            )
            .cornerRadius(12)
        }
        .springyButton()
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.accentPrimary, .accentSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(title)
                .font(.title2())
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
    }
}

struct ToggleCard: View {
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    var onChange: ((Bool) -> Void)? = nil
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body())
                    .foregroundColor(.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption())
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.accentPrimary)
                .onChange(of: isOn) { _, newValue in
                    onChange?(newValue)
                }
        }
        .padding(16)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 16)
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
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
            
            Spacer()
        }
        .padding(16)
        .liquidGlassCard(tintColor: color.opacity(0.1), cornerRadius: 12)
    }
}

struct ExpandableInfo: View {
    let title: String
    @Binding var isExpanded: Bool
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                    Text(title)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .font(.caption())
                .foregroundColor(.textSecondary)
            }
            
            if isExpanded {
                Text(content)
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
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.body())
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThoughtManager())
}
