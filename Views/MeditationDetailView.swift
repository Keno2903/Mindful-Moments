import SwiftUI

struct MeditationDetailView: View {
    @EnvironmentObject var dataStore: MeditationDataStore
    @EnvironmentObject var playerViewModel: MeditationPlayerViewModel // Use shared instance from environment
    @Environment(\.dismiss) var dismiss
    
    @State var meditation: MeditationOption // Use @State if we modify it directly for editing, or pass as let
    
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    private var isCurrentMeditationPlaying: Bool {
        playerViewModel.currentMeditation?.id == meditation.id && playerViewModel.isPlaying
    }
    
    var body: some View {
        ZStack {
            MagicalBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                // New Header Section with Icon/Logo and Title
                VStack {
                    Image(systemName: meditation.category.iconName) // TODO: Replace with your AppLogo: Image("YourLogoName") if you add it to assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color.turquoiseCalm.opacity(0.8))
                        .padding(10)
                        .background(Color.darkSlate.opacity(0.5))
                        .clipShape(Circle())
                        .shadow(color: Color.turquoiseCalm.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.top, 20)

                    Text(meditation.title)
                        .font(.largeTitle).bold()
                        .foregroundColor(Color.softWhite)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)

                // Description Section
                if !meditation.description.isEmpty {
                    Text("Beschreibung")
                        .font(.title2).bold()
                        .foregroundColor(Color.softWhite)
                        .padding(.top)
                    Text(meditation.description)
                        .font(.body)
                        .foregroundColor(Color.lavenderMist)
                }

                // Statistics Section
               /* Text("Statistiken")
                    .font(.title2).bold()
                    .foregroundColor(Color.softWhite)
                    .padding(.top)
                HStack(spacing: 15) {
                    StatCard(title: "Sessions", value: "\(meditation.completedSessions)", iconName: "figure.walk", color: Color.turquoiseCalm)
                    StatCard(title: "Gesamtzeit", value: $meditation.totalTimeMeditated.formattedDuration, iconName: "clock.fill", color: Color.lavenderMist)
                    StatCard(title: "Zuletzt", value: meditation.lastMeditatedDate?.formattedRelatively() ?? "Nie", iconName: "calendar", color: Color.turquoiseCalm.opacity(0.8))
                
                }*/
                // Removed padding here, parent VStack has it

                Spacer() // Pushes the button to the bottom if content is short
                playButton // Already moved and styled
                    // .padding(.horizontal) // Parent VStack has padding
                    .padding(.bottom, 10) // Adjusted bottom padding

                }
                .padding(.horizontal) // Add horizontal padding to the VStack content
            }
        }
        // .background(Color.softWhite.edgesIgnoringSafeArea(.all)) // Removed, as ZStack with MagicalBackground handles it.
        .navigationTitle(meditation.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                actionsMenu
            }
        }
        .sheet(isPresented: $showingEditView) {
            NavigationView {
                AddMeditationView(meditationToEdit: meditation)
                    .environmentObject(dataStore)
            }
        }
        .alert("Meditation löschen?", isPresented: $showingDeleteAlert) {
            Button("Abbrechen", role: .cancel) {}
            Button("Löschen", role: .destructive) { deleteMeditation() }
        } message: {
            Text("Möchtest du '\(meditation.title)' wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
        }
        .fullScreenCover(isPresented: $playerViewModel.isPlaying) {
            if let currentMed = playerViewModel.currentMeditation {
                 MeditationPlayerView(meditation: currentMed)
                    .environmentObject(playerViewModel)
                    .environmentObject(dataStore)
            }
        }
        .onReceive(dataStore.$meditationOptions) { updatedOptions in
            // Update local meditation copy if it changed in the store (e.g., after edit)
            if let updatedMeditation = updatedOptions.first(where: { $0.id == meditation.id }) {
                self.meditation = updatedMeditation
            }
        }
    }
    
    // MARK: - Subviews
    
    
    
    
    private var playButton: some View {
        Button {
            // Ensure currentMeditation is set before attempting to play
            // This might be redundant if startMeditation handles it, but good for safety
            if playerViewModel.currentMeditation == nil {
                playerViewModel.currentMeditation = meditation
            }

            playerViewModel.startMeditation(meditation: meditation)
        } label: {
            Label("Meditation starten", systemImage: "play.fill")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.turquoiseCalm.gradient) // Use branding color
                .cornerRadius(12)
                .shadow(color: Color.turquoiseCalm.opacity(0.5), radius: 8, x: 0, y: 4) // Enhanced shadow
        }
        .padding(.horizontal) // Ensure button has horizontal padding if VStack doesn't provide enough
    }
    
    private var actionsMenu: some View {
        Menu {
            Button {
                var updatedMeditation = meditation
                updatedMeditation.isFavorite.toggle()
                dataStore.updateMeditation(updatedMeditation)
            } label: {
                Label(meditation.isFavorite ? "Von Favoriten entfernen" : "Zu Favoriten", systemImage: meditation.isFavorite ? "heart.slash.fill" : "heart.fill")
            }
            
            Button {
                showingEditView = true
            } label: {
                Label("Bearbeiten", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Löschen", systemImage: "trash.fill")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
        }
    }
    
    // MARK: - Actions
    private func deleteMeditation() {
        dataStore.deleteMeditation(at: IndexSet(integer: dataStore.meditationOptions.firstIndex(where: { $0.id == meditation.id }) ?? 0))
        dismiss()
    }
}

// MARK: - Subviews for DetailView
struct StatCapsule: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Preview
struct MeditationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MeditationDetailView(meditation: MeditationOption.defaultOptions.first!)
                .environmentObject(MeditationDataStore.shared)
        }
    }
}

// MARK: - Extensions for formatting (Consider moving to a Utils file)
extension TimeInterval {
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: self) ?? "0s"
    }
    
    var formattedTotalTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .brief
        return formatter.string(from: self) ?? "0m"
    }
}

extension Date {
    var formattedRelative: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
