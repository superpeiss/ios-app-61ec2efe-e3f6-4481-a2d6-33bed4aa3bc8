import SwiftUI

struct PlaybackView: View {
    @StateObject private var viewModel: PlaybackViewModel
    @ObservedObject var storageManager: StorageManager
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false

    init(recording: Recording, storageManager: StorageManager) {
        _viewModel = StateObject(wrappedValue: PlaybackViewModel(recording: recording))
        self.storageManager = storageManager
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                statisticsSection

                waveformVisualization

                playbackControls

                fillerWordsTimeline

                fillerWordsList
            }
            .padding()
        }
        .navigationTitle(viewModel.recording.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive, action: { showDeleteAlert = true }) {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete Recording", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                storageManager.deleteRecording(viewModel.recording)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this recording? This action cannot be undone.")
        }
    }

    private var statisticsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                StatisticCard(
                    title: "Duration",
                    value: viewModel.recording.formattedDuration,
                    icon: "clock",
                    color: .blue
                )

                StatisticCard(
                    title: "Total Fillers",
                    value: "\(viewModel.recording.analysisResult.totalCount)",
                    icon: "exclamationmark.triangle",
                    color: .orange
                )
            }

            HStack(spacing: 20) {
                StatisticCard(
                    title: "Um Count",
                    value: "\(viewModel.recording.analysisResult.umCount)",
                    icon: "waveform",
                    color: .red
                )

                StatisticCard(
                    title: "Ah Count",
                    value: "\(viewModel.recording.analysisResult.ahCount)",
                    icon: "waveform",
                    color: .purple
                )
            }
        }
    }

    private var waveformVisualization: some View {
        VStack(spacing: 8) {
            Text("Playback Position")
                .font(.headline)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 60)

                // Filler word markers
                GeometryReader { geometry in
                    ForEach(viewModel.recording.analysisResult.fillerWords) { fillerWord in
                        let position = (fillerWord.timestamp / viewModel.duration) * geometry.size.width

                        Rectangle()
                            .fill(fillerWord.word == "um" ? Color.red : Color.purple)
                            .frame(width: 3, height: 60)
                            .offset(x: position)
                    }
                }

                // Current position indicator
                GeometryReader { geometry in
                    let position = (viewModel.currentTime / viewModel.duration) * geometry.size.width

                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 2, height: 60)
                        .offset(x: position)
                }
            }
            .frame(height: 60)

            HStack {
                Text(formatTime(viewModel.currentTime))
                    .font(.caption)
                    .monospacedDigit()

                Spacer()

                if let currentFillerWord = viewModel.isFillerWordAtCurrentTime() {
                    Text("Filler: \(currentFillerWord.word.uppercased())")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(currentFillerWord.word == "um" ? Color.red : Color.purple)
                        .cornerRadius(4)
                }

                Spacer()

                Text(formatTime(viewModel.duration))
                    .font(.caption)
                    .monospacedDigit()
            }
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 40) {
            Button(action: {
                viewModel.seek(to: max(0, viewModel.currentTime - 10))
            }) {
                Image(systemName: "gobackward.10")
                    .font(.title)
                    .foregroundColor(.blue)
            }

            Button(action: {
                viewModel.togglePlayback()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 70, height: 70)

                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }

            Button(action: {
                viewModel.seek(to: min(viewModel.duration, viewModel.currentTime + 10))
            }) {
                Image(systemName: "goforward.10")
                    .font(.title)
                    .foregroundColor(.blue)
            }
        }
    }

    private var fillerWordsTimeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filler Words Detected")
                .font(.headline)

            if viewModel.recording.analysisResult.fillerWords.isEmpty {
                Text("No filler words detected. Great job!")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }

    private var fillerWordsList: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.recording.analysisResult.fillerWords) { fillerWord in
                FillerWordRow(
                    fillerWord: fillerWord,
                    isCurrentlyPlaying: abs(fillerWord.timestamp - viewModel.currentTime) < 0.5,
                    onTap: {
                        viewModel.seek(to: fillerWord.timestamp)
                    }
                )
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct FillerWordRow: View {
    let fillerWord: FillerWord
    let isCurrentlyPlaying: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(fillerWord.word == "um" ? Color.red : Color.purple)
                    .frame(width: 12, height: 12)

                Text(fillerWord.word.uppercased())
                    .font(.headline)
                    .foregroundColor(fillerWord.word == "um" ? .red : .purple)

                Spacer()

                Text(formatTimestamp(fillerWord.timestamp))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .monospacedDigit()

                if isCurrentlyPlaying {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isCurrentlyPlaying ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isCurrentlyPlaying ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func formatTimestamp(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct PlaybackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlaybackView(
                recording: Recording(
                    title: "Sample Recording",
                    duration: 120,
                    audioFileURL: URL(fileURLWithPath: "/tmp/sample.m4a"),
                    analysisResult: AnalysisResult(fillerWords: [
                        FillerWord(word: "um", timestamp: 10),
                        FillerWord(word: "ah", timestamp: 25),
                        FillerWord(word: "um", timestamp: 45)
                    ])
                ),
                storageManager: StorageManager()
            )
        }
    }
}
