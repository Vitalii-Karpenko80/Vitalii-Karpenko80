//
//  ThoughtManager.swift
//  VoicePocket
//
//  Менеджер для управления мыслями и интеграции с системными API
//

import Foundation
import EventKit
import Combine

@MainActor
class ThoughtManager: ObservableObject {
    @Published var thoughts: [Thought] = []
    @Published var errorMessage: String?
    
    private let parser = ThoughtParser()
    private let eventStore = EKEventStore()
    private let userDefaults = UserDefaults.standard
    private let thoughtsKey = "saved_thoughts"
    
    init() {
        loadThoughts()
        requestCalendarAccess()
    }
    
    func addThought(_ text: String) {
        let thought = parser.parse(text)
        thoughts.insert(thought, at: 0)
        saveThoughts()
        
        if let task = thought.task {
            createReminder(title: task, dueDate: thought.when, notes: thought.context)
        }
    }
    
    func deleteThought(_ thought: Thought) {
        thoughts.removeAll { $0.id == thought.id }
        saveThoughts()
    }
    
    func markAsProcessed(_ thought: Thought) {
        if let index = thoughts.firstIndex(where: { $0.id == thought.id }) {
            thoughts[index] = Thought(
                id: thought.id,
                originalText: thought.originalText,
                task: thought.task,
                subject: thought.subject,
                when: thought.when,
                context: thought.context,
                createdAt: thought.createdAt,
                isProcessed: true
            )
            saveThoughts()
        }
    }
    
    private func requestCalendarAccess() {
        Task {
            do {
                let granted = try await eventStore.requestFullAccessToReminders()
                if !granted {
                    errorMessage = "Доступ к напоминаниям не предоставлен"
                }
            } catch {
                errorMessage = "Ошибка запроса доступа к напоминаниям: \(error.localizedDescription)"
            }
        }
    }
    
    private func createReminder(title: String, dueDate: Date?, notes: String?) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        if let dueDate = dueDate {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            reminder.dueDateComponents = components
        }
        
        if let notes = notes {
            reminder.notes = notes
        }
        
        do {
            try eventStore.save(reminder, commit: true)
            print("✅ Напоминание создано: \(title)")
        } catch {
            errorMessage = "Ошибка создания напоминания: \(error.localizedDescription)"
        }
    }
    
    private func saveThoughts() {
        if let encoded = try? JSONEncoder().encode(thoughts) {
            userDefaults.set(encoded, forKey: thoughtsKey)
        }
    }
    
    private func loadThoughts() {
        if let data = userDefaults.data(forKey: thoughtsKey),
           let decoded = try? JSONDecoder().decode([Thought].self, from: data) {
            thoughts = decoded
        }
    }
}
