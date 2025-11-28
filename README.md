# Speech Practice

A production-ready iOS app designed to help students improve their public speaking skills through audio recording, analysis, and feedback.

## Features

- **Audio Recording with Timer**: Record practice speeches with customizable target durations
- **Filler Word Detection**: Automatic on-device analysis to detect common filler words ("um", "ah", etc.)
- **Visual Playback**: Review recordings with visual highlighting of filler word locations
- **Progress Tracking**: Save recordings locally to track improvement over time
- **MVC Architecture**: Clean, maintainable code following Model-View-Controller design pattern

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.0+

## Setup

1. Install XcodeGen:
   ```bash
   brew install xcodegen
   ```

2. Generate the Xcode project:
   ```bash
   cd SpeechPractice
   ./setup.sh
   ```
   Or manually:
   ```bash
   xcodegen generate
   ```

3. Open the generated project:
   ```bash
   open SpeechPractice.xcodeproj
   ```

## Architecture

The app follows the MVC (Model-View-Controller) design pattern with SwiftUI:

### Models
- `Recording`: Represents a speech practice session
- `FillerWord`: Detected filler word with timestamp
- `AnalysisResult`: Analysis statistics and detected filler words

### Views (SwiftUI)
- `RecordingListView`: Main screen displaying all recordings
- `RecordView`: Recording interface with timer
- `PlaybackView`: Playback with filler word visualization

### Services (Controllers)
- `AudioRecorder`: Manages audio recording functionality
- `AudioAnalyzer`: Performs on-device speech analysis
- `AudioPlayer`: Handles audio playback
- `StorageManager`: Manages local data persistence

### ViewModels
- `RecordViewModel`: Business logic for recording
- `PlaybackViewModel`: Business logic for playback

## Permissions

The app requires the following permissions:
- **Microphone**: To record audio
- **Speech Recognition**: To analyze audio for filler words

## Technical Details

- **Audio Format**: MPEG-4 AAC (M4A)
- **Sample Rate**: 44.1 kHz
- **Channels**: Mono
- **Storage**: Local filesystem with UserDefaults for metadata

## Testing

The project includes a GitHub Actions workflow for continuous integration:
- Automated build verification
- Compilation testing on each push

## License

MIT License
