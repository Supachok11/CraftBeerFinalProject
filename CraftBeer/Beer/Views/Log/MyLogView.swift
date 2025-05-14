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
    @State private var rating: Double = 3
    @State private var notes:  String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor.ignoresSafeArea()

                // ───────── EMPTY / LOADING / LIST STATES ─────────
                if vm.isLoading {
                    ProgressView("Loading logs…")
                        .tint(.primaryColor)
                } else if vm.logs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "note.text")
                            .font(.system(size: 64))
                            .foregroundColor(.textSecondary)
                        Text("No Beer Log yet")
                            .font(.headline)
                            .foregroundColor(.textSecondary)
                    }
                } else {
                    List {
                        ForEach(vm.logs) { log in
                            logRow(log)
                                .listRowBackground(Color.surfaceColor)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        vm.delete(log)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        startEdit(log)
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.orange)

                                    ShareLink(item: shareText(for: log)) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My Beer Log")
            .accentColor(.primaryColor)
            .onAppear { vm.start() }
            .onDisappear { vm.stop() }
            .alert(item: $vm.error) { e in
                Alert(title: Text("Error"),
                      message: Text(e.message),
                      dismissButton: .default(Text("OK")))
            }
            // ───────── EDIT SHEET ─────────
            .sheet(item: $editingEntry) { entry in
                NavigationStack {
                    Form {
                        Section("Rating") {
                            Slider(value: $rating, in: 0...5, step: 0.5)
                            Text(String(format: "%.1f ★", rating))
                        }
                        Section("Notes") {
                            TextEditor(text: $notes)
                                .frame(height: 120)
                        }
                    }
                    .navigationTitle("Edit Entry")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                vm.update(entry: entry,
                                          rating: rating,
                                          notes: notes)
                                editingEntry = nil
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close", role: .cancel) { editingEntry = nil }
                        }
                    }
                }
            }
        }
    }

    // MARK: – Helpers
    private func startEdit(_ entry: BeerLogEntry) {
        editingEntry = entry
        rating = entry.rating
        notes  = entry.notes
    }

    private func shareText(for log: BeerLogEntry) -> String {
        "Check out my beer log for \(log.beerName): \(log.rating) ★ - \(log.notes)"
    }

    @ViewBuilder
    private func logRow(_ log: BeerLogEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(log.beerName).font(.headline)
                Spacer()
                Text(String(format: "%.1f ★", log.rating))
                    .foregroundColor(.yellow)
            }
            Text(log.notes).font(.body)
            Text(log.loggedDate.formatted(date: .abbreviated, time: .shortened))
                .font(.caption).foregroundColor(.textSecondary)
        }
    }
}
