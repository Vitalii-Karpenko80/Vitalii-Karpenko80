//
//  SpeechRecognizer.swift
//  VoicePocket
//
//  Сервис для распознавания речи
//

import Foundation
import Speech
import AVFoundation

@MainActor
class SpeechRecognizer: ObservableObject {
    @Published var isRecording = false
    @Published var transcription = ""
    @Published var errorMessage: String?
    
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("✅ Разрешение на распознавание речи получено")
                case .denied:
                    self?.errorMessage = "Доступ к распознаванию речи запрещён"
                case .restricted:
                    self?.errorMessage = "Распознавание речи ограничено на этом устройстве"
                case .notDetermined:
                    self?.errorMessage = "Разрешение на распознавание речи не запрошено"
                @unknown default:
                    self?.errorMessage = "Неизвестная ошибка авторизации"
                }
            }
        }
    }
    
    func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Распознавание речи недоступно"
            return
        }
        
        // Остановка предыдущей записи
        if let task = recognitionTask {
            task.cancel()
            self.recognitionTask = nil
        }
        
        // Настройка аудио сессии
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Ошибка настройки аудио: \(error.localizedDescription)"
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Не удалось создать запрос распознавания"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Настройка аудио движка
        audioEngine = AVAudioEngine()
        let inputNode = audioEngine!.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine!.prepare()
        
        do {
            try audioEngine!.start()
        } catch {
            errorMessage = "Ошибка запуска аудио движка: \(error.localizedDescription)"
            return
        }
        
        transcription = ""
        isRecording = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                Task { @MainActor in
                    self.transcription = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                Task { @MainActor in
                    self.stopRecording()
                }
            }
        }
    }
    
    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}
