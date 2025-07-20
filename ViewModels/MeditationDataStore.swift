import Foundation
import Combine
import UserNotifications
import UIKit

class MeditationDataStore: ObservableObject {
    static let shared = MeditationDataStore()
    
    @Published var meditationOptions: [MeditationOption] = []
    @Published var userData = UserData()
    @Published var userPreferences = UserPreferences() {
        didSet {
            savePreferences() // Save to UserDefaults whenever preferences change
            // After saving, re-evaluate notification scheduling
            if userPreferences.enableNotifications {
                requestNotificationPermission { granted in // Ensure we still have permission
                    if granted {
                        self.scheduleDailyReminderNotification()
                    } else {
                        // If permission was revoked, reflect this in the preferences
                        // This might be redundant if SettingsView already handles it, but good for robustness
                        DispatchQueue.main.async { // Ensure UI updates on main thread if any
                            if self.userPreferences.enableNotifications { // Check to avoid loop if already false
                                self.userPreferences.enableNotifications = false
                                // No need to call savePreferences() again due to didSet loop,
                                // but direct UserDefaults update might be safer if not for @Published complexity
                            }
                        }
                    }
                }
            } else {
                cancelDailyReminderNotifications()
            }

            // --- Background Music Logic based on preference changes ---
            // The BackgroundMusicPlayer's updatePlayback method now handles all logic
            // related to track changes, volume changes, and enabling/disabling music.
            BackgroundMusicPlayer.shared.updatePlayback(userPreferences: userPreferences)
            // --- End of Background Music Logic ---
        }
    }
    
    private let meditationsKey = "savedMeditations"
    private let userDataKey = "userMeditationData"
    private let preferencesKey = "userPreferences"
    
    private init() {
        loadAllData()
        setupNotificationObserver()
    }
    
    // MARK: - Data Management
    private func loadAllData() {
        loadMeditations()
        loadUserData()
        loadPreferences()
    }
    
    private func loadMeditations() {
        if let data = UserDefaults.standard.data(forKey: meditationsKey),
           let decoded = try? JSONDecoder().decode([MeditationOption].self, from: data) {
            meditationOptions = decoded
        } else {
            meditationOptions = MeditationOption.defaultOptions
        }
    }
    
    private func loadUserData() {
        if let data = UserDefaults.standard.data(forKey: userDataKey),
           let decoded = try? JSONDecoder().decode(UserData.self, from: data) {
            userData = decoded
        }
    }
    
    private func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            userPreferences = decoded
        }
    }
    
    private func saveMeditations() {
        if let encoded = try? JSONEncoder().encode(meditationOptions) {
            UserDefaults.standard.set(encoded, forKey: meditationsKey)
        }
    }
    
    private func saveUserData() {
        if let encoded = try? JSONEncoder().encode(userData) {
            UserDefaults.standard.set(encoded, forKey: userDataKey)
        }
    }
    
    private func savePreferences() {
        if let encoded = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }
    
    // MARK: - Public Methods
    func addMeditation(_ meditation: MeditationOption) {
        var newMeditation = meditation
        newMeditation.creationDate = Date()
        meditationOptions.append(newMeditation)
        saveMeditations()
    }
    
    func updateMeditation(_ meditation: MeditationOption) {
        if let index = meditationOptions.firstIndex(where: { $0.id == meditation.id }) {
            meditationOptions[index] = meditation
            saveMeditations()
        }
    }
    
    func deleteMeditation(at offsets: IndexSet) {
        meditationOptions.remove(atOffsets: offsets)
        saveMeditations()
    }
    
    func completeMeditationSession(meditationId: UUID, duration: TimeInterval) {
        // Update meditation stats
        if let index = meditationOptions.firstIndex(where: { $0.id == meditationId }) {
            meditationOptions[index].completedSessions += 1
            meditationOptions[index].totalMeditationTime += duration
            meditationOptions[index].lastUsed = Date()
        }
        
        // Update user data
        let session = MeditationSession(
            id: UUID(),
            meditationId: meditationId,
            startTime: Date().addingTimeInterval(-duration),
            duration: duration,
            completed: true
        )
        
        userData.meditationHistory.append(session)
        
        // Update streak
        updateStreak()
        
        // Check achievements
        checkAchievements()
        
        // Save all data
        saveAllData()
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = userData.lastMeditationDate {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            let lastMeditationDay = calendar.startOfDay(for: lastDate)
            
            if calendar.isDate(lastMeditationDay, inSameDayAs: today) {
                // Already meditated today, do nothing
                return
            } else if calendar.isDate(lastMeditationDay, inSameDayAs: yesterday) {
                // Meditated yesterday, increment streak
                userData.streak += 1
            } else {
                // Broken streak, reset to 1
                userData.streak = 1
            }
        } else {
            // First meditation
            userData.streak = 1
        }
        
        userData.lastMeditationDate = today
    }
    
    // MARK: - Achievements Logic (Placeholder)
    private func checkAchievements() {
        // Implement achievement logic here
        // Example: Check for 7-day streak, total minutes meditated, etc.
        // This might involve checking against userData.meditationHistory, userData.totalMeditationTime, userData.streak etc.
        // And then updating userData.achievements array.
        // e.g., if !userData.achievements.contains(where: { $0.id == "first_meditation" }) && userData.meditationHistory.count >= 1 { ... }
        saveUserData() // Save if achievements were updated
    }

    // MARK: - Breathing Exercises
    func logBreathingSession(duration: TimeInterval) {
        // For now, just add to total mindful time. Could be tracked separately later.
        userData.totalMindfulTime += duration // Assuming UserData has totalMindfulTime
        // Potentially update streaks or achievements related to breathing exercises
        // updateStreak(activityType: .breathing) // If we differentiate streaks
        checkAchievements() // Check if this session unlocked any achievements
        saveUserData()
        print("Breathing session of \(duration.formattedDuration) logged.")
    }

    // MARK: - User Data Statistics Management
    func incrementMeditationCount(for meditation: MeditationOption) {
        userData.meditationCount[meditation.id, default: 0] += 1
        userData.totalMindfulTime += meditation.duration
        // Potentially update lastMeditatedDate or other stats
        saveUserData()
    }

    // Method to reset all user statistics
    func resetAllStatistics() {
        userData = UserData() // This re-initializes UserData to its default state
        // If UserData has specific reset logic, call that instead or in addition.
        // For example: userData.resetStats()
        saveUserData() // Persist the reset data
        // Optionally, notify observers if needed, though @Published should handle UI updates.
        print("All user statistics have been reset.")
    }

    // MARK: - Notifications
    func scheduleInitialNotifications() {
        // Called when the app starts
        // Ensure preferences are loaded before this is called, which they are in init()
        if userPreferences.enableNotifications {
            requestNotificationPermission { granted in
                if granted {
                    self.scheduleDailyReminderNotification()
                }
            }
        } else {
            cancelDailyReminderNotifications() // Ensure no notifications if disabled
        }
    }

    func requestNotificationPermission(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
                if !granted {
                    // Update preferences if permission was denied after being enabled
                    // self.userPreferences.enableNotifications = false
                    // self.savePreferences()
                }
                completion?(granted)
            }
        }
    }

    func scheduleDailyReminderNotification() {
        guard userPreferences.enableNotifications else {
            cancelDailyReminderNotifications() // Cancel if called when notifications are globally off
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                // Optionally, re-request or guide user to settings if status is not authorized
                // For now, we just don't schedule if not authorized.
                print("Notification permission not granted. Cannot schedule reminder.")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Zeit für deine tägliche Achtsamkeit!"
            content.body = "Nimm dir einen Moment für dich mit Mindful Moments."
            content.sound = .default
            // content.badge = 1 // Optional: Set badge number
            
            var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: self.userPreferences.dailyReminderTime)
            dateComponents.second = 0 // Ensure it's at the start of the minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "MindfulMomentsDailyReminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error scheduling daily reminder: \(error.localizedDescription)")
                    } else {
                        print("Daily reminder scheduled successfully for \(self.userPreferences.dailyReminderTime.formatted(date: .omitted, time: .shortened))")
                    }
                }
            }
        }
    }

    func cancelDailyReminderNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["MindfulMomentsDailyReminder"])
        print("Cancelled all pending daily reminders.")
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveAllData),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func saveAllData() {
        saveMeditations()
        saveUserData()
        savePreferences()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
