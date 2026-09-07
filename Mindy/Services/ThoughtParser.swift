//
//  ThoughtParser.swift
//  Mindy
//
//  Парсер для извлечения структурированной информации из текста
//

import Foundation
import NaturalLanguage

class ThoughtParser {
    
    func parse(_ text: String) -> Thought {
        let task = extractTask(from: text)
        let subject = extractSubject(from: text)
        let when = extractDate(from: text)
        let context = extractContext(from: text)
        
        return Thought(
            originalText: text,
            task: task,
            subject: subject,
            when: when,
            context: context,
            isProcessed: true
        )
    }
    
    private func extractTask(from text: String) -> String? {
        let taskKeywords = ["позвонить", "написать", "купить", "отправить", "встретиться", 
                           "сделать", "завершить", "проверить", "напомнить", "узнать"]
        
        let lowercased = text.lowercased()
        for keyword in taskKeywords {
            if let range = lowercased.range(of: keyword) {
                let startIndex = range.lowerBound
                var endIndex = text.endIndex
                
                if let nextSentence = text[range.upperBound...].firstIndex(where: { $0 == "." || $0 == "," || $0 == "насчёт" || $0 == "про" }) {
                    endIndex = nextSentence
                }
                
                let taskText = String(text[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                return taskText
            }
        }
        
        return nil
    }
    
    private func extractSubject(from text: String) -> String? {
        let subjectKeywords = ["насчёт", "про", "о ", "об "]
        let lowercased = text.lowercased()
        
        for keyword in subjectKeywords {
            if let range = lowercased.range(of: keyword) {
                let startIndex = text.index(range.upperBound, offsetBy: 0)
                var endIndex = text.endIndex
                
                if let nextPunctuation = text[startIndex...].firstIndex(where: { $0 == "," || $0 == "." }) {
                    endIndex = nextPunctuation
                }
                
                let subject = String(text[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                return subject.isEmpty ? nil : subject
            }
        }
        
        return nil
    }
    
    private func extractDate(from text: String) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        let lowercased = text.lowercased()
        
        if lowercased.contains("завтра") {
            return calendar.date(byAdding: .day, value: 1, to: now)
        }
        
        if lowercased.contains("послезавтра") {
            return calendar.date(byAdding: .day, value: 2, to: now)
        }
        
        if lowercased.contains("сегодня") {
            return now
        }
        
        if lowercased.contains("через неделю") {
            return calendar.date(byAdding: .day, value: 7, to: now)
        }
        
        let timePatterns = [
            ("до (\\d{1,2}):?(\\d{2})?", "до времени"),
            ("в (\\d{1,2}):?(\\d{2})?", "в определённое время"),
            ("к (\\d{1,2}):?(\\d{2})?", "к времени")
        ]
        
        for (pattern, _) in timePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                if let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                    if let hourRange = Range(match.range(at: 1), in: text),
                       let hour = Int(text[hourRange]) {
                        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
                        dateComponents.hour = hour
                        dateComponents.minute = 0
                        
                        if let minuteRange = Range(match.range(at: 2), in: text),
                           let minute = Int(text[minuteRange]) {
                            dateComponents.minute = minute
                        }
                        
                        if let date = calendar.date(from: dateComponents) {
                            if lowercased.contains("завтра") {
                                return calendar.date(byAdding: .day, value: 1, to: date)
                            }
                            return date
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    private func extractContext(from text: String) -> String? {
        let contextKeywords = ["он обещал", "она сказала", "нужно", "важно", "срочно", 
                              "не забыть", "ждём", "ожидаем"]
        let lowercased = text.lowercased()
        
        for keyword in contextKeywords {
            if let range = lowercased.range(of: keyword) {
                let startIndex = range.lowerBound
                let contextText = String(text[startIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
                return contextText.isEmpty ? nil : contextText
            }
        }
        
        return nil
    }
}
