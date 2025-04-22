import SwiftUI
struct OutfitCardView: View {
    let outfitImage: Image
    let username: String

    var body: some View {
        ZStack {
            outfitImage
                .resizable()
                .scaledToFill()
                .frame(height: 500)
                .clipped()
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal, 10)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                                // ❌ Dislike
                    Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .onTapGesture {
                        print("❌ Disliked outfit")
                    }

                    Spacer()
                                // ✅ Like
                    Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .onTapGesture {
                        print("✅ Liked outfit")
                    }

                    Spacer()
                }
                .padding(.bottom, 20)
            }


           
        }
    }
}
