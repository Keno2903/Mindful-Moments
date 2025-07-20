import SwiftUI
import AVFoundation // For sound feedback

struct MeditationTimerView: View {
    let meditation: MeditationOption
    
    @State private var timeRemaining: TimeInterval
    @State private var timerActive = false
    @State private var progress: CGFloat = 1.0
    @Environment(\.dismiss) var dismiss // Updated for newer iOS versions

    // Timer object that publishes time every second
    let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Audio player for completion sound
    @State private var audioPlayer: AVAudioPlayer?

    // Initializer to set up the timer with the selected meditation's duration
    init(meditation: MeditationOption) {
        self.meditation = meditation
        _timeRemaining = State(initialValue: meditation.duration)
        // Initialize progress based on initial timeRemaining and duration
        // This ensures progress is 1.0 if duration is 0, preventing division by zero.
        if meditation.duration > 0 {
            _progress = State(initialValue: CGFloat(meditation.duration / meditation.duration))
        } else {
            _progress = State(initialValue: 1.0)
        }
    }

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.teal.opacity(0.6), Color.indigo.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                // Close Button
                HStack {
                    Spacer()
                    Button(action: {
                        stopTimer()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding([.top, .trailing])

                Text(meditation.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Circular Progress Timer Visual
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 20)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .rotationEffect(.degrees(-90)) // Start trim from the top
                        .animation(.linear(duration: 1.0), value: progress) // Animate progress changes

                    Text(timeString(time: timeRemaining))
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(width: 250, height: 250)
                .padding(.vertical, 20)
                
                Text(meditation.description)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Timer Controls (Play/Pause, Reset)
                HStack(spacing: 40) {
                    Button(action: {
                        if timerActive {
                            pauseTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Image(systemName: timerActive ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .foregroundColor(.white)
                    }

                    Button(action: {
                        resetTimer()
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                Spacer()
            }
        }
        .onReceive(timerPublisher) { _ in // Listen to timer ticks
            guard timerActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
                // Update progress, ensure duration is not zero
                progress = meditation.duration > 0 ? CGFloat(timeRemaining / meditation.duration) : 0
            } else {
                stopTimer()
                playSound(soundName: "meditation_complete_sound", type: "mp3") // Placeholder for actual sound file
                // Optionally, auto-dismiss or show a completion message
                // dismiss()
            }
        }
        .onAppear {
            // Decide if timer should start automatically or wait for play.
            // For now, require a tap on play.
        }
        .onDisappear {
            stopTimer() // Ensure timer stops if the view disappears
        }
    }

    // Helper function to format time into MM:SS string
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }

    func startTimer() {
        timerActive = true
        // playSound(soundName: "meditation_start_sound") // Optional start sound
    }

    func pauseTimer() {
        timerActive = false
    }

    func stopTimer() {
        timerActive = false
        // audioPlayer?.stop() // Stop sound if it's playing
    }
    
    func resetTimer() {
        stopTimer()
        timeRemaining = meditation.duration
        progress = meditation.duration > 0 ? 1.0 : 0
    }

    // Helper function to play a sound
    func playSound(soundName: String, type: String = "mp3") {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: type) else {
            print("Sound file not found: \(soundName).\(type). Please add it to your project.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Couldn't play sound: \(error.localizedDescription)")
        }
    }
}

// Preview for MeditationTimerView
struct MeditationTimerView_Previews: PreviewProvider {
    static var previews: some View {
        MeditationTimerView(meditation: MeditationOption(title: "Preview Meditation",
                                                          duration: 10, description: "A short 10-second preview.", category: .customS))
    }
}
