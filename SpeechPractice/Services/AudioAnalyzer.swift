import Foundation
import Speech
import AVFoundation

/// Service responsible for analyzing audio recordings to detect filler words
class AudioAnalyzer: ObservableObject {
    @Published var isAnalyzing = false
    @Published var errorMessage: String?

    private let fillerWords = ["um", "uh", "ah", "er", "hmm"]

    func requestSpeechRecognitionPermission(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }

    func analyzeAudio(at url: URL, completion: @escaping (Result<AnalysisResult, Error>) -> Void) {
        guard let recognizer = SFSpeechRecognizer() else {
            completion(.failure(AudioAnalyzerError.recognizerUnavailable))
            return
        }

        guard recognizer.isAvailable else {
            completion(.failure(AudioAnalyzerError.recognizerNotAvailable))
            return
        }

        isAnalyzing = true

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false

        recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isAnalyzing = false

                if let error = error {
                    self.errorMessage = "Analysis failed: \(error.localizedDescription)"
                    completion(.failure(error))
                    return
                }

                guard let result = result, result.isFinal else {
                    return
                }

                let detectedFillerWords = self.detectFillerWords(from: result)
                let analysisResult = AnalysisResult(fillerWords: detectedFillerWords)
                completion(.success(analysisResult))
            }
        }
    }

    private func detectFillerWords(from result: SFSpeechRecognitionResult) -> [FillerWord] {
        var detectedWords: [FillerWord] = []

        for segment in result.bestTranscription.segments {
            let word = segment.substring.lowercased()

            // Check if the word is a filler word
            if fillerWords.contains(word) {
                let fillerWord = FillerWord(
                    word: word,
                    timestamp: segment.timestamp
                )
                detectedWords.append(fillerWord)
            }
        }

        return detectedWords
    }

    // Fallback analysis for when Speech Recognition is not available
    func analyzeAudioFallback(at url: URL, completion: @escaping (Result<AnalysisResult, Error>) -> Void) {
        // This is a simplified fallback that simulates detection
        // In a production app, you might use signal processing techniques
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let audioFile = try AVAudioFile(forReading: url)
                let duration = Double(audioFile.length) / audioFile.processingFormat.sampleRate

                // Simulate some filler words for demonstration
                // In a real implementation, this would use audio signal processing
                var simulatedFillerWords: [FillerWord] = []

                // Add a few simulated detections based on duration
                let detectionCount = Int(duration / 30) // One detection every 30 seconds
                for i in 0..<detectionCount {
                    let timestamp = Double(i) * 30.0 + Double.random(in: 0...20)
                    let word = ["um", "ah"].randomElement() ?? "um"
                    simulatedFillerWords.append(FillerWord(word: word, timestamp: timestamp))
                }

                let result = AnalysisResult(fillerWords: simulatedFillerWords)

                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

enum AudioAnalyzerError: LocalizedError {
    case recognizerUnavailable
    case recognizerNotAvailable

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable:
            return "Speech recognizer is not available on this device"
        case .recognizerNotAvailable:
            return "Speech recognizer is not currently available"
        }
    }
}
