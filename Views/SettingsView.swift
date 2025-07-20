//  SettingsView.swift
//  CalmMind – direkte Live‑Übernahme der Einstellungen
//  (Keine “Speichern”/“Abbrechen”‑Buttons mehr)
//
//  Änderungen in den Toggles, Pickern etc. werden sofort in
//  `MeditationDataStore.userPreferences` geschrieben, indem wir `draft`
//  per `.onChange` zurück in den Store spiegeln.
//
import SwiftUI
import UIKit

struct SettingsView: View {
    // MARK: – Environment
    @EnvironmentObject private var store: MeditationDataStore
    @Environment(\.openURL) private var openURL

    // MARK: – Draft (lokale Kopie)
    @State private var draft = UserPreferences()

    // Alerts
    @State private var showNotifAlert = false
    @State private var showResetAlert = false

    // MARK: – Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    musicSection
                    soundSection
                    generalSection
                    notificationSection
                    dataSection
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Einstellungen")
            // ---------- Alerts ----------
            .alert("Berechtigung erforderlich", isPresented: $showNotifAlert) {
                Button("Einstellungen öffnen") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Bitte aktiviere Mitteilungen in den Systemeinstellungen.")
            }
            .alert("Statistiken zurücksetzen?", isPresented: $showResetAlert) {
                Button("Zurücksetzen", role: .destructive) {
                    store.resetAllStatistics()
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Alle Fortschritte werden gelöscht. Fortfahren?")
            }
        }
        .onAppear { draft = store.userPreferences }
        // Jede Änderung sofort an den Store zurückgeben → live gespeichert
        .onChange(of: draft) { newPrefs in
            store.userPreferences = newPrefs
        }
    }

    // MARK: – Teil‑Blöcke ----------------------------------------------------

    private var musicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hintergrundmusik").font(.headline).foregroundColor(.turquoiseCalm)

            Toggle("Aktivieren", isOn: $draft.enableBackgroundMusic)
                .tint(.lavenderMist)

            Picker("Musikstück", selection: $draft.selectedBackgroundMusicTrack) {
                ForEach(BackgroundMusicTrack.allCases) { track in
                    Text(track.displayName).tag(track)
                }
            }
            .pickerStyle(.menu)

            HStack {
                Text("Lautstärke")
                Slider(value: $draft.backgroundMusicVolume, in: 0...1)
                Text("\(Int(draft.backgroundMusicVolume * 100)) %")
                    .frame(width: 50, alignment: .trailing)
            }
        }
    }

    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hintergrundgeräusche").font(.headline).foregroundColor(.turquoiseCalm)

            Toggle("Aktivieren", isOn: $draft.enableBackgroundSounds)
                .tint(.lavenderMist)

            Picker("Standardgeräusch", selection: $draft.defaultBackgroundSound) {
                ForEach(BackgroundSound.allCases) { sound in
                    Text(sound.displayName).tag(sound)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Allgemein").font(.headline).foregroundColor(.turquoiseCalm)

            Toggle("Haptisches Feedback", isOn: $draft.hapticFeedback)
                .tint(.lavenderMist)

            Stepper(value: $draft.defaultMeditationDuration, in: 60...3600, step: 60) {
                Text("Standard‑Dauer: \(draft.defaultMeditationDuration.formattedDuration)")
            }
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Benachrichtigungen").font(.headline).foregroundColor(.turquoiseCalm)

            Toggle("Tägliche Erinnerung", isOn: $draft.enableNotifications)
                .tint(.lavenderMist)
                .onChange(of: draft.enableNotifications) { _, enabled in
                    if enabled {
                        store.requestNotificationPermission { granted in
                            if !granted {
                                draft.enableNotifications = false
                                showNotifAlert = true
                            }
                        }
                    } else {
                        store.cancelDailyReminderNotifications()
                    }
                }

            if draft.enableNotifications {
                DatePicker("Erinnerungszeit", selection: $draft.dailyReminderTime, displayedComponents: .hourAndMinute)
            }
        }
    }

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Datenmanagement").font(.headline).foregroundColor(.turquoiseCalm)

            Button("Standardeinstellungen wiederherstellen") {
                draft.resetToDefaults()
            }
            Button("Alle Statistiken zurücksetzen", role: .destructive) {
                showResetAlert = true
            }
        }
    }

   
}

// MARK: – Preview
#Preview("Settings‑Preview") {
    SettingsView()
        .environmentObject(MeditationDataStore.shared)
}
