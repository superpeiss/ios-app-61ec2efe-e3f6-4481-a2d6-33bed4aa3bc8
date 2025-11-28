import Foundation

/// Represents a detected filler word in an audio recording
struct FillerWord: Codable, Identifiable {
    let id: UUID
    let word: String
    let timestamp: TimeInterval

    init(id: UUID = UUID(), word: String, timestamp: TimeInterval) {
        self.id = id
        self.word = word
        self.timestamp = timestamp
    }
}

/// Analysis result containing detected filler words and statistics
struct AnalysisResult: Codable {
    let fillerWords: [FillerWord]
    let totalCount: Int
    let umCount: Int
    let ahCount: Int

    init(fillerWords: [FillerWord]) {
        self.fillerWords = fillerWords
        self.totalCount = fillerWords.count
        self.umCount = fillerWords.filter { $0.word.lowercased() == "um" }.count
        self.ahCount = fillerWords.filter { $0.word.lowercased() == "ah" }.count
    }
}

/// Represents a recorded speech practice session
struct Recording: Codable, Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let duration: TimeInterval
    let audioFileURL: URL
    let analysisResult: AnalysisResult

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = Date(),
        duration: TimeInterval,
        audioFileURL: URL,
        analysisResult: AnalysisResult
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.duration = duration
        self.audioFileURL = audioFileURL
        self.analysisResult = analysisResult
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
