import Foundation
import AVFoundation
import Combine
import MediaPlayer

class MeditationPlayerViewModel: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var selectedBackgroundSound: BackgroundSound = .none
    @Published var isBackgroundSoundPlaying = false
    
    // Audio players
    private var backgroundPlayer: AVAudioPlayer?
    private var timer: AnyCancellable?
    private var totalDuration: TimeInterval = 0
    private var startTime: Date?
    private var mainMusicWasPlayingBeforeMeditation: Bool = false // Track if main music was paused by us
    
    // For background audio session
    private var audioSession = AVAudioSession.sharedInstance()
    private var backgroundPlayerURLs: [BackgroundSound: URL] = [:]
    
    // For remote control (lock screen controls)
    private var nowPlayingInfo = [String: Any]()
    
    var currentMeditation: MeditationOption?
    
    override init() {
        super.init()
        setupAudioSession()
        setupBackgroundSounds()
        setupRemoteTransportControls()
    }
    
    // MARK: - Setup
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupBackgroundSounds() {
        // Preload background sounds
        BackgroundSound.allCases.forEach { sound in
            if let fileName = sound.fileName,
               let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
                backgroundPlayerURLs[sound] = url
            }
        }
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resumeMeditation()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pauseMeditation()
            return .success
        }
        
        // Update now playing info
        updateNowPlayingInfo()
    }
    
    // MARK: - Public Methods
    func startMeditation(meditation: MeditationOption) {
        DispatchQueue.main.async {
            self.currentMeditation = meditation
        self.totalDuration = meditation.duration
        self.timeRemaining = meditation.duration
        self.startTime = Date()
        self.isPlaying = true

        // Pause main background music if it's playing and this meditation has its own sound
        if meditation.backgroundSound != .none && MeditationDataStore.shared.userPreferences.enableBackgroundSounds {
            // Assuming BackgroundMusicPlayer.shared has an 'isPlaying' property and 'pause' method
            // This is a placeholder for the actual check and call
            // if BackgroundMusicPlayer.shared.isPlaying && MeditationDataStore.shared.userPreferences.enableBackgroundMusic {
            //     BackgroundMusicPlayer.shared.pause()
            //     self.mainMusicWasPlayingBeforeMeditation = true
            // } else {
            //     self.mainMusicWasPlayingBeforeMeditation = false
            // }
            // For now, let's assume a direct call to a hypothetical method in BackgroundMusicPlayer
            // that handles this logic, or we refine this once BackgroundMusicPlayer is found.
            // For the purpose of this change, we'll add a conceptual placeholder call.
            // Actual implementation depends on BackgroundMusicPlayer's interface.
            if BackgroundMusicPlayer.shared.isPlaying && MeditationDataStore.shared.userPreferences.enableBackgroundMusic {
                 BackgroundMusicPlayer.shared.pause()
                 self.mainMusicWasPlayingBeforeMeditation = true
            } else {
                 self.mainMusicWasPlayingBeforeMeditation = false
            }
        }

        // Start background sound if enabled
        if MeditationDataStore.shared.userPreferences.enableBackgroundSounds {
            self.selectedBackgroundSound = meditation.backgroundSound
            self.playBackgroundSound()
        }
        
        // Start timer
            self.startTimer()
        
        // Update now playing info
        self.updateNowPlayingInfo()
        } // Closes DispatchQueue.main.async
    }
    
    func togglePlayPause() {
        if isPlaying {
            pauseMeditation()
        } else {
            resumeMeditation()
        }
    }
    
    func pauseMeditation() {
        isPlaying = false
        timer?.cancel()
        backgroundPlayer?.pause()
        updateNowPlayingInfo()
    }
    
    func resumeMeditation() {
        isPlaying = true
        
        // Resume background sound if needed
        if MeditationDataStore.shared.userPreferences.enableBackgroundSounds {
            playBackgroundSound()
        }
        
        // Resume timer
        startTimer()
        updateNowPlayingInfo()
    }
    
    func endMeditation(completed: Bool = true) {
        isPlaying = false
        timer?.cancel()
        stopBackgroundSound()
        
        // Save session if completed
        if completed, let meditation = currentMeditation, let startTime = startTime {
            let actualDuration = meditation.duration - timeRemaining
            MeditationDataStore.shared.completeMeditationSession(
                meditationId: meditation.id,
                duration: actualDuration
            )
        }
        
        // Reset player
        resetPlayer()

        // Resume main background music if it was paused by this meditation session
        if self.mainMusicWasPlayingBeforeMeditation && MeditationDataStore.shared.userPreferences.enableBackgroundMusic {
            // BackgroundMusicPlayer.shared.play() // Placeholder for actual call
            BackgroundMusicPlayer.shared.play()
        }
        self.mainMusicWasPlayingBeforeMeditation = false
    }
    
    func skipForward(seconds: TimeInterval) {
        timeRemaining = max(0, timeRemaining - seconds)
        progress = 1 - (timeRemaining / totalDuration)
        updateNowPlayingInfo()
    }
    
    func skipBackward(seconds: TimeInterval) {
        timeRemaining = min(totalDuration, timeRemaining + seconds)
        progress = 1 - (timeRemaining / totalDuration)
        updateNowPlayingInfo()
    }
    
    // MARK: - Private Methods
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            progress = 1 - (timeRemaining / totalDuration)
            updateNowPlayingInfo()
        } else {
            endMeditation(completed: true)
        }
    }
    
    internal func playBackgroundSound() {
        guard selectedBackgroundSound != .none,
              let url = backgroundPlayerURLs[selectedBackgroundSound] else {
            return
        }
        
        do {
            // Stop current sound if playing
            stopBackgroundSound()
            
            // Create and configure new player
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundPlayer?.volume = 0.3 // Lower volume for background
            backgroundPlayer?.prepareToPlay()
            backgroundPlayer?.play()
            
            isBackgroundSoundPlaying = true
        } catch {
            print("Couldn't play background sound: \(error)")
        }
    }
    
    func stopBackgroundSound() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
        isBackgroundSoundPlaying = false
    }
    
    private func resetPlayer() {
        timer?.cancel()
        stopBackgroundSound()
        currentMeditation = nil
        startTime = nil
        timeRemaining = 0
        progress = 0
        updateNowPlayingInfo(clear: true)
    }
    
    private func updateNowPlayingInfo(clear: Bool = false) {
        if clear {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        
        guard let meditation = currentMeditation else { return }
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = meditation.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Mindful Moments"
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Meditation"
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = totalDuration - timeRemaining
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = totalDuration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Set artwork
        if let image = UIImage(named: "AppIcon") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in
                return image
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Cleanup
    deinit {
        timer?.cancel()
        stopBackgroundSound()
    }
}
