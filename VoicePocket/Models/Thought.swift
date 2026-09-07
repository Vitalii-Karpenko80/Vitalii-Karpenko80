//
//  Thought.swift
//  VoicePocket
//
//  Модель для хранения распознанной мысли
//

import Foundation

struct Thought: Identifiable, Codable {
    let id: UUID
    let originalText: String
    let task: String?
    let subject: String?
    let when: Date?
    let context: String?
    let priority: String?
    let taskType: String?
    let createdAt: Date
    var isProcessed: Bool
    
    init(
        id: UUID = UUID(),
        originalText: String,
        task: String? = nil,
        subject: String? = nil,
        when: Date? = nil,
        context: String? = nil,
        priority: String? = nil,
        taskType: String? = nil,
        createdAt: Date = Date(),
        isProcessed: Bool = false
    ) {
        self.id = id
        self.originalText = originalText
        self.task = task
        self.subject = subject
        self.when = when
        self.context = context
        self.priority = priority
        self.taskType = taskType
        self.createdAt = createdAt
        self.isProcessed = isProcessed
    }
    
    var formattedWhen: String {
        guard let when = when else { return "Без даты" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: when)
    }
    
    var priorityColor: String {
        switch priority {
        case "high": return "🔴"
        case "medium": return "🟡"
        case "low": return "🟢"
        default: return ""
        }
    }
    
    var typeIcon: String {
        switch taskType {
        case "call": return "phone.fill"
        case "meeting": return "person.2.fill"
        case "purchase": return "cart.fill"
        case "reminder": return "bell.fill"
        case "note": return "note.text"
        default: return "checkmark.circle.fill"
        }
    }
}
