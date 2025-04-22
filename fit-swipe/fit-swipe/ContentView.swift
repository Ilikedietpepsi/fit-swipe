import SwiftUI

struct ContentView: View {
    @State private var reloadToggle = false
    var body: some View {
        ZStack {
            // Main swipe content
            if reloadToggle {
                ContentViewBody()
            } else {
                ContentViewBody()
            }
            // Bottom Navigation Bar
            VStack {
                Spacer()
                HStack {
                    // Left: Main Page Label
                    VStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 40))
                        Text("Main Page")
                            .font(.footnote)
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        print("🔁 Refreshing main page")
                        reloadToggle.toggle()  // Triggers rebuild
                    }

                    // Center: Floating +
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
                        // TODO: Add outfit logic
                        print("➕ Add Outfit tapped")
                    }

                    // Right: My Account (to implement later)
                    VStack {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 40))
                        Text("My Account")
                            .font(.footnote)
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        print("👤 My Account tapped")
                        // TODO: Navigate to account screen
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                .background(
                    Color.white
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
                )
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    private func ContentViewBody() -> some View {
        OutfitCardView(
            outfitImage: Image("outfit"), // Replace with dynamic image later
            username: "user1"
        )
        .padding(.bottom, 80) // Room for nav bar
        .transition(.opacity) // Smooth animation (optional)
        .id(UUID()) // Force redraw if needed
    }
}
