//
//  MindfulMomentsApp.swift
//  MindfulMoments
//
//  Created by Keno Göllner  on 09.06.25.
//

import SwiftUI

@main
struct MindfulMomentsApp: App {
    // Inject AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var playerViewModel = MeditationPlayerViewModel()
    @StateObject private var backgroundMusicPlayer = BackgroundMusicPlayer.shared // Ensure this is @StateObject if it publishes changes affecting the UI directly or needs to persist.
    @StateObject private var dataStore = MeditationDataStore.shared // Access the shared MeditationDataStore

    init() {
        // Customizing Navigation Bar Appearance for a magical look
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // Make it transparent to show custom backgrounds
        appearance.backgroundColor = .clear // Explicitly clear background
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.softWhite), .font: UIFont.systemFont(ofSize: 18, weight: .bold)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.softWhite), .font: UIFont.systemFont(ofSize: 34, weight: .bold)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance // For smaller nav bars
        UINavigationBar.appearance().tintColor = UIColor(Color.lavenderMist) // Tint color for back buttons etc.
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .environmentObject(playerViewModel)
                .environmentObject(backgroundMusicPlayer) // Pass the music player
                .preferredColorScheme(.dark) // Enforce dark scheme for the magical look
                .onAppear {
                    // Call a function to setup/reschedule notifications based on stored preferences
                    // This ensures that when the app starts, notifications are correctly scheduled.
                    MeditationDataStore.shared.scheduleInitialNotifications()
                }
        }
    }
}
