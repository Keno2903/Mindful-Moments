//
//  ContentView.swift
//  MindfulMoments
//
//  Created by Keno Göllner  on 09.06.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: MeditationDataStore
    @EnvironmentObject var backgroundMusicPlayer: BackgroundMusicPlayer // Corrected variable name
    @StateObject var playerViewModel = MeditationPlayerViewModel() // Central player view model

    init() {
        // Customize TabView appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Color.darkSlate.opacity(0.8)) // Semi-transparent dark background for tab bar
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.turquoiseCalm)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.turquoiseCalm)]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.lavenderMist.opacity(0.7))
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.lavenderMist.opacity(0.7))]

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        ZStack {
            MagicalBackground()
            TabView {
                NavigationView {
                    MeditationListView()
                }
                .tabItem {
                    Label("Meditieren", systemImage: "figure.mind.and.body")
                }
                .environmentObject(dataStore)
                .environmentObject(playerViewModel)

                NavigationView {
                    BreathingExerciseView()
                }
                .tabItem {
                    Label("Atmen", systemImage: "lungs.fill")
                }
                .environmentObject(dataStore)

                NavigationView {
                    StatisticsView()
                }
                .tabItem {
                    Label("Fortschritt", systemImage: "chart.bar.xaxis")
                }
                .environmentObject(dataStore)

                NavigationView {
                    SettingsView()
                }
                .tabItem {
                    Label("Einstellungen", systemImage: "gear")
                }
                .environmentObject(dataStore)
            }
            .accentColor(Color.turquoiseCalm) // Accent color for selected tab item
        }
        .onAppear {
            // Update playback based on current preferences when the view appears.
            // This will handle starting the music if enabled, or ensuring it's stopped if disabled.
            backgroundMusicPlayer.updatePlayback(userPreferences: dataStore.userPreferences)
        }
    }
}


// Preview for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

