import SwiftUI

struct RecordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RecordViewModel
    @State private var targetDuration: TimeInterval = 120 // Default 2 minutes

    init(storageManager: StorageManager) {
        _viewModel = StateObject(wrappedValue: RecordViewModel(storageManager: storageManager))
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    timerDisplay

                    targetDurationPicker

                    recordButton

                    Spacer()

                    if viewModel.isRecording {
                        stopButton
                    }
                }
                .padding()
            }
            .navigationTitle("Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if viewModel.isRecording {
                            viewModel.toggleRecording()
                        }
                        dismiss()
                    }
                }
            }
            .alert("Permission Required", isPresented: $viewModel.showPermissionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please grant microphone and speech recognition permissions in Settings to use this feature.")
            }
            .sheet(isPresented: $viewModel.showSaveDialog) {
                SaveRecordingView(
                    recordingTitle: $viewModel.recordingTitle,
                    isAnalyzing: viewModel.isAnalyzing,
                    onSave: {
                        viewModel.saveRecording()
                        dismiss()
                    },
                    onDiscard: {
                        viewModel.discardRecording()
                    }
                )
            }
        }
    }

    private var timerDisplay: some View {
        VStack(spacing: 10) {
            Text(formatTime(viewModel.recordingTime))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()

            if viewModel.isRecording && targetDuration > 0 {
                ProgressView(value: min(viewModel.recordingTime, targetDuration), total: targetDuration)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .frame(width: 200)

                Text("Target: \(formatTime(targetDuration))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var targetDurationPicker: some View {
        VStack(spacing: 8) {
            Text("Target Duration")
                .font(.headline)
                .foregroundColor(.secondary)

            Picker("Target Duration", selection: $targetDuration) {
                Text("1 min").tag(TimeInterval(60))
                Text("2 min").tag(TimeInterval(120))
                Text("3 min").tag(TimeInterval(180))
                Text("5 min").tag(TimeInterval(300))
                Text("10 min").tag(TimeInterval(600))
            }
            .pickerStyle(.segmented)
            .disabled(viewModel.isRecording)
        }
        .padding(.horizontal)
    }

    private var recordButton: some View {
        Button(action: {
            viewModel.toggleRecording()
        }) {
            ZStack {
                Circle()
                    .fill(viewModel.isRecording ? Color.red : Color.blue)
                    .frame(width: 120, height: 120)
                    .shadow(radius: 10)

                Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(viewModel.isRecording ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isRecording)
    }

    private var stopButton: some View {
        Text("Tap to stop recording")
            .font(.headline)
            .foregroundColor(.secondary)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct SaveRecordingView: View {
    @Binding var recordingTitle: String
    let isAnalyzing: Bool
    let onSave: () -> Void
    let onDiscard: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recording Details")) {
                    TextField("Title", text: $recordingTitle)
                }

                Section {
                    if isAnalyzing {
                        HStack {
                            ProgressView()
                            Text("Analyzing audio...")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Button(action: {
                            onSave()
                        }) {
                            Text("Save Recording")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.blue)
                        }

                        Button(role: .destructive, action: {
                            onDiscard()
                            dismiss()
                        }) {
                            Text("Discard")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle("Save Recording")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(isAnalyzing)
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(storageManager: StorageManager())
    }
}
