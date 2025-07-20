// MindfulMoments/Views/StatCard.swift
import SwiftUI

struct StatCard: View {
    var title: String
    var value: String
    var iconName: String? // Optional icon
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.caption) // Smaller icon
                        .foregroundColor(color.opacity(0.8))
                }
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color.softWhite.opacity(0.7))
            }
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // Take available width
        .background(Color.darkSlate.opacity(0.5)) // Use a brand color for background
        .cornerRadius(10)
    }
}

struct StatCard_Previews: PreviewProvider {
    static var previews: some View {
        StatCard(title: "Sessions", value: "15", iconName: "figure.walk", color: .turquoiseCalm)
            .padding()
            .background(MagicalBackground())
    }
}
