//
//  GPT4ParsingService.swift
//  VoicePocket
//
//  Сервис для парсинга задач через GPT-4
//

import Foundation
import OpenAI

@MainActor
class GPT4ParsingService: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    private var openAI: OpenAI?
    private let userDefaults = UserDefaults.standard
    private let apiKeyKey = "openai_api_key"
    
    var isConfigured: Bool {
        return apiKey != nil
    }
    
    var apiKey: String? {
        get {
            userDefaults.string(forKey: apiKeyKey)
        }
        set {
            userDefaults.set(newValue, forKey: apiKeyKey)
            if let key = newValue {
                openAI = OpenAI(apiToken: key)
            } else {
                openAI = nil
            }
        }
    }
    
    init() {
        if let key = apiKey {
            openAI = OpenAI(apiToken: key)
        }
    }
    
    func parseThought(_ text: String) async throws -> ParsedThought {
        guard let openAI = openAI else {
            throw GPT4Error.notConfigured
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        let prompt = """
        Ты — ассистент для анализа голосовых заметок на русском языке.
        
        Извлеки из текста структурированную информацию и верни ТОЛЬКО валидный JSON без дополнительного текста.
        
        Текст: "\(text)"
        
        Верни JSON в формате:
        {
            "task": "краткое описание действия (глагол + объект)",
            "subject": "тема или объект задачи",
            "when": "дата и время в ISO 8601 формате или null",
            "context": "дополнительная информация, контекст, детали",
            "priority": "high, medium, low или null",
            "type": "call, meeting, purchase, reminder, note или task"
        }
        
        Правила:
        - task: начинается с глагола (позвонить, купить, написать, встретиться)
        - subject: конкретная тема (имя человека, товар, проект)
        - when: если упомянуто время - преобразуй в ISO 8601 относительно текущей даты
        - context: все дополнительные детали, причины, условия
        - priority: определи по словам "срочно", "важно", "можно подождать"
        - type: категоризируй задачу по типу действия
        
        Примеры дат:
        - "завтра" = следующий день
        - "послезавтра" = через 2 дня
        - "через неделю" = через 7 дней
        - "в 15:00" = сегодня в 15:00
        - "завтра в 9 утра" = завтра в 09:00
        
        Верни ТОЛЬКО JSON, без markdown форматирования.
        """
        
        let query = ChatQuery(
            messages: [
                .init(role: .system, content: "Ты эксперт по анализу задач из текста. Всегда отвечай только валидным JSON."),
                .init(role: .user, content: prompt)
            ],
            model: .gpt4_o,
            temperature: 0.3
        )
        
        do {
            let result = try await openAI.chats(query: query)
            
            guard let content = result.choices.first?.message.content?.string else {
                throw GPT4Error.emptyResponse
            }
            
            // Очистка markdown форматирования если есть
            let cleanedContent = content
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let jsonData = Data(cleanedContent.utf8)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let parsed = try decoder.decode(ParsedThought.self, from: jsonData)
            return parsed
            
        } catch {
            errorMessage = "GPT-4 ошибка: \(error.localizedDescription)"
            throw GPT4Error.parsingFailed(error.localizedDescription)
        }
    }
}

// MARK: - Models

struct ParsedThought: Codable {
    let task: String?
    let subject: String?
    let when: Date?
    let context: String?
    let priority: Priority?
    let type: TaskType?
    
    enum Priority: String, Codable {
        case high, medium, low
    }
    
    enum TaskType: String, Codable {
        case call, meeting, purchase, reminder, note, task
    }
}

enum GPT4Error: LocalizedError {
    case notConfigured
    case emptyResponse
    case parsingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "API ключ OpenAI не настроен. Добавьте ключ в настройках."
        case .emptyResponse:
            return "GPT-4 вернул пустой ответ"
        case .parsingFailed(let message):
            return "Ошибка парсинга: \(message)"
        }
    }
}
