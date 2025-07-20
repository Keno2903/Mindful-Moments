import Foundation
import SwiftUI

// MARK: - Enums
enum MeditationCategory: String, CaseIterable, Identifiable, Codable {
    case focus = "Konzentration"
    case sleep = "Schlaf"
    case anxiety = "Angstbewältigung"
    case morning = "Morgenroutine"
    case customS = "Benutzerdefiniert"
    
    var id: String { self.rawValue }
    var iconName: String {
        switch self {
        case .focus: return "brain.head.profile"
        case .sleep: return "moon.zzz.fill"
        case .anxiety: return "heart.circle"
        case .morning: return "sunrise.fill"
        case .customS: return "plus.circle"
        }
    }
}

enum BackgroundSound: String, CaseIterable, Identifiable, Codable {
    case none = "Keins"
    case rain = "Regen"
    case waves = "Meeresrauschen"
    case forest = "Wald"
    case whiteNoise = "Weißes Rauschen"
    
    var id: String { self.rawValue }
    var displayName: String { self.rawValue } // For Picker display
    var fileName: String? {
        self == .none ? nil : self.rawValue.lowercased()
    }
}

// Enum for different background music tracks
public enum BackgroundMusicTrack: String, CaseIterable, Codable, Identifiable {
    public var id: String { self.rawValue }

    case peacefulPiano = "Friedliches Klavier"
    case ambientGuitar = "Ambient Gitarre"
    case singingBowl = "Klangschalen"

    var fileName: String {
        switch self {
            case .peacefulPiano: return "peaceful_piano.mp3" // Ensure these filenames match your assets
            case .ambientGuitar: return "ambient_guitar.mp3"
            case .singingBowl: return "singing_bowl.mp3"
        }
    }

    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Models
struct MeditationOption: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var duration: TimeInterval
    var description: String
    var category: MeditationCategory
    var backgroundSound: BackgroundSound
    var isFavorite: Bool
    var creationDate: Date
    var lastUsed: Date?
    
    // For progress tracking
    var completedSessions: Int = 0
    var totalMeditationTime: TimeInterval = 0
    
    // Default initializer
    init(id: UUID = UUID(),
         title: String,
         duration: TimeInterval,
         description: String,
         category: MeditationCategory,
         backgroundSound: BackgroundSound = .none,
         isFavorite: Bool = false,
         creationDate: Date = Date(),
         lastUsed: Date? = nil) {
        self.id = id
        self.title = title
        self.duration = duration
        self.description = description
        self.category = category
        self.backgroundSound = backgroundSound
        self.isFavorite = isFavorite
        self.creationDate = creationDate
        self.lastUsed = lastUsed
    }
    
    // Default meditation options
    static var defaultOptions: [MeditationOption] = [
        MeditationOption(title: "Morgenfrische",
                         duration: 300,
                         description: "Starte klar und energiegeladen in den Tag.",
                         category: .morning, // War .achtsamkeit, zu .morning geändert
                         backgroundSound: .forest),
        MeditationOption(title: "Stressabbau Express",
                         duration: 180,
                         description: "Finde schnelle Entspannung in stressigen Momenten.",
                         category: .anxiety, // War .stressabbau, zu .anxiety geändert
                         backgroundSound: .rain),
        MeditationOption(title: "Tiefer Schlaf",
                         duration: 900,
                         description: "Gleite sanft in eine erholsame Nachtruhe.",
                         category: .sleep,
                         backgroundSound: .waves),
        MeditationOption(title: "Fokus & Konzentration",
                         duration: 600,
                         description: "Schärfe deinen Geist für anstehende Aufgaben.",
                         category: .focus, // War .konzentration, passt zu .focus
                         backgroundSound: .none),
        MeditationOption(title: "Dankbarkeitsmoment", // Könnte .customS oder .morning sein
                         duration: 240,
                         description: "Kultiviere Dankbarkeit für mehr Lebensfreude.",
                         category: .customS, // War .achtsamkeit, zu .customS als Platzhalter
                         backgroundSound: .forest),
        MeditationOption(title: "Innere Ruhe finden",
                         duration: 480,
                         description: "Eine kurze Auszeit, um zur inneren Mitte zu gelangen.",
                         category: .anxiety, // War .stressabbau, passt zu .anxiety
                         backgroundSound: .rain),
        MeditationOption(title: "Kreativitätsboost", // Könnte .customS oder .focus sein
                         duration: 720,
                         description: "Öffne deinen Geist für neue Ideen und Inspiration.",
                         category: .customS, // War .persönlichkeitsentwicklung, zu .customS
                         backgroundSound: .waves),
        MeditationOption(title: "Loslassen lernen", // Könnte .customS oder .anxiety sein
                         duration: 540,
                         description: "Befreie dich von belastenden Gedanken und Gefühlen.",
                         category: .customS, // War .selbstmitgefühl, zu .customS
                         backgroundSound: .none),
        MeditationOption(title: "Energie tanken",
                         duration: 360,
                         description: "Lade deine Batterien mit positiver Energie wieder auf.",
                         category: .focus, // War .konzentration, passt zu .focus
                         backgroundSound: .forest),
        MeditationOption(title: "Abendentspannung",
                         duration: 600,
                         description: "Lass den Tag sanft ausklingen und bereite dich auf die Nacht vor.",
                         category: .sleep,
                         backgroundSound: .rain),
        MeditationOption(
            title: "Morgendliche Ruhe",
            duration: 300,
            description: "Starte entspannt in den Tag",
            category: .morning,
            backgroundSound: .none
        ),
        MeditationOption(
            title: "Tiefenentspannung",
            duration: 600,
            description: "Lass den Stress des Tages hinter dir",
            category: .sleep,
            backgroundSound: .rain
        ),
        MeditationOption(
            title: "Fokus verbessern",
            duration: 480,
            description: "Steigere deine Konzentrationsfähigkeit",
            category: .focus,
            backgroundSound: .none
        ),
        MeditationOption(title: "Sonnenaufgangsmeditation",
                         duration: 420,
                         description: "Beginne den Tag mit neuer Energie und Klarheit.",
                         category: .morning,
                         backgroundSound: .forest),
        MeditationOption(title: "Gelassen durch den Tag",
                         duration: 600,
                         description: "Finde innere Ruhe für stressige Situationen.",
                         category: .anxiety,
                         backgroundSound: .rain),
        MeditationOption(title: "Atemfokus",
                         duration: 300,
                         description: "Komme durch bewusstes Atmen im Moment an.",
                         category: .focus,
                         backgroundSound: .waves),
        MeditationOption(title: "Selbstmitgefühl stärken",
                         duration: 540,
                         description: "Begegne dir selbst mit Freundlichkeit.",
                         category: .customS,
                         backgroundSound: .none),
        MeditationOption(title: "Abendliche Dankbarkeit",
                         duration: 360,
                         description: "Reflektiere, wofür du heute dankbar bist.",
                         category: .customS,
                         backgroundSound: .forest),
        MeditationOption(title: "Mentale Klarheit",
                         duration: 480,
                         description: "Sortiere deine Gedanken für mehr Fokus.",
                         category: .focus,
                         backgroundSound: .rain),
        MeditationOption(title: "Kurze Pause",
                         duration: 180,
                         description: "Entspanne dich in wenigen Minuten.",
                         category: .anxiety,
                         backgroundSound: .none),
        MeditationOption(title: "Körperreise",
                         duration: 900,
                         description: "Spüre und entspanne deinen gesamten Körper.",
                         category: .sleep,
                         backgroundSound: .waves),
        MeditationOption(title: "Positive Affirmationen",
                         duration: 300,
                         description: "Stärke dein Selbstvertrauen mit positiven Gedanken.",
                         category: .customS,
                         backgroundSound: .forest),
        MeditationOption(title: "Loslassen am Abend",
                         duration: 600,
                         description: "Lass den Tag los und finde Ruhe.",
                         category: .sleep,
                         backgroundSound: .rain),
        MeditationOption(title: "Kreative Pause",
                         duration: 420,
                         description: "Fördere deine Kreativität durch Entspannung.",
                         category: .customS,
                         backgroundSound: .waves),
        MeditationOption(title: "Selbstbewusstsein stärken",
                         duration: 480,
                         description: "Fühle dich stark und selbstsicher.",
                         category: .customS,
                         backgroundSound: .none),
        MeditationOption(title: "Ruhe in der Natur",
                         duration: 600,
                         description: "Entspanne mit beruhigenden Naturklängen.",
                         category: .morning,
                         backgroundSound: .forest),
        MeditationOption(title: "Achtsam essen",
                         duration: 300,
                         description: "Genieße dein Essen bewusst und achtsam.",
                         category: .customS,
                         backgroundSound: .none)
    ]
}

// MARK: - User Data
struct UserData: Codable {
    var meditationHistory: [MeditationSession] = []
    var achievements: [Achievement] = []
    var dailyGoal: TimeInterval = 600 // 10 minutes in seconds
    var streak: Int = 0
    var preferences: UserPreferences = UserPreferences()
    var totalMindfulTime: TimeInterval = 0 // Tracks total time for meditations and breathing exercises
    var longestStreak: Int = 0
    var lastMeditationDate: Date? = nil
    var meditationCount: [UUID: Int] = [:] // Tracks count for each meditation ID
}

struct MeditationSession: Identifiable, Codable {
    let id: UUID
    let meditationId: UUID
    let startTime: Date
    let duration: TimeInterval
    let completed: Bool
}

struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let imageName: String
    var isUnlocked: Bool
    let dateUnlocked: Date?
}

// MARK: - User Preferences
struct UserPreferences: Codable, Equatable {
    var enableNotifications: Bool = true
    var dailyReminderTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    var preferredTheme: AppTheme = .system
    var hapticFeedback: Bool = true
    var enableBackgroundSounds: Bool = true
    var defaultBackgroundSound: BackgroundSound = .none // Default ambient sound for meditations
    var defaultMeditationDuration: TimeInterval = 300 // 5 minutes
    var autoStartBreathingExercise: Bool = false // New preference

    // Background Music Preferences
    var enableBackgroundMusic: Bool = true
    var selectedBackgroundMusicTrack: BackgroundMusicTrack = .peacefulPiano // Default track
    var backgroundMusicVolume: Float = 0.5 // Default volume (0.0 to 1.0)

    // Method to reset preferences to default values
    mutating func resetToDefaults() {
        self = UserPreferences() // Re-initialize with default values
    }
}

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case light = "Hell"
    case dark = "Dunkel"
    case system = "System"
    
    var id: String { self.rawValue }
}
