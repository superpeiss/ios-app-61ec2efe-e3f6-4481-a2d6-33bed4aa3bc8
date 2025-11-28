import SwiftUI

struct RecordingListView: View {
    @StateObject private var storageManager = StorageManager()
    @State private var showRecordView = false

    var body: some View {
        NavigationView {
            ZStack {
                if storageManager.recordings.isEmpty {
                    emptyStateView
                } else {
                    recordingsList
                }
            }
            .navigationTitle("Speech Practice")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showRecordView = true }) {
                        Image(systemName: "mic.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showRecordView) {
                RecordView(storageManager: storageManager)
            }
        }
        .navigationViewStyle(.stack)
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Recordings Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tap the microphone icon to start your first practice session")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: { showRecordView = true }) {
                Label("Start Recording", systemImage: "mic.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
    }

    private var recordingsList: some View {
        List {
            ForEach(storageManager.recordings) { recording in
                NavigationLink(destination: PlaybackView(recording: recording, storageManager: storageManager)) {
                    RecordingRow(recording: recording)
                }
            }
            .onDelete(perform: storageManager.deleteRecording)
        }
    }
}

struct RecordingRow: View {
    let recording: Recording

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recording.title)
                .font(.headline)

            HStack {
                Label(recording.formattedDate, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Label(recording.formattedDuration, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                FillerWordBadge(
                    label: "Total Fillers",
                    count: recording.analysisResult.totalCount,
                    color: .orange
                )

                FillerWordBadge(
                    label: "Um",
                    count: recording.analysisResult.umCount,
                    color: .red
                )

                FillerWordBadge(
                    label: "Ah",
                    count: recording.analysisResult.ahCount,
                    color: .purple
                )
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}

struct FillerWordBadge: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)

            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

struct RecordingListView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingListView()
    }
}
