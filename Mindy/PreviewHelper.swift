//
//  PreviewHelper.swift
//  Mindy
//
//  Хелпер для SwiftUI Preview
//

import SwiftUI

extension Thought {
    static let preview1 = Thought(
        originalText: "Завтра позвонить Сергею насчёт дверей, он обещал цену до 12 часов",
        task: "позвонить Сергею",
        subject: "дверей",
        when: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
        context: "он обещал цену до 12 часов",
        priority: "high",
        taskType: "call",
        isProcessed: true
    )
    
    static let preview2 = Thought(
        originalText: "Купить молоко и хлеб сегодня",
        task: "Купить молоко и хлеб",
        subject: nil,
        when: Date(),
        context: nil,
        priority: "low",
        taskType: "purchase",
        isProcessed: true
    )
    
    static let preview3 = Thought(
        originalText: "Послезавтра написать отчёт о продажах, срочно",
        task: "написать отчёт",
        subject: "продажах",
        when: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
        context: "срочно",
        priority: "medium",
        taskType: "task",
        isProcessed: true
    )
}

#Preview("Empty State") {
    ContentView()
        .environmentObject(ThoughtManager())
}

#Preview("With Thoughts") {
    let manager = ThoughtManager()
    manager.thoughts = [.preview1, .preview2, .preview3]
    
    return ContentView()
        .environmentObject(manager)
}

#Preview("Settings") {
    SettingsView()
        .environmentObject(ThoughtManager())
}
