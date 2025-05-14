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

    /// A view displaying interactive half-star rating.
    struct StarRatingView: View {
        @Binding var rating: Double
        let maxRating: Int = 5

        var body: some View {
            GeometryReader { geo in
                let fullWidth = geo.size.width
                let stepWidth = fullWidth / CGFloat(maxRating)
                HStack(spacing: 4) {
                    ForEach(0..<maxRating, id: \.self) { index in
                        let lower = Double(index)
                        let upper = Double(index + 1)
                        let symbol = rating >= upper
                            ? "star.fill"
                            : (rating >= lower + 0.5
                                ? "star.lefthalf.fill"
                                : "star")
                        Image(systemName: symbol)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: stepWidth - 4, height: stepWidth - 4)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            let x = min(max(0, value.location.x), fullWidth)
                            let raw = Double(x / stepWidth)
                            let newRating = (raw * 2).rounded() / 2
                            rating = min(max(newRating, 0), Double(maxRating))
                        }
                )
            }
            .frame(height: 44)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Rating")) {
                    StarRatingView(rating: $rating)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Section("Tasting Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                        .padding(4)
                        .background(Color.surfaceColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.primaryColor, lineWidth: 1)
                        )
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.surfaceColor)
            .navigationTitle("Log This Beer")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) { isPresented = false }
                        .foregroundColor(.primaryColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if saving {
                        ProgressView()
                    } else {
                        Button("Save") { saveEntry() }
                            .foregroundColor(.primaryColor)
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMsg != nil), actions: {
                Button("OK", role: .cancel) {
                    errorMsg = nil
                }
            }, message: {
                Text(errorMsg ?? "")
            })
        }
        .accentColor(.primaryColor)
    }

    // MARK: – Firestore write
    private func saveEntry() {
        guard let uid = session.user?.uid else {
            return
        }

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
                if let err {
                    errorMsg = err.localizedDescription
                }
                else {
                    isPresented = false
                }
            }
    }
}

// MARK: - Supporting Structures
struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}
