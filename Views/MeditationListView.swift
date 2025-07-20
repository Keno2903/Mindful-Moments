import SwiftUI

struct MeditationListView: View {
    @EnvironmentObject var dataStore: MeditationDataStore
    @EnvironmentObject var playerViewModel: MeditationPlayerViewModel
    @State private var showingAddMeditationView = false
    @State private var selectedMeditation: MeditationOption?
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.darkSlate
                    .ignoresSafeArea()
                    .allowsHitTesting(false) // Don't block touches
                
                // Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Deine Meditationen")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.softWhite)
                                .padding(.horizontal)
                            Spacer()
                            Button(action: { showingAddMeditationView = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.turquoiseCalm)
                            }
                            .padding(.trailing)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                        
                        // Meditation Grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredMeditations) { meditation in
                                NavigationLink(destination:
                                    MeditationDetailView(meditation: meditation)
                                        .environmentObject(dataStore)
                                        .environmentObject(playerViewModel)
                                ) {
                                    MeditationCard(meditation: meditation)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddMeditationView) {
                AddMeditationView()
                    .environmentObject(dataStore)
                    .environmentObject(playerViewModel)
            }
        }
    }
    
    // MARK: - Card View
    private struct MeditationCard: View {
        let meditation: MeditationOption
        @State private var isPressed = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.turquoiseCalm.opacity(0.3), .lavenderMist.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: meditation.category.iconName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.turquoiseCalm)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Title
                Text(meditation.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.softWhite)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // Duration & Category
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.lavenderMist.opacity(0.8))
                        Text(meditation.duration.formattedDuration)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.lavenderMist.opacity(0.9))
                    }
                    
                    Text(meditation.category.rawValue)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            Capsule()
                                .fill(Color.lavenderMist.opacity(0.15))
                        )
                        .foregroundColor(.lavenderMist)
                }
            }
            .padding(16)
            .frame(height: 180)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.darkSlate)
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [
                                    .turquoiseCalm.opacity(0.4),
                                    .lavenderMist.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .onLongPressGesture(
                minimumDuration: .infinity,
                maximumDistance: .greatestFiniteMagnitude,
                pressing: { pressing in
                    withAnimation(.spring()) {
                        isPressed = pressing
                    }
                },
                perform: {}
            )
        }
    }
    
    // MARK: - Data
    private var filteredMeditations: [MeditationOption] {
        MeditationOption.defaultOptions
    }
}

// MARK: - Preview
struct MeditationListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ZStack {
                MagicalBackground()
                MeditationListView()
            }
            .environmentObject(MeditationDataStore.shared)
            .environmentObject(MeditationPlayerViewModel())
        }
    }
}


