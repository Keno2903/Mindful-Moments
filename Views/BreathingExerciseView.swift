import SwiftUI

struct BreathingExerciseView: View {
    @EnvironmentObject var dataStore: MeditationDataStore
    @Environment(\.dismiss) var dismiss
    
    // Animation states
    @State private var scale: CGFloat = 1.0
    @State private var instruction: String = "Einatmen"
    @State private var isAnimating = false
    @State private var breathsRemaining: Int = 10 // Example: 10 breath cycles
    
    // Timing for breath cycle (in seconds)
    let inhaleDuration: Double = 4.0
    let holdAfterInhaleDuration: Double = 1.0 // Optional hold
    let exhaleDuration: Double = 6.0
    let holdAfterExhaleDuration: Double = 1.0 // Optional hold
    
    private var cycleDuration: Double {
        inhaleDuration + holdAfterInhaleDuration + exhaleDuration + holdAfterExhaleDuration
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.teal.opacity(0.7), Color.cyan.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                HStack {
                    Spacer()
                    Button {
                        stopExercise()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding([.top, .trailing])
                
                Text("Atemübung")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 100, height: 100)
                        .scaleEffect(scale)
                }
                
                Text(instruction)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                
                Text("Verbleibende Zyklen: \(breathsRemaining)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Button(action: {
                    if isAnimating {
                        stopExercise()
                    } else {
                        startExercise()
                    }
                }) {
                    Text(isAnimating ? "Pause" : (breathsRemaining == 0 ? "Neustart" : "Start"))
                        .font(.headline)
                        .foregroundColor(.teal)
                        .padding()
                        .frame(minWidth: 150)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                
                Spacer()
            }
        }
        .onAppear {
            if dataStore.userPreferences.autoStartBreathingExercise {
                startExercise()
            }
        }
        .onDisappear {
            stopExercise() // Ensure animation stops if view disappears
        }
    }
    
    func startExercise() {
        guard !isAnimating else { return }
        if breathsRemaining == 0 { // Reset if finished
            breathsRemaining = 10
        }
        isAnimating = true
        animateBreathCycle()
    }
    
    func stopExercise() {
        isAnimating = false
        // Reset animation properties to initial state
        withAnimation(.spring()) {
            scale = 1.0
        }
        instruction = "Einatmen"
        // Potentially cancel any ongoing timers/DispatchWorkItems if more complex logic is used
    }
    
    func animateBreathCycle() {
        guard isAnimating && breathsRemaining > 0 else {
            if breathsRemaining == 0 {
                instruction = "Abgeschlossen!"
                isAnimating = false
            }
            return
        }
        
        // Inhale
        instruction = "Einatmen"
        withAnimation(.easeInOut(duration: inhaleDuration)) {
            scale = 1.5
        }
        
        // Hold after inhale
        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration) {
            guard isAnimating else { return }
            instruction = "Halten"
            // Scale remains 1.5
        }
        
        // Exhale
        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration + holdAfterInhaleDuration) {
            guard isAnimating else { return }
            instruction = "Ausatmen"
            withAnimation(.easeInOut(duration: exhaleDuration)) {
                scale = 0.75
            }
        }
        
        // Hold after exhale
        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration + holdAfterInhaleDuration + exhaleDuration) {
            guard isAnimating else { return }
            instruction = "Halten"
            // Scale remains 0.75
        }
        
        // Next cycle
        DispatchQueue.main.asyncAfter(deadline: .now() + cycleDuration) {
            guard isAnimating else { return }
            breathsRemaining -= 1
            if breathsRemaining > 0 {
                animateBreathCycle() // Loop
            } else {
                instruction = "Sehr gut! Übung beendet."
                withAnimation(.spring()) {
                    scale = 1.0
                }
                isAnimating = false
                // Log completion
                dataStore.logBreathingSession(duration: cycleDuration * Double(10 - breathsRemaining))
            }
        }
    }
}

// MARK: - Preview
struct BreathingExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingExerciseView()
            .environmentObject(MeditationDataStore.shared)
    }
}
