import SwiftUI

struct AnimalWordsGameOverView: View {
    @ObservedObject var gameManager: AnimalWordsGameManager
    @EnvironmentObject var dataManager: AnimalWordsDataManager
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Top spacing
                    Spacer()
                        .frame(height: max(20, geometry.size.height * 0.05))
                    
                    // Game Over Title
                    animalWordsGameOverTitle
                    
                    // Final Score Section
                    animalWordsFinalScoreSection
                    
                    // Found Words Section
                    animalWordsFoundWordsSection(geometry: geometry)
                    
                    // Action Buttons
                    animalWordsActionButtons
                    
                    // Bottom spacing for safe area
                    Spacer()
                        .frame(height: max(30, geometry.size.height * 0.05))
                }
                .padding(.horizontal, max(20, min(40, geometry.size.width * 0.1)))
                .frame(minHeight: geometry.size.height)
            }
        }
    }
    
    private var animalWordsGameOverTitle: some View {
        VStack(spacing: 12) {
            Text("🎉")
                .font(.system(size: 60))
            
            Text("Game Over!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(gameManager.animalWordsCurrentGameMode.animalWordsDisplayName)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var animalWordsFinalScoreSection: some View {
        VStack(spacing: 20) {
            Text("Final Score")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 40) {
                animalWordsScoreItem(
                    title: "Total Score",
                    value: "\(gameManager.animalWordsCurrentScore.animalWordsPoints)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                animalWordsScoreItem(
                    title: "Words Found",
                    value: "\(gameManager.animalWordsCurrentScore.animalWordsWordsCount)",
                    icon: "text.book.closed.fill",
                    color: .green
                )
            }
            
            // Performance Rating
            animalWordsPerformanceRating
        }
        .padding(.vertical, 25)
        .padding(.horizontal, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private func animalWordsScoreItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var animalWordsPerformanceRating: some View {
        let wordsCount = gameManager.animalWordsCurrentScore.animalWordsWordsCount
        let (rating, emoji, message) = animalWordsGetPerformanceRating(wordsCount: wordsCount)
        
        return VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 40))
            
            Text(rating)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 15)
    }
    
    private func animalWordsFoundWordsSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: 15) {
            if !gameManager.animalWordsFoundWords.isEmpty {
                Text("Words You Found")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                let columns = animalWordsCalculateGridColumns(for: geometry.size.width)
                let maxHeight = min(max(120, geometry.size.height * 0.15), 200)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(gameManager.animalWordsFoundWords, id: \.self) { word in
                            Text(word.uppercased())
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.9))
                                )
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                }
                .frame(maxHeight: maxHeight)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            } else {
                VStack(spacing: 10) {
                    Text("😅")
                        .font(.system(size: 30))
                    
                    Text("No words found this time")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Try spinning more and look for common words!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                )
            }
        }
    }
    
    private func animalWordsCalculateGridColumns(for width: CGFloat) -> [GridItem] {
        // Adaptive column count based on screen width
        let columnCount: Int
        if width > 768 { // iPad landscape
            columnCount = 4
        } else if width > 600 { // iPad portrait or large phone landscape
            columnCount = 3
        } else if width > 400 { // Regular phone
            columnCount = 3
        } else { // Small phone
            columnCount = 2
        }
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount)
    }
    
    private var animalWordsActionButtons: some View {
        VStack(spacing: 12) {
            // Play Again Button (Full width, prominent)
            animalWordsActionButton(
                title: "Play Again",
                icon: "arrow.clockwise.circle.fill",
                color: .green,
                isFullWidth: true
            ) {
                gameManager.animalWordsStartNewGame(mode: gameManager.animalWordsCurrentGameMode)
            }
            
            // Secondary buttons in a row
            HStack(spacing: 12) {
                // Different Mode Button
                animalWordsActionButton(
                    title: gameManager.animalWordsCurrentGameMode == .endless ? "Try Timed" : "Try Endless",
                    icon: gameManager.animalWordsCurrentGameMode == .endless ? "timer" : "infinity",
                    color: .orange,
                    isFullWidth: false
                ) {
                    let newMode: AnimalWordsGameMode = gameManager.animalWordsCurrentGameMode == .endless ? .timed : .endless
                    gameManager.animalWordsStartNewGame(mode: newMode)
                }
                
                // Main Menu Button
                animalWordsActionButton(
                    title: "Main Menu",
                    icon: "house.circle.fill",
                    color: .blue,
                    isFullWidth: false
                ) {
                    gameManager.animalWordsReturnToMenu()
                }
            }
        }
        .padding(.horizontal, 10)
    }
    
    private func animalWordsActionButton(
        title: String,
        icon: String,
        color: Color,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(isFullWidth ? .title3 : .headline)
                
                Text(title)
                    .font(isFullWidth ? .title3 : .headline)
                    .fontWeight(.semibold)
                
                if isFullWidth {
                    Spacer()
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, isFullWidth ? 30 : 20)
            .padding(.vertical, isFullWidth ? 18 : 12)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(color)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(AnimalWordsBouncyButtonStyle())
    }
    
    private func animalWordsGetPerformanceRating(wordsCount: Int) -> (String, String, String) {
        switch wordsCount {
        case 0:
            return ("Keep Trying!", "💪", "Every expert was once a beginner!")
        case 1...3:
            return ("Good Start!", "👍", "You're getting the hang of it!")
        case 4...7:
            return ("Well Done!", "🌟", "You're becoming a word master!")
        case 8...12:
            return ("Excellent!", "🔥", "Outstanding word skills!")
        case 13...20:
            return ("Amazing!", "🚀", "You're a word wizard!")
        default:
            return ("Legendary!", "👑", "Absolutely incredible performance!")
        }
    }
} 