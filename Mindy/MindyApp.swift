//
//  VoicePocketApp.swift
//  VoicePocket
//
//  Голосовой «входящий ящик» для мыслей (iOS 2026)
//

import SwiftUI

@main
struct VoicePocketApp: App {
    @StateObject private var thoughtManager = ThoughtManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(thoughtManager)
                .preferredColorScheme(.dark) // Dark Mode 2.0 как стандарт
        }
    }
}
