import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct Outfit: Identifiable {
    let id: String
    let imageURL: String
    let timestamp: Timestamp

}

struct ContentView: View {
    @State private var outfits: [Outfit] = []
    @State private var reloadToggle = false
    @State private var showUploadSheet = false
    @State private var currentIndex = 0
    @State private var loadingMore = false
    @State private var dragOffset: CGSize = .zero


    var body: some View {
        ZStack {
            if outfits.isEmpty {
                Text("Loading outfits...")
            } else {
                ZStack {
                    ForEach(Array(outfits.enumerated()), id: \.element.id) { index, outfit in
                        OutfitCardView(
                            outfitId: outfit.id,
                            imageURL: outfit.imageURL,
                            isTopCard: index == outfits.count - 1, // ✅ only top card can swipe
                            onSwiped: { liked in
                                handleSwipe(at: index, liked: liked)
                            }
                        )
                    }
                }
                .padding(.bottom, 80) // Leave room for bottom bar
            }
            

            // Bottom Navigation Bar
            bottomBar
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            fetchOutfits()
        }
        .sheet(isPresented: $showUploadSheet) {
            UploadOutfitView()
        }
    }
    
    var bottomBar: some View {
        VStack {
            Spacer()
            HStack {
                VStack {
                    Image(systemName: "house.fill")
                    Text("Main Page")
                        .font(.footnote)
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    fetchOutfits()
                }

                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 8)
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 38, weight: .bold))
                }
                .offset(y: -20)
                .onTapGesture {
                    showUploadSheet = true
                }

                VStack {
                    Image(systemName: "person.crop.circle")
                    Text("My Account")
                        .font(.footnote)
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    print("Go to Account page (future)")
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 10)
            .background(Color.white.shadow(radius: 5))
        }
    }
    
    private func handleSwipe(at index: Int, liked: Bool) {
        // Remove top card after swipe
        if outfits.isEmpty { return }

        outfits.removeLast()

        // Load more outfits if getting low
        if outfits.count <= 1 && !loadingMore {
            loadMoreOutfits()
        }
    }
    
    func loadMoreOutfits() {
        loadingMore = true

        let lastTimestamp = outfits.last?.timestamp ?? Timestamp()

        Firestore.firestore().collection("outfits")
            .order(by: "timestamp", descending: true)
            .start(after: [lastTimestamp])
            .limit(to: 10)
            .getDocuments { snapshot, error in
                loadingMore = false
                if let documents = snapshot?.documents {
                    let newOutfits = documents.compactMap { doc -> Outfit? in
                        guard let url = doc["imageURL"] as? String,
                              let timestamp = doc["timestamp"] as? Timestamp else { return nil }
                        return Outfit(id: doc.documentID, imageURL: url, timestamp: timestamp)
                    }
                    outfits += newOutfits
                }
            }
    }

    func fetchOutfits() {
        Firestore.firestore().collection("outfits")
            .order(by: "timestamp", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.outfits = documents.compactMap { doc in
                        guard let imageURL = doc["imageURL"] as? String,
                              let timestamp = doc["timestamp"] as? Timestamp else { return nil }
                        return Outfit(id: doc.documentID, imageURL: imageURL, timestamp: timestamp)
                    }
                }
            }
    }
}

