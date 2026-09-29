//
//  EditEntryView.swift
//  CraftJournal
//
//  Created by iMac09 on 9/29/26.
//

import SwiftUI
import CoreData
import UIKit
import PhotosUI

struct EditEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var entry: CraftEntry

    @State private var title: String
    @State private var craftType: String
    @State private var location: String
    @State private var notes: String
    @State private var image: UIImage?
    @State private var showingCamera = false
    @State private var pickerItem: PhotosPickerItem?

    init(entry: CraftEntry) {
        self.entry = entry
        _title = State(initialValue: entry.title ?? "")
        _craftType = State(initialValue: entry.craftType ?? crafts[0])
        _location = State(initialValue: entry.location ?? "")
        _notes = State(initialValue: entry.notes ?? "")
        if let data = entry.photo {
            _image = State(initialValue: UIImage(data: data))
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Picker("Craft", selection: $craftType) {
                    ForEach(crafts, id: \.self) { craft in
                        Text(craft)
                    }
                }
                TextField("Location", text: $location)
                TextField("Notes", text: $notes, axis: .vertical)

                Section("Photo") {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                    }
                    Button("Take Photo") {
                        showingCamera = true
                    }
                    .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                    PhotosPicker("Choose from Library", selection: $pickerItem, matching: .images)
                        .onChange(of: pickerItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    image = uiImage
                                }
                            }
                        }
                }
            }
            .navigationTitle("Edit Entry")
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(image: $image)
                    .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveChanges() {
        entry.title = title
        entry.craftType = craftType
        entry.location = location
        entry.notes = notes
        entry.photo = image?.jpegData(compressionQuality: 0.7)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not save changes: \(error)")
        }
    }
}
