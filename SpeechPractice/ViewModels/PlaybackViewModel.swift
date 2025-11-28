import Foundation
import SwiftUI

/// ViewModel for managing playback functionality
class PlaybackViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var errorMessage: String?

    let recording: Recording
    private let audioPlayer = AudioPlayer()

    init(recording: Recording) {
        self.recording = recording
        setupObservers()
        loadAudio()
    }

    private func setupObservers() {
        audioPlayer.$isPlaying
            .assign(to: &$isPlaying)

        audioPlayer.$currentTime
            .assign(to: &$currentTime)

        audioPlayer.$duration
            .assign(to: &$duration)

        audioPlayer.$errorMessage
            .compactMap { $0 }
            .assign(to: &$errorMessage)
    }

    private func loadAudio() {
        audioPlayer.loadAudio(from: recording.audioFileURL)
    }

    func togglePlayback() {
        if isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }

    func stop() {
        audioPlayer.stop()
    }

    func seek(to time: TimeInterval) {
        audioPlayer.seek(to: time)
    }

    func isFillerWordAtCurrentTime(threshold: TimeInterval = 0.5) -> FillerWord? {
        recording.analysisResult.fillerWords.first { fillerWord in
            abs(fillerWord.timestamp - currentTime) < threshold
        }
    }

    func getFillerWordsInRange(start: TimeInterval, end: TimeInterval) -> [FillerWord] {
        recording.analysisResult.fillerWords.filter { fillerWord in
            fillerWord.timestamp >= start && fillerWord.timestamp <= end
        }
    }
}
