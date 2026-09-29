import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CraftEntry.date, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<CraftEntry>

    @State private var showingAddEntry = false
    @State private var searchText = ""
    @State private var showFavouritesOnly = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Show", selection: $showFavouritesOnly) {
                    Text("All").tag(false)
                    Text("Favourites").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                Group {
                    if entries.isEmpty {
                        emptyState
                    } else {
                        List {
                            Section {
                                ForEach(entries) { entry in
                                    NavigationLink {
                                        EntryDetailView(entry: entry)
                                    } label: {
                                        EntryRow(entry: entry)
                                    }
                                }
                                .onDelete(perform: deleteEntries)
                            } header: {
                                Text(countText)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Craft Journal")
            .searchable(text: $searchText, prompt: "Search titles")
            .onChange(of: searchText) { _, _ in updatePredicate() }
            .onChange(of: showFavouritesOnly) { _, _ in updatePredicate() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if !searchText.isEmpty {
            ContentUnavailableView(
                "No Results",
                systemImage: "magnifyingglass",
                description: Text("No entries match your search.")
            )
        } else if showFavouritesOnly {
            ContentUnavailableView(
                "No Favourites Yet",
                systemImage: "star",
                description: Text("Tap the star on an entry to add it here.")
            )
        } else {
            ContentUnavailableView(
                "No Entries Yet",
                systemImage: "camera",
                description: Text("Tap + to photograph your first craft.")
            )
        }
    }

    private var countText: String {
        let count = entries.count
        if showFavouritesOnly {
            return count == 1 ? "1 favourite" : "\(count) favourites"
        }
        return count == 1 ? "1 entry" : "\(count) entries"
    }

    private func updatePredicate() {
        var predicates: [NSPredicate] = []
        if showFavouritesOnly {
            predicates.append(NSPredicate(format: "isFavourite == YES"))
        }
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", searchText))
        }
        entries.nsPredicate = predicates.isEmpty
            ? nil
            : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    private func deleteEntries(offsets: IndexSet) {
        offsets.map { entries[$0] }.forEach(viewContext.delete)

        do {
            try viewContext.save()
        } catch {
            print("Could not delete: \(error)")
        }
    }
}

struct EntryRow: View {
    @ObservedObject var entry: CraftEntry
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        HStack {
            if let data = entry.photo, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading) {
                Text(entry.title ?? "Untitled")
                    .font(.headline)
                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let location = entry.location, !location.isEmpty {
                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                entry.isFavourite.toggle()
                try? viewContext.save()
            } label: {
                Image(systemName: entry.isFavourite ? "star.fill" : "star")
                    .foregroundStyle(entry.isFavourite ? .yellow : .secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext,
                     PersistenceController.preview.container.viewContext)
}
