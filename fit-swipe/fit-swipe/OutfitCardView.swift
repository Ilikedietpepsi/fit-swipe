import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore

struct OutfitCardView: View {
    let outfitId: String
    let imageURL: String
    var isTopCard: Bool
    var onSwiped: (_ liked: Bool) -> Void
    @State private var offset = CGSize.zero
    @GestureState private var isDragging = false
    
    
    var body: some View {
        ZStack {
            WebImage(url: URL(string: imageURL))
            .onSuccess { _, _, _ in
                print("✅ Image loaded successfully")
            }
            .resizable()
            .indicator(.activity) // Spinner while loading
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width * 0.85, height: 500) 
            .frame(height: 500)
            .cornerRadius(20)
            .clipped()
            .shadow(radius: 10)
            .offset(x: offset.width, y: offset.height)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .gesture(
                isTopCard ? DragGesture()
                .updating($isDragging) { value, state, _ in
                    state = true
                }
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { gesture in
                    if abs(gesture.translation.width) > 150 {
                    // Swipe completed
                        swipeCard(toRight: gesture.translation.width > 0)
                    } else {
                    // Snap back to center
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    }
                } : nil
            )
            
            if isTopCard {
                VStack {
                    Spacer()
                    HStack (spacing: 60) {
                       
                                    // ❌ Dislike
                       
                        ZStack {
                            Color.clear.frame(width: 80, height: 80) // Fixed invisible box
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .scaleEffect(scaleForIcon(side: "left")) // 👈 Only this changes
                                .foregroundColor(.red)
                                .animation(.easeOut(duration: 0.2), value: offset.width)
                                .onTapGesture {
                                    print("❌ Disliked outfit")
                                }
                        }

                        ZStack {
                            Color.clear.frame(width: 80, height: 80) // Fixed invisible box
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .scaleEffect(scaleForIcon(side: "right")) // 👈 Only this changes
                                .foregroundColor(.green)
                                .animation(.easeOut(duration: 0.2), value: offset.width)
                                .onTapGesture {
                                    print("✅ Liked outfit")
                                }
                        }

                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                }
            }


           
        }
    }

    
    private func scaleForIcon(side: String) -> CGFloat {
        let growth = min(abs(offset.width) / 150, 0.5) // max 50% grow

        if side == "left" && offset.width < 0 {
            return 1.0 + growth
        } else if side == "right" && offset.width > 0 {
            return 1.0 + growth
        } else {
            return 1.0
        }
    }
    
    private func swipeCard(toRight: Bool) {
        withAnimation(.easeIn(duration: 0.4)) {
            offset = CGSize(width: toRight ? 1000 : -1000, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            offset = .zero
            if toRight {
                updateOutfitRating()
            }
            onSwiped(toRight)
        }
        
            // TODO: trigger next outfit or record vote
    }
    
    private func updateOutfitRating() {
        let docRef = Firestore.firestore().collection("outfits").document(outfitId)

        docRef.updateData([
            "rating": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print("❌ Failed to update rating: \(error.localizedDescription)")
            } else {
                print("✅ Rating updated by +1!")
            }
        }
    }
}

