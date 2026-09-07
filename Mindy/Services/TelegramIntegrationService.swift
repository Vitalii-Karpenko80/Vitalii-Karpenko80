//
//  TelegramIntegrationService.swift
//  Mindy
//
//  Интеграция с Telegram Bot для отправки задач
//

import Foundation

@MainActor
class TelegramIntegrationService: ObservableObject {
    @Published var isConfigured = false
    @Published var errorMessage: String?
    @Published var lastSentDate: Date?
    
    private let userDefaults = UserDefaults.standard
    private let botTokenKey = "telegram_bot_token"
    private let chatIDKey = "telegram_chat_id"
    private let enabledKey = "telegram_enabled"
    
    var botToken: String {
        get {
            userDefaults.string(forKey: botTokenKey) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: botTokenKey)
            updateConfiguredState()
        }
    }
    
    var chatID: String {
        get {
            userDefaults.string(forKey: chatIDKey) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: chatIDKey)
            updateConfiguredState()
        }
    }
    
    var enabled: Bool {
        get {
            userDefaults.bool(forKey: enabledKey)
        }
        set {
            userDefaults.set(newValue, forKey: enabledKey)
        }
    }
    
    init() {
        updateConfiguredState()
    }
    
    private func updateConfiguredState() {
        isConfigured = !botToken.isEmpty && !chatID.isEmpty
    }
    
    // MARK: - Send Message
    
    func sendThought(_ thought: Thought) async -> Bool {
        guard isConfigured && enabled else {
            errorMessage = "Telegram не настроен"
            return false
        }
        
        let message = formatThought(thought)
        return await sendMessage(message)
    }
    
    func sendDailySummary(thoughts: [Thought]) async -> Bool {
        guard isConfigured && enabled else {
            errorMessage = "Telegram не настроен"
            return false
        }
        
        let message = formatDailySummary(thoughts)
        return await sendMessage(message)
    }
    
    func sendCustomMessage(_ text: String) async -> Bool {
        guard isConfigured && enabled else {
            errorMessage = "Telegram не настроен"
            return false
        }
        
        return await sendMessage(text)
    }
    
    private func sendMessage(_ text: String) async -> Bool {
        let urlString = "https://api.telegram.org/bot\(botToken)/sendMessage"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Неверный URL Telegram API"
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "chat_id": chatID,
            "text": text,
            "parse_mode": "Markdown"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Неверный ответ от сервера"
                return false
            }
            
            if httpResponse.statusCode == 200 {
                lastSentDate = Date()
                print("✅ Сообщение отправлено в Telegram")
                return true
            } else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let description = json["description"] as? String {
                    errorMessage = "Ошибка Telegram: \(description)"
                } else {
                    errorMessage = "Ошибка отправки: код \(httpResponse.statusCode)"
                }
                return false
            }
            
        } catch {
            errorMessage = "Ошибка сети: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Formatting
    
    private func formatThought(_ thought: Thought) -> String {
        var lines: [String] = []
        
        // Title with emoji
        if let task = thought.task {
            let emoji = getEmojiForType(thought.taskType)
            lines.append("*\(emoji) \(task)*")
        } else {
            lines.append("*📝 Новая мысль*")
        }
        
        lines.append("")
        
        // Details
        if let subject = thought.subject {
            lines.append("📎 Тема: `\(subject)`")
        }
        
        if let when = thought.when {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ru_RU")
            lines.append("📅 Когда: `\(formatter.string(from: when))`")
        }
        
        if let priority = thought.priority {
            let priorityText = priority == "high" ? "🔴 Высокий" : priority == "medium" ? "🟡 Средний" : "🟢 Низкий"
            lines.append("⚡️ Приоритет: \(priorityText)")
        }
        
        if let context = thought.context {
            lines.append("")
            lines.append("💬 Контекст:")
            lines.append(context)
        }
        
        lines.append("")
        lines.append("_Создано: \(formatDate(thought.createdAt))_")
        
        return lines.joined(separator: "\n")
    }
    
    private func formatDailySummary(_ thoughts: [Thought]) -> String {
        var lines: [String] = []
        
        lines.append("*📊 Сводка задач на сегодня*")
        lines.append("")
        
        let today = Calendar.current.startOfDay(for: Date())
        let todayThoughts = thoughts.filter { thought in
            guard let when = thought.when else { return false }
            return Calendar.current.isDate(when, inSameDayAs: today)
        }
        
        if todayThoughts.isEmpty {
            lines.append("✨ На сегодня задач нет!")
        } else {
            lines.append("Всего задач: *\(todayThoughts.count)*")
            lines.append("")
            
            // Group by priority
            let highPriority = todayThoughts.filter { $0.priority == "high" }
            let mediumPriority = todayThoughts.filter { $0.priority == "medium" }
            let lowPriority = todayThoughts.filter { $0.priority == "low" }
            
            if !highPriority.isEmpty {
                lines.append("🔴 *Высокий приоритет:*")
                for thought in highPriority {
                    lines.append("  • \(thought.task ?? thought.originalText)")
                }
                lines.append("")
            }
            
            if !mediumPriority.isEmpty {
                lines.append("🟡 *Средний приоритет:*")
                for thought in mediumPriority {
                    lines.append("  • \(thought.task ?? thought.originalText)")
                }
                lines.append("")
            }
            
            if !lowPriority.isEmpty {
                lines.append("🟢 *Низкий приоритет:*")
                for thought in lowPriority {
                    lines.append("  • \(thought.task ?? thought.originalText)")
                }
                lines.append("")
            }
        }
        
        lines.append("_Отправлено из Mindy_")
        
        return lines.joined(separator: "\n")
    }
    
    // MARK: - Test Connection
    
    func testConnection() async -> Bool {
        guard isConfigured else {
            errorMessage = "Заполните Bot Token и Chat ID"
            return false
        }
        
        let testMessage = "✅ Тестовое сообщение от Mindy\n\nИнтеграция настроена успешно!"
        return await sendMessage(testMessage)
    }
    
    // MARK: - Helpers
    
    private func getEmojiForType(_ type: String?) -> String {
        switch type {
        case "call": return "📞"
        case "meeting": return "👥"
        case "purchase": return "🛒"
        case "reminder": return "🔔"
        case "note": return "📝"
        default: return "✅"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    // MARK: - Get Chat ID Instructions
    
    func getChatIDInstructions() -> String {
        return """
        Как получить Chat ID:
        
        1. Найдите @userinfobot в Telegram
        2. Нажмите Start
        3. Бот отправит ваш Chat ID
        4. Скопируйте число и вставьте выше
        
        Для групп:
        1. Добавьте бота в группу
        2. Отправьте любое сообщение
        3. Откройте: https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates
        4. Найдите chat.id в ответе
        """
    }
}
