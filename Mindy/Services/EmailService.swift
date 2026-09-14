//
//  EmailService.swift
//  Mindy
//
//  Сервис для отправки задач по email
//

import Foundation
import MessageUI
import SwiftUI

@MainActor
class EmailService: ObservableObject {
    @Published var showingMailComposer = false
    @Published var mailResult: Result<MFMailComposeResult, Error>?
    
    static let shared = EmailService()
    
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func prepareEmail(
        subject: String,
        body: String,
        recipients: [String] = [],
        isHTML: Bool = false
    ) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: isHTML)
        composer.setToRecipients(recipients)
        return composer
    }
    
    func formatThoughtsForEmail(
        _ thoughts: [Thought],
        format: EmailFormat = .html
    ) -> (subject: String, body: String, isHTML: Bool) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        
        let subject = "Задачи Mindy - \(formatter.string(from: date))"
        
        switch format {
        case .plain:
            let body = formatPlainText(thoughts, date: date)
            return (subject, body, false)
            
        case .html:
            let body = formatHTML(thoughts, date: date)
            return (subject, body, true)
            
        case .markdown:
            let body = formatMarkdown(thoughts, date: date)
            return (subject, body, false)
        }
    }
    
    // MARK: - Format Plain Text
    
    private func formatPlainText(_ thoughts: [Thought], date: Date) -> String {
        var lines: [String] = []
        
        lines.append("═══════════════════════════════")
        lines.append("   ЗАДАЧИ MINDY")
        lines.append("═══════════════════════════════")
        lines.append("")
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        lines.append("Дата экспорта: \(formatter.string(from: date))")
        lines.append("Всего задач: \(thoughts.count)")
        lines.append("")
        
        // Group by priority
        let high = thoughts.filter { $0.priority == "high" }
        let medium = thoughts.filter { $0.priority == "medium" }
        let low = thoughts.filter { $0.priority == "low" }
        let none = thoughts.filter { $0.priority == nil || ($0.priority != "high" && $0.priority != "medium" && $0.priority != "low") }
        
        if !high.isEmpty {
            lines.append("──────────────────────────────")
            lines.append("🔴 ВЫСОКИЙ ПРИОРИТЕТ (\(high.count))")
            lines.append("──────────────────────────────")
            lines.append("")
            for thought in high {
                lines.append(contentsOf: formatThoughtPlain(thought))
                lines.append("")
            }
        }
        
        if !medium.isEmpty {
            lines.append("──────────────────────────────")
            lines.append("🟡 СРЕДНИЙ ПРИОРИТЕТ (\(medium.count))")
            lines.append("──────────────────────────────")
            lines.append("")
            for thought in medium {
                lines.append(contentsOf: formatThoughtPlain(thought))
                lines.append("")
            }
        }
        
        if !low.isEmpty {
            lines.append("──────────────────────────────")
            lines.append("🟢 НИЗКИЙ ПРИОРИТЕТ (\(low.count))")
            lines.append("──────────────────────────────")
            lines.append("")
            for thought in low {
                lines.append(contentsOf: formatThoughtPlain(thought))
                lines.append("")
            }
        }
        
        if !none.isEmpty {
            lines.append("──────────────────────────────")
            lines.append("⚪️ БЕЗ ПРИОРИТЕТА (\(none.count))")
            lines.append("──────────────────────────────")
            lines.append("")
            for thought in none {
                lines.append(contentsOf: formatThoughtPlain(thought))
                lines.append("")
            }
        }
        
        lines.append("═══════════════════════════════")
        lines.append("Отправлено из приложения Mindy")
        lines.append("https://mindy.app")
        
        return lines.joined(separator: "\n")
    }
    
    private func formatThoughtPlain(_ thought: Thought) -> [String] {
        var lines: [String] = []
        
        if let task = thought.task {
            lines.append("▸ \(task)")
        } else {
            lines.append("▸ \(thought.originalText)")
        }
        
        if let subject = thought.subject {
            lines.append("  Тема: \(subject)")
        }
        
        if let when = thought.when {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ru_RU")
            lines.append("  Когда: \(formatter.string(from: when))")
        }
        
        if let context = thought.context {
            lines.append("  Контекст: \(context)")
        }
        
        if let type = thought.taskType {
            let typeNames: [String: String] = [
                "call": "Звонок",
                "meeting": "Встреча",
                "purchase": "Покупка",
                "reminder": "Напоминание",
                "note": "Заметка",
                "task": "Задача"
            ]
            lines.append("  Тип: \(typeNames[type] ?? "Задача")")
        }
        
        return lines
    }
    
    // MARK: - Format HTML
    
    private func formatHTML(_ thoughts: [Thought], date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 20px;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                }
                .container {
                    background: white;
                    border-radius: 16px;
                    padding: 30px;
                    box-shadow: 0 10px 40px rgba(0,0,0,0.1);
                }
                .header {
                    text-align: center;
                    border-bottom: 3px solid #667eea;
                    padding-bottom: 20px;
                    margin-bottom: 30px;
                }
                .header h1 {
                    color: #667eea;
                    margin: 0;
                    font-size: 32px;
                }
                .meta {
                    color: #666;
                    font-size: 14px;
                    margin-top: 10px;
                }
                .section {
                    margin-bottom: 30px;
                }
                .section-title {
                    font-size: 20px;
                    font-weight: bold;
                    margin-bottom: 15px;
                    padding-bottom: 10px;
                    border-bottom: 2px solid #eee;
                }
                .high { color: #ef4444; }
                .medium { color: #f59e0b; }
                .low { color: #10b981; }
                .task {
                    background: #f9fafb;
                    border-left: 4px solid #667eea;
                    padding: 15px;
                    margin-bottom: 15px;
                    border-radius: 8px;
                }
                .task-title {
                    font-weight: bold;
                    font-size: 16px;
                    margin-bottom: 8px;
                    color: #111;
                }
                .task-detail {
                    font-size: 14px;
                    color: #666;
                    margin: 4px 0;
                }
                .task-detail strong {
                    color: #333;
                }
                .badge {
                    display: inline-block;
                    padding: 4px 10px;
                    border-radius: 12px;
                    font-size: 12px;
                    font-weight: 600;
                    margin-right: 8px;
                }
                .badge-high { background: #fee2e2; color: #991b1b; }
                .badge-medium { background: #fef3c7; color: #92400e; }
                .badge-low { background: #d1fae5; color: #065f46; }
                .footer {
                    text-align: center;
                    margin-top: 40px;
                    padding-top: 20px;
                    border-top: 2px solid #eee;
                    color: #999;
                    font-size: 14px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🧠 Задачи Mindy</h1>
                    <div class="meta">
                        <p>Дата экспорта: \(formatter.string(from: date))</p>
                        <p>Всего задач: <strong>\(thoughts.count)</strong></p>
                    </div>
                </div>
        """
        
        // Group by priority
        let high = thoughts.filter { $0.priority == "high" }
        let medium = thoughts.filter { $0.priority == "medium" }
        let low = thoughts.filter { $0.priority == "low" }
        let none = thoughts.filter { $0.priority == nil || ($0.priority != "high" && $0.priority != "medium" && $0.priority != "low") }
        
        if !high.isEmpty {
            html += """
                <div class="section">
                    <div class="section-title high">🔴 Высокий приоритет (\(high.count))</div>
            """
            for thought in high {
                html += formatThoughtHTML(thought, priorityClass: "high")
            }
            html += "</div>"
        }
        
        if !medium.isEmpty {
            html += """
                <div class="section">
                    <div class="section-title medium">🟡 Средний приоритет (\(medium.count))</div>
            """
            for thought in medium {
                html += formatThoughtHTML(thought, priorityClass: "medium")
            }
            html += "</div>"
        }
        
        if !low.isEmpty {
            html += """
                <div class="section">
                    <div class="section-title low">🟢 Низкий приоритет (\(low.count))</div>
            """
            for thought in low {
                html += formatThoughtHTML(thought, priorityClass: "low")
            }
            html += "</div>"
        }
        
        if !none.isEmpty {
            html += """
                <div class="section">
                    <div class="section-title">⚪️ Без приоритета (\(none.count))</div>
            """
            for thought in none {
                html += formatThoughtHTML(thought, priorityClass: "")
            }
            html += "</div>"
        }
        
        html += """
                <div class="footer">
                    <p>Отправлено из приложения <strong>Mindy</strong></p>
                    <p>Ваш умный голосовой помощник для задач</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return html
    }
    
    private func formatThoughtHTML(_ thought: Thought, priorityClass: String) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        
        var html = "<div class=\"task\">"
        
        // Badge
        if !priorityClass.isEmpty {
            html += "<span class=\"badge badge-\(priorityClass)\">\(priorityClass.uppercased())</span>"
        }
        
        // Title
        html += "<div class=\"task-title\">"
        html += thought.task ?? thought.originalText
        html += "</div>"
        
        // Details
        if let subject = thought.subject {
            html += "<div class=\"task-detail\"><strong>Тема:</strong> \(subject)</div>"
        }
        
        if let when = thought.when {
            html += "<div class=\"task-detail\"><strong>Когда:</strong> \(formatter.string(from: when))</div>"
        }
        
        if let context = thought.context {
            html += "<div class=\"task-detail\"><strong>Контекст:</strong> \(context)</div>"
        }
        
        if let type = thought.taskType {
            let typeNames: [String: String] = [
                "call": "📞 Звонок",
                "meeting": "👥 Встреча",
                "purchase": "🛒 Покупка",
                "reminder": "🔔 Напоминание",
                "note": "📝 Заметка",
                "task": "✅ Задача"
            ]
            html += "<div class=\"task-detail\"><strong>Тип:</strong> \(typeNames[type] ?? "✅ Задача")</div>"
        }
        
        html += "</div>"
        
        return html
    }
    
    // MARK: - Format Markdown
    
    private func formatMarkdown(_ thoughts: [Thought], date: Date) -> String {
        var lines: [String] = []
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        
        lines.append("# 🧠 Задачи Mindy")
        lines.append("")
        lines.append("**Дата экспорта:** \(formatter.string(from: date))")
        lines.append("**Всего задач:** \(thoughts.count)")
        lines.append("")
        lines.append("---")
        lines.append("")
        
        // Group by priority
        let high = thoughts.filter { $0.priority == "high" }
        let medium = thoughts.filter { $0.priority == "medium" }
        let low = thoughts.filter { $0.priority == "low" }
        let none = thoughts.filter { $0.priority == nil || ($0.priority != "high" && $0.priority != "medium" && $0.priority != "low") }
        
        if !high.isEmpty {
            lines.append("## 🔴 Высокий приоритет (\(high.count))")
            lines.append("")
            for thought in high {
                lines.append(contentsOf: formatThoughtMarkdown(thought))
            }
            lines.append("")
        }
        
        if !medium.isEmpty {
            lines.append("## 🟡 Средний приоритет (\(medium.count))")
            lines.append("")
            for thought in medium {
                lines.append(contentsOf: formatThoughtMarkdown(thought))
            }
            lines.append("")
        }
        
        if !low.isEmpty {
            lines.append("## 🟢 Низкий приоритет (\(low.count))")
            lines.append("")
            for thought in low {
                lines.append(contentsOf: formatThoughtMarkdown(thought))
            }
            lines.append("")
        }
        
        if !none.isEmpty {
            lines.append("## ⚪️ Без приоритета (\(none.count))")
            lines.append("")
            for thought in none {
                lines.append(contentsOf: formatThoughtMarkdown(thought))
            }
            lines.append("")
        }
        
        lines.append("---")
        lines.append("")
        lines.append("*Отправлено из приложения Mindy*")
        
        return lines.joined(separator: "\n")
    }
    
    private func formatThoughtMarkdown(_ thought: Thought) -> [String] {
        var lines: [String] = []
        
        lines.append("### \(thought.task ?? thought.originalText)")
        lines.append("")
        
        if let subject = thought.subject {
            lines.append("- **Тема:** \(subject)")
        }
        
        if let when = thought.when {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ru_RU")
            lines.append("- **Когда:** \(formatter.string(from: when))")
        }
        
        if let context = thought.context {
            lines.append("- **Контекст:** \(context)")
        }
        
        if let type = thought.taskType {
            let typeNames: [String: String] = [
                "call": "📞 Звонок",
                "meeting": "👥 Встреча",
                "purchase": "🛒 Покупка",
                "reminder": "🔔 Напоминание",
                "note": "📝 Заметка",
                "task": "✅ Задача"
            ]
            lines.append("- **Тип:** \(typeNames[type] ?? "✅ Задача")")
        }
        
        lines.append("")
        
        return lines
    }
}

// MARK: - Email Format

enum EmailFormat {
    case plain
    case html
    case markdown
}

// MARK: - Mail Composer Wrapper

struct MailComposerView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    let subject: String
    let body: String
    let isHTML: Bool
    let recipients: [String]
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(isShowing: Binding<Bool>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                isShowing = false
            }
            
            if let error = error {
                self.result = .failure(error)
            } else {
                self.result = .success(result)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing, result: $result)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: isHTML)
        composer.setToRecipients(recipients)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        
    }
}
