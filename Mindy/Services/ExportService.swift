//
//  ExportService.swift
//  Mindy
//
//  Сервис для экспорта задач в текстовый файл
//

import Foundation
import UIKit

class ExportService {
    
    // MARK: - Export Types
    
    enum ExportPeriod {
        case today
        case tomorrow
        case thisWeek
        case all
        
        var title: String {
            switch self {
            case .today: return "Сегодня"
            case .tomorrow: return "Завтра"
            case .thisWeek: return "На эту неделю"
            case .all: return "Все задачи"
            }
        }
    }
    
    enum ExportFormat {
        case plain      // Простой текст
        case markdown   // Markdown с чекбоксами
        case detailed   // Подробный с контекстом
    }
    
    // MARK: - Public Methods
    
    func exportTasks(
        _ thoughts: [Thought],
        period: ExportPeriod,
        format: ExportFormat = .detailed
    ) -> String {
        let filtered = filterThoughts(thoughts, by: period)
        
        switch format {
        case .plain:
            return generatePlainText(filtered, period: period)
        case .markdown:
            return generateMarkdown(filtered, period: period)
        case .detailed:
            return generateDetailed(filtered, period: period)
        }
    }
    
    func createTextFile(
        content: String,
        period: ExportPeriod
    ) -> URL? {
        let filename = generateFilename(for: period)
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("❌ Ошибка создания файла: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func filterThoughts(_ thoughts: [Thought], by period: ExportPeriod) -> [Thought] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .today:
            return thoughts.filter { thought in
                guard let when = thought.when else { return false }
                return calendar.isDateInToday(when)
            }
            
        case .tomorrow:
            return thoughts.filter { thought in
                guard let when = thought.when else { return false }
                return calendar.isDateInTomorrow(when)
            }
            
        case .thisWeek:
            return thoughts.filter { thought in
                guard let when = thought.when else { return false }
                let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now)!
                return when >= now && when <= weekFromNow
            }
            
        case .all:
            return thoughts
        }
    }
    
    // MARK: - Format Generators
    
    private func generatePlainText(_ thoughts: [Thought], period: ExportPeriod) -> String {
        var output = "MINDY - ЗАДАЧИ НА \(period.title.uppercased())\n"
        output += "Создано: \(formattedDate(Date()))\n"
        output += String(repeating: "=", count: 50) + "\n\n"
        
        if thoughts.isEmpty {
            output += "Нет задач на этот период.\n"
            return output
        }
        
        for (index, thought) in thoughts.enumerated() {
            output += "\(index + 1). \(thought.task ?? "Задача")\n"
            
            if let when = thought.when {
                output += "   ⏰ \(formattedDate(when))\n"
            }
            
            if let subject = thought.subject {
                output += "   📝 Тема: \(subject)\n"
            }
            
            if let priority = thought.priority {
                output += "   🎯 Приоритет: \(priority)\n"
            }
            
            output += "\n"
        }
        
        return output
    }
    
    private func generateMarkdown(_ thoughts: [Thought], period: ExportPeriod) -> String {
        var output = "# 🧠 Mindy - Задачи на \(period.title)\n\n"
        output += "**Создано**: \(formattedDate(Date()))\n\n"
        output += "---\n\n"
        
        if thoughts.isEmpty {
            output += "Нет задач на этот период.\n"
            return output
        }
        
        // Группировка по приоритету
        let grouped = Dictionary(grouping: thoughts) { $0.priority ?? "medium" }
        let priorities = ["high", "medium", "low"]
        
        for priority in priorities {
            guard let tasks = grouped[priority], !tasks.isEmpty else { continue }
            
            let emoji = priority == "high" ? "🔴" : priority == "medium" ? "🟡" : "🟢"
            let title = priority == "high" ? "Высокий приоритет" : priority == "medium" ? "Средний приоритет" : "Низкий приоритет"
            
            output += "## \(emoji) \(title)\n\n"
            
            for thought in tasks {
                output += "- [ ] **\(thought.task ?? "Задача")**\n"
                
                if let when = thought.when {
                    output += "  - ⏰ \(formattedDate(when))\n"
                }
                
                if let subject = thought.subject {
                    output += "  - 📝 \(subject)\n"
                }
                
                if let context = thought.context {
                    output += "  - 💡 \(context)\n"
                }
                
                output += "\n"
            }
        }
        
        return output
    }
    
    private func generateDetailed(_ thoughts: [Thought], period: ExportPeriod) -> String {
        var output = "🧠 MINDY - МОИ ЗАДАЧИ\n"
        output += String(repeating: "═", count: 50) + "\n\n"
        output += "📅 Период: \(period.title)\n"
        output += "🕐 Создано: \(formattedDate(Date()))\n"
        output += "📊 Всего задач: \(thoughts.count)\n"
        output += "\n" + String(repeating: "═", count: 50) + "\n\n"
        
        if thoughts.isEmpty {
            output += "✨ Нет задач на этот период.\n"
            output += "Используйте Mindy, чтобы добавить новые задачи!\n"
            return output
        }
        
        // Группировка по дате
        let grouped = Dictionary(grouping: thoughts) { thought -> String in
            guard let when = thought.when else { return "Без даты" }
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            formatter.locale = Locale(identifier: "ru_RU")
            return formatter.string(from: when)
        }
        
        let sortedDates = grouped.keys.sorted()
        
        for date in sortedDates {
            guard let tasks = grouped[date] else { continue }
            
            output += "📆 \(date)\n"
            output += String(repeating: "─", count: 50) + "\n\n"
            
            for (index, thought) in tasks.enumerated() {
                // Номер и задача
                output += "\(index + 1). "
                
                // Тип задачи
                if let type = thought.taskType {
                    let icon = getTypeIcon(type)
                    output += "\(icon) "
                }
                
                output += "\(thought.task ?? "Задача")\n"
                
                // Приоритет
                if let priority = thought.priority {
                    let priorityText = priority == "high" ? "🔴 ВЫСОКИЙ" : priority == "medium" ? "🟡 СРЕДНИЙ" : "🟢 НИЗКИЙ"
                    output += "   Приоритет: \(priorityText)\n"
                }
                
                // Тема
                if let subject = thought.subject {
                    output += "   Тема: \(subject)\n"
                }
                
                // Время
                if let when = thought.when {
                    let timeFormatter = DateFormatter()
                    timeFormatter.timeStyle = .short
                    timeFormatter.locale = Locale(identifier: "ru_RU")
                    output += "   Время: \(timeFormatter.string(from: when))\n"
                }
                
                // Контекст
                if let context = thought.context {
                    output += "   💡 Контекст: \(context)\n"
                }
                
                // Оригинальный текст
                output += "   🎤 \"\(thought.originalText)\"\n"
                
                output += "\n"
            }
        }
        
        // Статистика
        output += String(repeating: "═", count: 50) + "\n"
        output += "📊 СТАТИСТИКА\n"
        output += String(repeating: "─", count: 50) + "\n"
        
        let highPriority = thoughts.filter { $0.priority == "high" }.count
        let mediumPriority = thoughts.filter { $0.priority == "medium" }.count
        let lowPriority = thoughts.filter { $0.priority == "low" }.count
        
        output += "🔴 Высокий приоритет: \(highPriority)\n"
        output += "🟡 Средний приоритет: \(mediumPriority)\n"
        output += "🟢 Низкий приоритет: \(lowPriority)\n\n"
        
        output += "Создано с помощью Mindy 🧠\n"
        output += "Your AI Thought Companion\n"
        
        return output
    }
    
    // MARK: - Helpers
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func generateFilename(for period: ExportPeriod) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        let periodString = period.title.lowercased()
            .replacingOccurrences(of: " ", with: "-")
        
        return "mindy-tasks-\(periodString)-\(dateString).txt"
    }
    
    private func getTypeIcon(_ type: String) -> String {
        switch type {
        case "call": return "📞"
        case "meeting": return "👥"
        case "purchase": return "🛒"
        case "reminder": return "🔔"
        case "note": return "📝"
        default: return "✅"
        }
    }
}
