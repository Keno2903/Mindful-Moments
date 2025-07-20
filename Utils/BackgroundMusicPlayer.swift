// MindfulMoments/Utils/BackgroundMusicPlayer.swift

import Foundation
import AVFoundation

class BackgroundMusicPlayer: ObservableObject {
    static let shared = BackgroundMusicPlayer() // Singleton instance

    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentTrack: BackgroundMusicTrack?

    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            // try AVAudioSession.sharedInstance().setActive(true) // Activation can be deferred or handled more carefully
        } catch {
            print("Failed to set audio session category for background music: \(error)")
        }
    }

    func playTrack(_ track: BackgroundMusicTrack, userPreferences: UserPreferences) {
        guard userPreferences.enableBackgroundMusic else {
            print("BackgroundMusicPlayer: Music is disabled in preferences.")
            stop() // Ensure it's stopped if disabled
            return
        }
        
        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: nil) else { // fileName includes extension
            print("Error: Background music file not found for track: \(track.fileName)")
            self.currentTrack = nil
            self.isPlaying = false
            return
        }

        if audioPlayer != nil && isPlaying {
            stop()
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = userPreferences.backgroundMusicVolume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            self.isPlaying = true
            self.currentTrack = track
            print("BackgroundMusicPlayer: Playing track \(track.displayName) at volume \(userPreferences.backgroundMusicVolume)")
        } catch {
            print("Error playing background music track \(track.displayName): \(error.localizedDescription)")
            self.isPlaying = false
            self.currentTrack = nil
        }
    }

    func setVolume(_ volume: Float) {
        audioPlayer?.volume = max(0.0, min(1.0, volume))
        print("BackgroundMusicPlayer: Volume set to \(volume)")
    }

    func play() { 
        if let player = audioPlayer, !player.isPlaying {
            player.play()
            isPlaying = true
            print("BackgroundMusicPlayer: Resumed playback.")
        } else {
            print("BackgroundMusicPlayer: Play called, but player not set up or already playing.")
        }
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        print("BackgroundMusicPlayer: Paused.")
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        print("BackgroundMusicPlayer: Stopped.")
    }
    
    func updatePlayback(userPreferences: UserPreferences) {
        if !userPreferences.enableBackgroundMusic {
            stop()
        } else {
            if let currentTrack = self.currentTrack {
                if !isPlaying {
                    playTrack(currentTrack, userPreferences: userPreferences)
                } else {
                    setVolume(userPreferences.backgroundMusicVolume)
                }
            } else if let firstTrack = BackgroundMusicTrack.allCases.first { 
                playTrack(firstTrack, userPreferences: userPreferences)
            }
        }
    }
}
