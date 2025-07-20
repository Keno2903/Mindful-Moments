import SwiftUI

struct AddMeditationView: View {
    @EnvironmentObject var dataStore: MeditationDataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var duration: TimeInterval
    @State private var category: MeditationCategory
    @State private var backgroundSound: BackgroundSound
    
    var meditationToEdit: MeditationOption? // Pass this if editing an existing meditation
    
    init(meditationToEdit: MeditationOption? = nil) {
        self.meditationToEdit = meditationToEdit
        _title = State(initialValue: meditationToEdit?.title ?? "")
        _description = State(initialValue: meditationToEdit?.description ?? "")
        _duration = State(initialValue: meditationToEdit?.duration ?? 300) // Default 5 minutes
        _category = State(initialValue: meditationToEdit?.category ?? .customS)
        _backgroundSound = State(initialValue: meditationToEdit?.backgroundSound ?? .none)
    }
    
    private var isEditingMode: Bool {
        meditationToEdit != nil
    }
    
    private var navTitle: String {
        isEditingMode ? "Meditation bearbeiten" : "Neue Meditation"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Grundlegende Informationen")) {
                    TextField("Titel", text: $title)
                    
                    VStack(alignment: .leading) {
                        Text("Beschreibung (optional)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextEditor(text: $description)
                            .frame(height: 100)
                    }
                }
                
                Section(header: Text("Einstellungen")) {
                    // Duration Picker
                    VStack(alignment: .leading) {
                        Text("Dauer: \(duration.formattedDuration)")
                        Slider(value: $duration, in: 60...3600, step: 60) // 1 min to 1 hour, steps of 1 min
                    }
                    
                    Picker("Kategorie", selection: $category) {
                        ForEach(MeditationCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    
                    Picker("Hintergrundgeräusch", selection: $backgroundSound) {
                        ForEach(BackgroundSound.allCases) { sound in
                            Text(sound.rawValue).tag(sound)
                        }
                    }
                }
                
                Section {
                    Button(action: saveMeditation) {
                        Text(isEditingMode ? "Änderungen speichern" : "Meditation erstellen")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(title.isEmpty)
                }
                
                if isEditingMode {
                    Section {
                        Button(role: .destructive, action: { dismiss() }) {
                            Text("Abbrechen")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !isEditingMode { // Show cancel only when adding new, not editing from detail view sheet
                        Button("Abbrechen") {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveMeditation()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveMeditation() {
        let newOrUpdatedMeditation = MeditationOption(
            id: meditationToEdit?.id ?? UUID(), // Keep existing ID if editing
            title: title,
            duration: duration,
            description: description,
            category: category,
            backgroundSound: backgroundSound,
            isFavorite: meditationToEdit?.isFavorite ?? false, // Preserve favorite status
            creationDate: meditationToEdit?.creationDate ?? Date() // Preserve original creation date
        )
        
        if let _ = meditationToEdit {
            dataStore.updateMeditation(newOrUpdatedMeditation)
        } else {
            dataStore.addMeditation(newOrUpdatedMeditation)
        }
        dismiss()
    }
}

// MARK: - Preview
struct AddMeditationView_Previews: PreviewProvider {
    static var previews: some View {
        AddMeditationView()
            .environmentObject(MeditationDataStore.shared)
        
        AddMeditationView(meditationToEdit: MeditationOption.defaultOptions.first!)
            .environmentObject(MeditationDataStore.shared)
    }
}
