//
//  QuickRecordIntent.swift
//  VoicePocket
//
//  App Intent для Action Button и Shortcuts
//

import AppIntents
import SwiftUI

struct QuickRecordIntent: AppIntent {
    static var title: LocalizedStringResource = "Быстрая запись мысли"
    static var description = IntentDescription("Открывает Voice Pocket и сразу начинает запись")
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct VoicePocketShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: QuickRecordIntent(),
            phrases: [
                "Записать мысль в \(.applicationName)",
                "Открыть \(.applicationName)",
                "Новая заметка в \(.applicationName)"
            ],
            shortTitle: "Записать мысль",
            systemImageName: "mic.circle.fill"
        )
    }
}
