//
//  EntryDetailView.swift
//  CraftJournal
//
//  Created by iMac09 on 9/29/26.
//
import SwiftUI

struct EntryDetailView: View {
    @ObservedObject var entry: CraftEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()
                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text(entry.notes ?? "")
                    .font(.body)
                if let date = entry.date {
                    Text(date, style: .date)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
