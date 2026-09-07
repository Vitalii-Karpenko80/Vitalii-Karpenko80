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
    let createdAt: Date
    var isProcessed: Bool
    
    init(
        id: UUID = UUID(),
        originalText: String,
        task: String? = nil,
        subject: String? = nil,
        when: Date? = nil,
        context: String? = nil,
        createdAt: Date = Date(),
        isProcessed: Bool = false
    ) {
        self.id = id
        self.originalText = originalText
        self.task = task
        self.subject = subject
        self.when = when
        self.context = context
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
}
