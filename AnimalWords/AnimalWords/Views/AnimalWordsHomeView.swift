import SwiftUI

struct AnimalWordsHomeView: View {
    @ObservedObject var gameManager: AnimalWordsGameManager
    @State private var animalWordsShowLeaderboard = false
    @State private var animalWordsShowSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top spacing
                Spacer()
                    .frame(height: geometry.size.height * 0.1)
                
                // Game Title
                animalWordsTitleSection
                
                Spacer()
                    .frame(height: geometry.size.height * 0.08)
                
                // Mode Selection Buttons
                animalWordsModeSelectionSection
                
                Spacer()
                    .frame(height: geometry.size.height * 0.06)
                
                // Navigation Buttons
                animalWordsNavigationSection
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $animalWordsShowLeaderboard) {
            AnimalWordsLeaderboardView()
        }
        .sheet(isPresented: $animalWordsShowSettings) {
            AnimalWordsSettingsView()
        }
    }
    
    // MARK: - Title Section
    private var animalWordsTitleSection: some View {
        VStack(spacing: 10) {
            // Main title with animal emoji
            HStack {
                Text("🦁")
                    .font(.system(size: 40))
                Text("Animal Slot Words")
                    .font(.custom("Arial-BoldMT", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("🎰")
                    .font(.system(size: 40))
            }
            .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
            
            // Subtitle
            Text("Spin • Select • Score!")
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .fontWeight(.medium)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .blur(radius: 1)
        )
    }
    
    // MARK: - Mode Selection Section
    private var animalWordsModeSelectionSection: some View {
        VStack(spacing: 20) {
            Text("Choose Your Adventure")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Endless Mode Button
            animalWordsModeButton(
                mode: .endless,
                icon: "infinity",
                title: "Endless Mode",
                subtitle: "Play without time limit",
                color: Color.green
            )
            
            // Timed Mode Button
            animalWordsModeButton(
                mode: .timed,
                icon: "timer",
                title: "Timed Mode",
                subtitle: "60 seconds challenge",
                color: Color.orange
            )
        }
    }
    
    // MARK: - Navigation Section
    private var animalWordsNavigationSection: some View {
        HStack(spacing: 30) {
            // Leaderboard Button
            animalWordsNavigationButton(
                icon: "trophy.fill",
                title: "Leaderboard",
                color: Color.yellow
            ) {
                animalWordsShowLeaderboard = true
            }
            
            // Settings Button
            animalWordsNavigationButton(
                icon: "gearshape.fill",
                title: "Settings",
                color: Color.gray
            ) {
                animalWordsShowSettings = true
            }
        }
    }
    
    // MARK: - Helper Views
    private func animalWordsModeButton(
        mode: AnimalWordsGameMode,
        icon: String,
        title: String,
        subtitle: String,
        color: Color
    ) -> some View {
        Button(action: {
            gameManager.animalWordsStartNewGame(mode: mode)
        }) {
            HStack(spacing: 15) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                    .frame(width: 50)
                
                // Text content
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(color.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(AnimalWordsBouncyButtonStyle())
    }
    
    private func animalWordsNavigationButton(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 100, height: 100)
            .background(
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(AnimalWordsBouncyButtonStyle())
    }
}

// MARK: - Custom Button Style
struct AnimalWordsBouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
} 