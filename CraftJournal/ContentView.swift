//
//  ContentView.swift
//  CraftJournal
//
//  Created by iMac09 on 9/29/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CraftEntry.date, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<CraftEntry>

    @State private var showingAddEntry = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    NavigationLink {
                        EntryDetailView(entry: entry)
                    } label: {
                        EntryRow(entry: entry)
                    }
                }
                .onDelete(perform: deleteEntries)
            }
            .navigationTitle("Craft Journal")
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

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.title ?? "Untitled")
                .font(.headline)

            Text(entry.craftType ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext,
                     PersistenceController.preview.container.viewContext)
}
