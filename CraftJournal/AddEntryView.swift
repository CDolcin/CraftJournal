import SwiftUI
import CoreData

struct AddEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var craftType = crafts[0]
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Picker("Craft", selection: $craftType) {
                    ForEach(crafts, id: \.self) { craft in
                        Text(craft)
                    }
                }
                TextField("Notes", text: $notes, axis: .vertical)
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveEntry() {
        let entry = CraftEntry(context: viewContext)
        entry.id = UUID()
        entry.title = title
        entry.craftType = craftType
        entry.notes = notes
        entry.date = Date()
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not save: \(error)")
        }
    }
}
