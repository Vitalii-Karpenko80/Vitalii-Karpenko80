//
//  ThoughtManager.swift
//  Mindy
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
    @Published var isProcessing = false
    
    private let parser = ThoughtParser()
    private let gpt4Service = GPT4ParsingService()
    private let eventStore = EKEventStore()
    private let cloudSync = CloudSyncService()
    private let calendarService = CalendarIntegrationService()
    private let userDefaults = UserDefaults.standard
    private let thoughtsKey = "saved_thoughts"
    private let useGPT4Key = "use_gpt4_parsing"
    
    var useGPT4: Bool {
        get {
            userDefaults.bool(forKey: useGPT4Key)
        }
        set {
            userDefaults.set(newValue, forKey: useGPT4Key)
        }
    }
    
    init() {
        loadThoughts()
        requestCalendarAccess()
    }
    
    func addThought(_ text: String) async {
        isProcessing = true
        
        var thought: Thought
        
        // Гибридный подход: GPT-4 если включён и настроен, иначе локальный
        if useGPT4 && gpt4Service.isConfigured {
            do {
                let parsed = try await gpt4Service.parseThought(text)
                thought = Thought(
                    originalText: text,
                    task: parsed.task,
                    subject: parsed.subject,
                    when: parsed.when,
                    context: parsed.context,
                    priority: parsed.priority?.rawValue,
                    taskType: parsed.type?.rawValue,
                    isProcessed: true
                )
                print("✅ Использован GPT-4 парсинг")
            } catch {
                // Fallback на локальный парсер
                thought = parser.parse(text)
                errorMessage = "GPT-4 недоступен, использован локальный парсер"
                print("⚠️ Fallback на локальный парсер: \(error.localizedDescription)")
            }
        } else {
            // Локальный парсер
            thought = parser.parse(text)
            print("✅ Использован локальный парсер")
        }
        
        thoughts.insert(thought, at: 0)
        saveThoughts()
        
        // Smart Calendar Integration
        await calendarService.smartIntegrate(thought: thought)
        
        // CloudKit Sync
        if cloudSync.syncEnabled {
            do {
                try await cloudSync.uploadThought(thought)
            } catch {
                print("⚠️ CloudKit sync failed: \(error.localizedDescription)")
            }
        }
        
        isProcessing = false
    }
    
    func getGPT4Service() -> GPT4ParsingService {
        return gpt4Service
    }
    
    func deleteThought(_ thought: Thought) {
        thoughts.removeAll { $0.id == thought.id }
        saveThoughts()
        
        // Delete from CloudKit
        if cloudSync.syncEnabled {
            Task {
                do {
                    try await cloudSync.deleteThought(thought)
                } catch {
                    print("⚠️ CloudKit delete failed: \(error.localizedDescription)")
                }
            }
        }
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
