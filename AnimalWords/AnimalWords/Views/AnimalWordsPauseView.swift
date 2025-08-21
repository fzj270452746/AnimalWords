import SwiftUI

struct AnimalWordsPauseView: View {
    @ObservedObject var gameManager: AnimalWordsGameManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 10) {
                    Text("⏸️")
                        .font(.system(size: 60))
                    
                    Text("Game Paused")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Current Stats
                animalWordsCurrentStats
                
                // Buttons
                VStack(spacing: 20) {
                    // Resume Button
                    animalWordsPauseButton(
                        title: "Resume Game",
                        icon: "play.circle.fill",
                        color: .green
                    ) {
                        gameManager.animalWordsResumeGame()
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    // Restart Button
                    animalWordsPauseButton(
                        title: "Restart Game",
                        icon: "arrow.clockwise.circle.fill",
                        color: .orange
                    ) {
                        gameManager.animalWordsStartNewGame(mode: gameManager.animalWordsCurrentGameMode)
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    // Main Menu Button
                    animalWordsPauseButton(
                        title: "Main Menu",
                        icon: "house.circle.fill",
                        color: .red
                    ) {
                        gameManager.animalWordsReturnToMenu()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.top, 60)
        }
    }
    
    private var animalWordsCurrentStats: some View {
        VStack(spacing: 15) {
            Text("Current Progress")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 40) {
                animalWordsStatItem(
                    title: "Score",
                    value: "\(gameManager.animalWordsCurrentScore.animalWordsPoints)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                animalWordsStatItem(
                    title: "Words",
                    value: "\(gameManager.animalWordsCurrentScore.animalWordsWordsCount)",
                    icon: "text.book.closed.fill",
                    color: .blue
                )
                
                if gameManager.animalWordsCurrentGameMode == .timed {
                    animalWordsStatItem(
                        title: "Time",
                        value: gameManager.animalWordsGetFormattedTime(),
                        icon: "timer",
                        color: .orange
                    )
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func animalWordsStatItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private func animalWordsPauseButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 18)
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
} 