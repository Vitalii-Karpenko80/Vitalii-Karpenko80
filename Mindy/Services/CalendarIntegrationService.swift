//
//  CalendarIntegrationService.swift
//  Mindy
//
//  Расширенная интеграция с календарем и напоминаниями
//

import Foundation
import EventKit

@MainActor
class CalendarIntegrationService: ObservableObject {
    @Published var errorMessage: String?
    @Published var calendarEnabled = false
    @Published var remindersEnabled = false
    
    private let eventStore = EKEventStore()
    private let userDefaults = UserDefaults.standard
    private let calendarEnabledKey = "calendar_integration_enabled"
    private let remindersEnabledKey = "reminders_integration_enabled"
    private let defaultCalendarKey = "default_calendar_id"
    
    init() {
        calendarEnabled = userDefaults.bool(forKey: calendarEnabledKey)
        remindersEnabled = userDefaults.bool(forKey: remindersEnabledKey)
        requestAccess()
    }
    
    // MARK: - Authorization
    
    func requestAccess() {
        Task {
            do {
                // Request calendar access
                let calendarGranted = try await eventStore.requestFullAccessToEvents()
                calendarEnabled = calendarGranted
                userDefaults.set(calendarGranted, forKey: calendarEnabledKey)
                
                // Request reminders access
                let remindersGranted = try await eventStore.requestFullAccessToReminders()
                remindersEnabled = remindersGranted
                userDefaults.set(remindersGranted, forKey: remindersEnabledKey)
                
                if !calendarGranted {
                    errorMessage = "Доступ к календарю не предоставлен"
                }
                if !remindersGranted {
                    errorMessage = "Доступ к напоминаниям не предоставлен"
                }
            } catch {
                errorMessage = "Ошибка запроса доступа: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Calendar Events
    
    func createCalendarEvent(from thought: Thought) async -> Bool {
        guard calendarEnabled else {
            errorMessage = "Календарь не доступен"
            return false
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = thought.task ?? thought.originalText
        event.calendar = getDefaultCalendar()
        
        if let when = thought.when {
            event.startDate = when
            // Default duration: 1 hour
            event.endDate = when.addingTimeInterval(3600)
        } else {
            // If no date, create event for now + 1 hour
            event.startDate = Date()
            event.endDate = Date().addingTimeInterval(3600)
        }
        
        if let context = thought.context {
            event.notes = context
        }
        
        // Add location for meetings
        if thought.taskType == "meeting" {
            // Try to extract location from context
            if let context = thought.context {
                event.location = extractLocation(from: context)
            }
        }
        
        // Set alert based on priority
        if let priority = thought.priority {
            let alarm: EKAlarm
            switch priority {
            case "high":
                alarm = EKAlarm(relativeOffset: -3600) // 1 hour before
            case "medium":
                alarm = EKAlarm(relativeOffset: -1800) // 30 min before
            case "low":
                alarm = EKAlarm(relativeOffset: -900) // 15 min before
            default:
                alarm = EKAlarm(relativeOffset: -1800)
            }
            event.addAlarm(alarm)
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("✅ Событие создано в календаре: \(event.title)")
            return true
        } catch {
            errorMessage = "Ошибка создания события: \(error.localizedDescription)"
            print("❌ Ошибка создания события: \(error)")
            return false
        }
    }
    
    // MARK: - Reminders
    
    func createReminder(from thought: Thought) async -> Bool {
        guard remindersEnabled else {
            errorMessage = "Напоминания не доступны"
            return false
        }
        
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = thought.task ?? thought.originalText
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        if let when = thought.when {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: when)
            reminder.dueDateComponents = components
        }
        
        if let context = thought.context {
            reminder.notes = context
        }
        
        // Set priority
        if let priorityString = thought.priority {
            switch priorityString {
            case "high":
                reminder.priority = 1 // High
            case "medium":
                reminder.priority = 5 // Medium
            case "low":
                reminder.priority = 9 // Low
            default:
                reminder.priority = 0 // None
            }
        }
        
        do {
            try eventStore.save(reminder, commit: true)
            print("✅ Напоминание создано: \(reminder.title)")
            return true
        } catch {
            errorMessage = "Ошибка создания напоминания: \(error.localizedDescription)"
            print("❌ Ошибка создания напоминания: \(error)")
            return false
        }
    }
    
    // MARK: - Smart Integration
    
    func smartIntegrate(thought: Thought) async {
        // Decide whether to create calendar event or reminder based on task type
        switch thought.taskType {
        case "meeting":
            // Meetings go to calendar
            let _ = await createCalendarEvent(from: thought)
            
        case "call":
            // Calls can be both - create reminder
            let _ = await createReminder(from: thought)
            
        case "purchase", "note":
            // Simple tasks - reminder only
            let _ = await createReminder(from: thought)
            
        default:
            // Default: create reminder
            let _ = await createReminder(from: thought)
        }
    }
    
    // MARK: - Helpers
    
    private func getDefaultCalendar() -> EKCalendar {
        if let savedCalendarID = userDefaults.string(forKey: defaultCalendarKey),
           let calendar = eventStore.calendar(withIdentifier: savedCalendarID) {
            return calendar
        }
        return eventStore.defaultCalendarForNewEvents ?? eventStore.calendars(for: .event).first!
    }
    
    func getAvailableCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
    
    func setDefaultCalendar(_ calendar: EKCalendar) {
        userDefaults.set(calendar.calendarIdentifier, forKey: defaultCalendarKey)
    }
    
    private func extractLocation(from text: String) -> String? {
        // Simple location extraction - look for common patterns
        let patterns = [
            "в (.*?)(?:\\s|$)",
            "на (.*?)(?:\\s|$)",
            "по адресу (.*?)(?:\\s|$)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range(at: 1), in: text) {
                return String(text[range])
            }
        }
        
        return nil
    }
    
    // MARK: - Batch Operations
    
    func createBatchEvents(from thoughts: [Thought]) async -> (success: Int, failed: Int) {
        var successCount = 0
        var failedCount = 0
        
        for thought in thoughts {
            let success = await createCalendarEvent(from: thought)
            if success {
                successCount += 1
            } else {
                failedCount += 1
            }
        }
        
        return (successCount, failedCount)
    }
}
