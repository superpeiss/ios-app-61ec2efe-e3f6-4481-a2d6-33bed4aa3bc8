import Foundation

/// Service responsible for managing local storage of recordings
class StorageManager: ObservableObject {
    @Published var recordings: [Recording] = []
    @Published var errorMessage: String?

    private let recordingsKey = "SavedRecordings"
    private let userDefaults = UserDefaults.standard

    init() {
        loadRecordings()
    }

    func saveRecording(_ recording: Recording) {
        recordings.insert(recording, at: 0)
        persistRecordings()
    }

    func deleteRecording(_ recording: Recording) {
        // Delete the audio file
        do {
            try FileManager.default.removeItem(at: recording.audioFileURL)
        } catch {
            errorMessage = "Failed to delete audio file: \(error.localizedDescription)"
        }

        // Remove from recordings array
        recordings.removeAll { $0.id == recording.id }
        persistRecordings()
    }

    func deleteRecording(at indexSet: IndexSet) {
        for index in indexSet {
            let recording = recordings[index]
            deleteRecording(recording)
        }
    }

    private func loadRecordings() {
        guard let data = userDefaults.data(forKey: recordingsKey) else {
            recordings = []
            return
        }

        do {
            let decoder = JSONDecoder()
            recordings = try decoder.decode([Recording].self, from: data)
        } catch {
            errorMessage = "Failed to load recordings: \(error.localizedDescription)"
            recordings = []
        }
    }

    private func persistRecordings() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recordings)
            userDefaults.set(data, forKey: recordingsKey)
        } catch {
            errorMessage = "Failed to save recordings: \(error.localizedDescription)"
        }
    }

    func getRecordingsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
