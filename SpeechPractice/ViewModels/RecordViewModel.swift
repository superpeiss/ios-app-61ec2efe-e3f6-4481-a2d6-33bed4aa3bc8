import Foundation
import SwiftUI

/// ViewModel for managing recording functionality
class RecordViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var showPermissionAlert = false
    @Published var showSaveDialog = false
    @Published var recordingTitle = ""
    @Published var isAnalyzing = false
    @Published var errorMessage: String?

    private let audioRecorder = AudioRecorder()
    private let audioAnalyzer = AudioAnalyzer()
    private let storageManager: StorageManager

    private var currentAudioURL: URL?

    init(storageManager: StorageManager) {
        self.storageManager = storageManager
        setupObservers()
    }

    private func setupObservers() {
        audioRecorder.$recordingTime
            .assign(to: &$recordingTime)

        audioRecorder.$errorMessage
            .compactMap { $0 }
            .assign(to: &$errorMessage)

        audioAnalyzer.$errorMessage
            .compactMap { $0 }
            .assign(to: &$errorMessage)
    }

    func checkPermissions(completion: @escaping (Bool) -> Void) {
        audioRecorder.requestMicrophonePermission { [weak self] micGranted in
            guard micGranted else {
                completion(false)
                return
            }

            self?.audioAnalyzer.requestSpeechRecognitionPermission { speechGranted in
                completion(speechGranted)
            }
        }
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        checkPermissions { [weak self] granted in
            guard let self = self else { return }

            if granted {
                if let url = self.audioRecorder.startRecording() {
                    self.currentAudioURL = url
                    self.isRecording = true
                }
            } else {
                self.showPermissionAlert = true
            }
        }
    }

    private func stopRecording() {
        let duration = audioRecorder.stopRecording()
        isRecording = false

        if duration > 0 {
            showSaveDialog = true
        } else {
            errorMessage = "Recording is too short"
        }
    }

    func saveRecording() {
        guard let audioURL = currentAudioURL else {
            errorMessage = "No recording to save"
            return
        }

        let title = recordingTitle.isEmpty ? "Recording \(Date().formatted())" : recordingTitle

        isAnalyzing = true

        audioAnalyzer.analyzeAudio(at: audioURL) { [weak self] result in
            guard let self = self else { return }

            self.isAnalyzing = false

            switch result {
            case .success(let analysisResult):
                let recording = Recording(
                    title: title,
                    duration: self.recordingTime,
                    audioFileURL: audioURL,
                    analysisResult: analysisResult
                )

                self.storageManager.saveRecording(recording)
                self.resetState()

            case .failure:
                // If speech recognition fails, try fallback analysis
                self.audioAnalyzer.analyzeAudioFallback(at: audioURL) { fallbackResult in
                    switch fallbackResult {
                    case .success(let analysisResult):
                        let recording = Recording(
                            title: title,
                            duration: self.recordingTime,
                            audioFileURL: audioURL,
                            analysisResult: analysisResult
                        )

                        self.storageManager.saveRecording(recording)
                        self.resetState()

                    case .failure(let error):
                        self.errorMessage = "Failed to analyze recording: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    func discardRecording() {
        if let audioURL = currentAudioURL {
            try? FileManager.default.removeItem(at: audioURL)
        }
        resetState()
    }

    private func resetState() {
        currentAudioURL = nil
        recordingTitle = ""
        recordingTime = 0
        showSaveDialog = false
    }
}
