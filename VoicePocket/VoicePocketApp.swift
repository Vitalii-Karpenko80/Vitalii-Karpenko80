//
//  VoicePocketApp.swift
//  VoicePocket
//
//  Голосовой «входящий ящик» для мыслей
//

import SwiftUI

@main
struct VoicePocketApp: App {
    @StateObject private var thoughtManager = ThoughtManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(thoughtManager)
        }
    }
}
