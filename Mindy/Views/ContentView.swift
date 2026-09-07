//
//  ContentView.swift
//  Mindy
//
//  Главный экран приложения (Дизайн iOS 2026)
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var thoughtManager: ThoughtManager
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var showingTranscription = false
    @State private var showingSettings = false
    @State private var showingExport = false
    @State private var buttonScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                AnimatedGradientBackground()
                
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
                        .padding(.bottom, 50)
                }
            }
            .navigationTitle("Mindy")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingExport = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.accentPrimary, .accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .springyButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.accentPrimary, .accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .springyButton()
                }
            }
            .sheet(isPresented: $showingTranscription) {
                TranscriptionSheet(
                    transcription: speechRecognizer.transcription,
                    isRecording: speechRecognizer.isRecording,
                    onSave: {
                        if !speechRecognizer.transcription.isEmpty {
                            Task {
                                await thoughtManager.addThought(speechRecognizer.transcription)
                            }
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
                .presentationDetents([.large])
                .presentationCornerRadius(32)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(thoughtManager)
            }
            .sheet(isPresented: $showingExport) {
                ExportView()
                    .environmentObject(thoughtManager)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            // Animated icon with glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.accentPrimary.opacity(0.3),
                                Color.accentPrimary.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                Circle()
                    .fill(Color.glassTint)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
                
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentPrimary, .accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.variableColor.iterative, options: .repeating)
            }
            
            VStack(spacing: 12) {
                Text("Начните говорить")
                    .font(.title1())
                    .foregroundColor(.textPrimary)
                
                Text("Ваши мысли автоматически\nраспознаются и структурируются")
                    .font(.body())
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding()
    }
    
    private var thoughtsList: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(thoughtManager.thoughts) { thought in
                    ThoughtCard(thought: thought)
                        .environmentObject(thoughtManager)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 120)
        }
    }
    
    private var recordButton: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Springy animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                buttonScale = 0.9
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    buttonScale = 1.0
                }
            }
            
            if speechRecognizer.isRecording {
                speechRecognizer.stopRecording()
            } else {
                speechRecognizer.startRecording()
                showingTranscription = true
            }
        }) {
            ZStack {
                // Outer pulsing ring when recording
                if speechRecognizer.isRecording {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.accentPrimary, .accentSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 96, height: 96)
                        .pulsing(color: .accentPrimary)
                }
                
                // Main button with liquid glass effect
                Circle()
                    .fill(
                        LinearGradient(
                            colors: speechRecognizer.isRecording 
                                ? [Color.red.opacity(0.8), Color.red]
                                : [Color.accentPrimary, Color.accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.3)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .padding(8)
                    )
                    .overlay(
                        Image(systemName: speechRecognizer.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                            .symbolEffect(.bounce, value: speechRecognizer.isRecording)
                    )
                    .softDepthShadow(
                        color: speechRecognizer.isRecording ? .red : .accentPrimary, 
                        radius: 30
                    )
            }
            .scaleEffect(buttonScale)
        }
    }
}

// MARK: - Thought Card with Liquid Glass

struct ThoughtCard: View {
    let thought: Thought
    @EnvironmentObject var thoughtManager: ThoughtManager
    @State private var showingDetails = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    if let task = thought.task {
                        HStack(spacing: 8) {
                            // Type icon
                            Image(systemName: thought.typeIcon)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .green.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .font(.title3)
                            
                            Text(task)
                                .font(.body(18))
                                .foregroundColor(.textPrimary)
                            
                            // Priority indicator
                            if !thought.priorityColor.isEmpty {
                                Text(thought.priorityColor)
                                    .font(.caption())
                            }
                        }
                    }
                    
                    if let subject = thought.subject {
                        HStack(spacing: 8) {
                            Image(systemName: "tag.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text(subject)
                                .font(.body())
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    if let when = thought.when {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.accentPrimary, .accentPrimary.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text(thought.formattedWhen)
                                .font(.caption(14))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    if let context = thought.context {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.accentSecondary, .accentSecondary.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text(context)
                                .font(.caption())
                                .foregroundColor(.textTertiary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    // GPT-4 badge если использован
                    if thoughtManager.useGPT4 && thoughtManager.getGPT4Service().isConfigured {
                        HStack(spacing: 6) {
                            Image(systemName: "brain.head.profile")
                                .font(.caption2)
                            Text("GPT-4")
                                .font(.caption(11))
                        }
                        .foregroundColor(.accentPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.accentPrimary.opacity(0.15))
                        )
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showingDetails.toggle()
                    }
                }) {
                    Image(systemName: showingDetails ? "xmark" : "ellipsis")
                        .font(.body(16))
                        .foregroundColor(.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.glassTint)
                        )
                }
                .springyButton()
            }
            
            if showingDetails {
                Divider()
                    .background(Color.glassBorder)
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Оригинальный текст:")
                        .font(.caption())
                        .foregroundColor(.textTertiary)
                    
                    Text(thought.originalText)
                        .font(.body())
                        .foregroundColor(.textSecondary)
                        .lineSpacing(4)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                thoughtManager.deleteThought(thought)
                            }
                        }) {
                            Label("Удалить", systemImage: "trash")
                                .font(.caption(13))
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.red.opacity(0.15))
                                )
                        }
                        .springyButton()
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .liquidGlassCard(
            tintColor: thought.isProcessed ? .glassTint : Color.accentPrimary.opacity(0.1),
            cornerRadius: 24
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
    }
}

// MARK: - Transcription Sheet

struct TranscriptionSheet: View {
    let transcription: String
    let isRecording: Bool
    let onSave: () -> Void
    let onCancel: () -> Void
    @EnvironmentObject var thoughtManager: ThoughtManager
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                
                VStack(spacing: 40) {
                    if isRecording {
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color.red.opacity(0.4),
                                                Color.red.opacity(0.0)
                                            ],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 60
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.red, .red.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "waveform")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                            .symbolEffect(.variableColor.iterative, options: .repeating)
                                    )
                                    .scaleEffect(isRecording ? 1.1 : 1.0)
                                    .animation(
                                        .easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true),
                                        value: isRecording
                                    )
                            }
                            
                            Text("Слушаю...")
                                .font(.title2())
                                .foregroundColor(.textPrimary)
                        }
                    }
                    
                    // Processing indicator
                    if thoughtManager.isProcessing {
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.accentPrimary)
                                .scaleEffect(1.2)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "brain.head.profile")
                                    .symbolEffect(.pulse, options: .repeating)
                                Text("GPT-4 анализирует...")
                            }
                            .font(.caption())
                            .foregroundColor(.textSecondary)
                        }
                        .padding(20)
                        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 16)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    ScrollView {
                        Text(transcription.isEmpty ? "Начните говорить..." : transcription)
                            .font(.title3)
                            .foregroundColor(transcription.isEmpty ? .textTertiary : .textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(24)
                            .frame(maxWidth: .infinity)
                            .liquidGlassCard(
                                tintColor: .glassTint,
                                cornerRadius: 20
                            )
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Запись")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        onCancel()
                    }
                    .foregroundColor(.textSecondary)
                    .springyButton()
                    .disabled(thoughtManager.isProcessing)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave()
                    }
                    .foregroundColor(.accentPrimary)
                    .fontWeight(.semibold)
                    .disabled(transcription.isEmpty || thoughtManager.isProcessing)
                    .springyButton()
                }
            }
        }
    }
}
