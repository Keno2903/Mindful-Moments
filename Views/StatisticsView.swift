import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var dataStore: MeditationDataStore
    
    private var userData: UserData {
        dataStore.userData
    }
    
    private var totalMeditations: Int {
        dataStore.userData.meditationHistory.count
    }
    
    private var totalMeditationTime: TimeInterval {
        dataStore.userData.totalMindfulTime
    }
    
    private var currentStreak: Int {
        dataStore.userData.streak
    }
    
    private var longestStreak: Int {
        dataStore.userData.longestStreak
    }
    
    private var achievements: [Achievement] {
        userData.achievements
    }
    
    let gridLayout: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Dein Fortschritt")
                        .font(.largeTitle.weight(.bold))
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: gridLayout, spacing: 20) {
                        StatisticCard(icon: "figure.mind.and.body", title: "Gesamtzeit", value: totalMeditationTime.formattedTotalTime, color: .blue)
                        StatisticCard(icon: "number.circle.fill", title: "Sessions", value: "\(totalMeditations)", color: .green)
                        StatisticCard(icon: "flame.fill", title: "Aktueller Streak", value: "\(currentStreak) Tage", color: .orange)
                        StatisticCard(icon: "star.fill", title: "Längster Streak", value: "\(longestStreak) Tage", color: .purple)
                    }
                    .padding(.horizontal)
                    
                    if !achievements.isEmpty {
                        SectionView(title: "Erfolge") {
                            ForEach(achievements) { achievement in
                                AchievementRow(achievement: achievement)
                            }
                        }
                    } else {
                        Text("Noch keine Erfolge freigeschaltet. Meditiere weiter!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    // Placeholder for a chart - could be added later
                    SectionView(title: "Aktivität (Demnächst)") {
                        VStack {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.largeTitle)
                                .foregroundColor(.gray.opacity(0.5))
                                .padding()
                            Text("Eine detaillierte Ansicht deiner Meditationsaktivität wird hier bald verfügbar sein.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.bottom))
            .navigationTitle("Statistiken")
        }
    }
}

// MARK: - Subviews for StatisticsView
struct StatisticCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            Image(systemName: achievement.isUnlocked ? "rosette" : "lock.fill")
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if achievement.isUnlocked {
                Text(achievement.dateUnlocked?.formattedRelative ?? "")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.weight(.semibold))
                .padding(.horizontal)
            content
        }
        .padding(.bottom)
    }
}

// MARK: - Preview
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        let dataStore = MeditationDataStore.shared
        // Populate with some sample data for preview
        dataStore.userData.meditationHistory.append(MeditationSession(id: UUID(), meditationId: UUID(), startTime: Date(), duration: 300, completed: true))
        dataStore.userData.meditationHistory.append(MeditationSession(id: UUID(), meditationId: UUID(), startTime: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, duration: 600, completed: true))
        dataStore.userData.achievements.append(Achievement(id: UUID(), title: "Erste Meditation", description: "Du hast deine erste Meditation abgeschlossen!", imageName: "star.fill", isUnlocked: true, dateUnlocked: Date()))
        dataStore.userData.achievements.append(Achievement(id: UUID(), title: "3-Tage-Streak", description: "Drei Tage in Folge meditiert.", imageName: "flame.fill", isUnlocked: false, dateUnlocked: nil))
        
        return StatisticsView()
            .environmentObject(dataStore)
    }
}
