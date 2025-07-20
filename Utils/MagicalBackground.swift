import SwiftUI

struct MagicalBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.darkSlate, Color.darkSlate.opacity(0.7), Color.lavenderMist.opacity(0.4)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct MagicalBackground_Previews: PreviewProvider {
    static var previews: some View {
        MagicalBackground()
    }
}
