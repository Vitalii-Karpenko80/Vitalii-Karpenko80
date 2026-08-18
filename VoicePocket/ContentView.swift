//
//  ContentView.swift
//  VoicePocket
//
//  Главный экран приложения
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var thoughtManager: ThoughtManager
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var showingTranscription = false
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    if thoughtManager.thoughts.isEmpty {
                        emptyStateView
                    } else {
                        thoughtsList
                    }
                }
                
                VStack {
                    Spacer()
                    recordButton
                        .padding(.bottom, 40)
                }
            }
            .navigationTitle("Voice Pocket")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingTranscription) {
                TranscriptionSheet(
                    transcription: speechRecognizer.transcription,
                    isRecording: speechRecognizer.isRecording,
                    onSave: {
                        if !speechRecognizer.transcription.isEmpty {
                            thoughtManager.addThought(speechRecognizer.transcription)
                            speechRecognizer.transcription = ""
                            showingTranscription = false
                        }
                    },
                    onCancel: {
                        speechRecognizer.stopRecording()
                        speechRecognizer.transcription = ""
                        showingTranscription = false
                    }
                )
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.1, blue: 0.2),
                Color(red: 0.2, green: 0.1, blue: 0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Нажмите кнопку и говорите")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("Ваши мысли автоматически\nраспознаются и структурируются")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var thoughtsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(thoughtManager.thoughts) { thought in
                    ThoughtCard(thought: thought)
                        .environmentObject(thoughtManager)
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
    }
    
    private var recordButton: some View {
        Button(action: {
            if speechRecognizer.isRecording {
                speechRecognizer.stopRecording()
            } else {
                speechRecognizer.startRecording()
                showingTranscription = true
            }
        }) {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.3, blue: 0.5),
                            Color(red: 0.8, green: 0.2, blue: 0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                )
                .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.5).opacity(0.5), radius: 20, x: 0, y: 10)
        }
    }
}

struct ThoughtCard: View {
    let thought: Thought
    @EnvironmentObject var thoughtManager: ThoughtManager
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    if let task = thought.task {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(task)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    
                    if let subject = thought.subject {
                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundColor(.orange)
                            Text(subject)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    if let when = thought.when {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text(thought.formattedWhen)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    if let context = thought.context {
                        HStack(alignment: .top) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.purple)
                            Text(context)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingDetails.toggle()
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            if showingDetails {
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Оригинальный текст:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(thought.originalText)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            thoughtManager.deleteThought(thought)
                        }) {
                            Text("Удалить")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct TranscriptionSheet: View {
    let transcription: String
    let isRecording: Bool
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.2)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    if isRecording {
                        VStack(spacing: 20) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "waveform")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                )
                                .scaleEffect(isRecording ? 1.1 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true),
                                    value: isRecording
                                )
                            
                            Text("Слушаю...")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    
                    ScrollView {
                        Text(transcription.isEmpty ? "Начните говорить..." : transcription)
                            .font(.title3)
                            .foregroundColor(transcription.isEmpty ? .white.opacity(0.5) : .white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Запись")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        onCancel()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave()
                    }
                    .foregroundColor(.white)
                    .disabled(transcription.isEmpty)
                }
            }
        }
    }
}
