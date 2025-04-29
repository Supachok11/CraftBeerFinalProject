import SwiftUI
import FirebaseFirestore
import FirebaseAuth

/// Modal sheet that lets a user add tasting notes + rating
/// for the current beer.  Saves to a `userLogs` collection.
struct BeerLogEntryView: View {

    // passed-in data
    let beer: Beer
    @Binding var isPresented: Bool

    // user session
    @EnvironmentObject private var session: SessionManager

    // form fields
    @State private var rating: Double = 3        // 0‒5 stars
    @State private var notes:  String  = ""

    // UI state
    @State private var saving   = false
    @State private var errorMsg: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Rating")) {
                    Slider(value: $rating, in: 0...5, step: 0.5)
                    HStack {
                        ForEach(0..<5) { idx in
                            Image(systemName: idx < Int(rating.rounded()) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Tasting Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Log This Beer")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) { isPresented = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if saving {
                        ProgressView()
                    } else {
                        Button("Save") { saveEntry() }
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMsg != nil), actions: {
                Button("OK", role: .cancel) { errorMsg = nil }
            }, message: {
                Text(errorMsg ?? "")
            })
        }
    }

    // MARK: – Firestore write
    private func saveEntry() {
        guard let uid = session.user?.uid else { return }

        saving = true
        let db   = Firestore.firestore()

        let entry: [String: Any] = [
            "userId":     uid,
            "beerId":     beer.id ?? "",
            "beerName":   beer.name,
            "rating":     rating,
            "notes":      notes,
            "loggedDate": Timestamp(date: Date())
        ]

        db.collection("userLogs")
            .addDocument(data: entry) { err in
                saving = false
                if let err { errorMsg = err.localizedDescription }
                else { isPresented = false }
            }
    }
}

// MARK: - Supporting Structures
struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}
