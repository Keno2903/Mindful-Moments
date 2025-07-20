import SwiftUI

struct MeditationPlayerView: View {
    @EnvironmentObject var playerViewModel: MeditationPlayerViewModel
    @EnvironmentObject var dataStore: MeditationDataStore
    @Environment(\.dismiss) var dismiss
    
    var meditation: MeditationOption
    
    var body: some View {
        ZStack {
            // Background Gradient or Image based on meditation theme
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Close Button
                HStack {
                    Spacer()
                    Button {
                        playerViewModel.endMeditation(completed: false)
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding([.top, .trailing])
                
                Spacer()
                
                Text(meditation.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Circular Progress Timer Visual
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 20)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(playerViewModel.progress))
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .rotationEffect(.degrees(-90)) // Start trim from the top
                        .animation(.linear, value: playerViewModel.progress)
                    
                    Text(playerViewModel.timeRemaining.formattedTimerDuration)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(width: 250, height: 250)
                .padding(.vertical, 20)
                
                // Background Sound Control (if applicable)
                if meditation.backgroundSound != .none && dataStore.userPreferences.enableBackgroundSounds {
                    HStack {
                        Text("Hintergrund: \(meditation.backgroundSound.rawValue)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Button {
                            if playerViewModel.isBackgroundSoundPlaying {
                                playerViewModel.stopBackgroundSound()
                            } else {
                                playerViewModel.playBackgroundSound()
                            }
                        } label: {
                            Image(systemName: playerViewModel.isBackgroundSoundPlaying ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                // Timer Controls (Play/Pause, Skip)
                HStack(spacing: 40) {
                    Button {
                        playerViewModel.skipBackward(seconds: 15)
                    } label: {
                        Image(systemName: "gobackward.15")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Button {
                        playerViewModel.togglePlayPause()
                    } label: {
                        Image(systemName: playerViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                    }
                    
                    Button {
                        playerViewModel.skipForward(seconds: 30)
                    } label: {
                        Image(systemName: "goforward.30")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                Button {
                    playerViewModel.endMeditation(completed: true)
                    dismiss()
                } label: {
                    Text("Meditation beenden")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .onAppear {
            // Ensure the player is correctly set up for this meditation if it wasn't already
            if playerViewModel.currentMeditation?.id != meditation.id {
                playerViewModel.startMeditation(meditation: meditation)
            } else if !playerViewModel.isPlaying {
                 // If it's the same meditation but was paused (e.g. app backgrounded), resume it or ensure UI reflects paused state
                 // For simplicity, we might just ensure it's playing if the view appears and it's the current one.
                 // Or, the user explicitly presses play from detail view.
            }
        }
    }
}

// MARK: - Preview
struct MeditationPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMeditation = MeditationOption.defaultOptions.first!
        let playerVM = MeditationPlayerViewModel()
        // Simulate starting the meditation for the preview
        playerVM.startMeditation(meditation: sampleMeditation)
        
        return MeditationPlayerView(meditation: sampleMeditation)
            .environmentObject(playerVM)
            .environmentObject(MeditationDataStore.shared)
    }
}

// MARK: - Extension for Timer Duration Formatting
extension TimeInterval {
    var formattedTimerDuration: String {
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
}
