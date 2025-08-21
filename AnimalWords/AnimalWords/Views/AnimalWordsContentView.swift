import SwiftUI

struct AnimalWordsContentView: View {
    @StateObject private var animalWordsGameManager = AnimalWordsGameManager()
    @StateObject private var animalWordsDataManager = AnimalWordsDataManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.6, blue: 1.0),
                        Color(red: 0.1, green: 0.3, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Main content based on game state
                Group {
                    switch animalWordsGameManager.animalWordsCurrentGameState {
                    case .menu:
                        AnimalWordsHomeView(gameManager: animalWordsGameManager)
                    case .playing, .spinning, .selecting:
                        AnimalWordsGameView(gameManager: animalWordsGameManager)
                    case .paused:
                        AnimalWordsPauseView(gameManager: animalWordsGameManager)
                    case .finished:
                        AnimalWordsGameOverView(gameManager: animalWordsGameManager)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: animalWordsGameManager.animalWordsCurrentGameState)
            }
        }
        .environmentObject(animalWordsGameManager)
        .environmentObject(animalWordsDataManager)
        .preferredColorScheme(.light)
        .statusBarHidden()
    }
} 