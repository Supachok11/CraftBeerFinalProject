//
//  MyLogView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import Kingfisher

struct MyLogView: View {
    @StateObject private var vm = BeerLogListViewModel()
    @State private var editingEntry: BeerLogEntry?
    @State private var rating = 3.0
    @State private var notes  = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.logs) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(log.beerName).font(.headline)
                            Spacer()
                            Text(String(format: "%.1f ★", log.rating))
                                .foregroundColor(.yellow)
                        }
                        Text(log.notes).font(.body)
                        Text(log.loggedDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption).foregroundColor(.secondary)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { vm.delete(log) } label: { Label("Delete", systemImage:"trash") }
                        Button { startEdit(log) } label: { Label("Edit", systemImage:"pencil") }.tint(.orange)
                    }
                }
            }
            .navigationTitle("My Beer Log")
            .onAppear { vm.start() }
            .onDisappear { vm.stop() }
            .alert(item: $vm.error) { e in
                Alert(title: Text("Error"), message: Text(e.message), dismissButton: .default(Text("OK")))
            }
            .sheet(item: $editingEntry) { entry in
                NavigationStack {
                    Form {
                        Section("Rating") {
                            Slider(value: $rating, in: 0...5, step: 0.5)
                            Text(String(format:"%.1f ★", rating))
                        }
                        Section("Notes") { TextEditor(text: $notes).frame(height:120) }
                    }
                    .navigationTitle("Edit Entry")
                    .toolbar {
                        ToolbarItem(placement:.confirmationAction) {
                            Button("Save") {
                                vm.update(entry: entry, rating: rating, notes: notes)
                                editingEntry = nil
                            }
                        }
                        ToolbarItem(placement:.cancellationAction) { Button("Close", role:.cancel) { editingEntry=nil } }
                    }
                }
            }
        }
    }
    private func startEdit(_ entry: BeerLogEntry) {
        editingEntry = entry
        rating = entry.rating
        notes  = entry.notes
    }
}

