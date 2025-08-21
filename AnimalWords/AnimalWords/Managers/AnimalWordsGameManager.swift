import Foundation
import SwiftUI

class AnimalWordsGameManager: ObservableObject {
    // MARK: - Published Properties
    @Published var animalWordsCurrentGameState: AnimalWordsGameState = .menu
    @Published var animalWordsCurrentGameMode: AnimalWordsGameMode = .endless
    @Published var animalWordsReelSymbols: [AnimalWordsReelSymbol] = []
    @Published var animalWordsSelectedLetters: [Int] = []
    @Published var animalWordsCurrentScore: AnimalWordsGameScore
    @Published var animalWordsTimeRemaining: Int = 60
    @Published var animalWordsIsSpinning: Bool = false
    @Published var animalWordsFoundWords: [String] = []
    @Published var animalWordsLastValidationMessage: String = ""
    @Published var animalWordsShowValidationAlert: Bool = false
    
    // MARK: - Private Properties
    private var animalWordsTimer: Timer?
    private let animalWordsDataManager = AnimalWordsDataManager.shared
    private let animalWordsWordValidator = AnimalWordsWordValidator.shared
    private let animalWordsAlphabet = Array("abcdefghijklmnopqrstuvwxyz")
    
    // MARK: - Constants
    private let animalWordsReelCount = 5
    private let animalWordsPointsPerWord = 10
    private let animalWordsTimedModeDuration = 60
    
    init() {
        self.animalWordsCurrentScore = AnimalWordsGameScore(mode: .endless)
        animalWordsInitializeReels()
    }
    
    // MARK: - Game Initialization
    private func animalWordsInitializeReels() {
        animalWordsReelSymbols = (0..<animalWordsReelCount).map { _ in
            let randomLetter = animalWordsAlphabet.randomElement() ?? "a"
            return AnimalWordsReelSymbol(letter: String(randomLetter))
        }
    }
    
    func animalWordsStartNewGame(mode: AnimalWordsGameMode) {
        animalWordsCurrentGameMode = mode
        animalWordsCurrentScore = AnimalWordsGameScore(mode: mode)
        animalWordsCurrentGameState = .playing
        animalWordsSelectedLetters.removeAll()
        animalWordsFoundWords.removeAll()
        animalWordsLastValidationMessage = ""
        
        if mode == .timed {
            animalWordsTimeRemaining = animalWordsTimedModeDuration
            animalWordsStartTimer()
        }
        
        animalWordsInitializeReels()
    }
    
    // MARK: - Timer Management
    private func animalWordsStartTimer() {
        animalWordsTimer?.invalidate()
        animalWordsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.animalWordsTimeRemaining > 0 {
                    self.animalWordsTimeRemaining -= 1
                } else {
                    self.animalWordsEndGame()
                }
            }
        }
    }
    
    private func animalWordsStopTimer() {
        animalWordsTimer?.invalidate()
        animalWordsTimer = nil
    }
    
    // MARK: - Slot Machine Mechanics
    func animalWordsSpin() {
        guard animalWordsCurrentGameState == .playing || animalWordsCurrentGameState == .selecting else { return }
        
        animalWordsIsSpinning = true
        animalWordsCurrentGameState = .spinning
        animalWordsSelectedLetters.removeAll()
        animalWordsResetAllLetterStates() // Use reset method instead of clear
        
        // Simulate spinning animation delay - longer for realistic slot machine feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.animalWordsGenerateNewSymbols()
            self.animalWordsIsSpinning = false
            self.animalWordsCurrentGameState = .selecting
        }
    }
    
    private func animalWordsGenerateNewSymbols() {
        for i in 0..<animalWordsReelSymbols.count {
            let randomLetter = animalWordsAlphabet.randomElement() ?? "a"
            animalWordsReelSymbols[i] = AnimalWordsReelSymbol(letter: String(randomLetter))
        }
    }
    
    // MARK: - Letter Selection
    func animalWordsToggleLetterSelection(at index: Int) {
        guard animalWordsCurrentGameState == .selecting,
              index < animalWordsReelSymbols.count else { return }
        
        // Prevent selection of already used letters
        if animalWordsReelSymbols[index].animalWordsState == .used {
            return
        }
        
        if animalWordsSelectedLetters.contains(index) {
            // Deselect
            animalWordsSelectedLetters.removeAll { $0 == index }
            animalWordsReelSymbols[index].animalWordsState = .normal
        } else {
            // Select
            animalWordsSelectedLetters.append(index)
            animalWordsReelSymbols[index].animalWordsState = .selected
        }
        
        // Keep the original selection order - do not sort
    }
    
    private func animalWordsClearLetterStates() {
        for i in 0..<animalWordsReelSymbols.count {
            // Only reset to normal if not already used
            if animalWordsReelSymbols[i].animalWordsState != .used {
                animalWordsReelSymbols[i].animalWordsState = .normal
            }
        }
    }
    
    private func animalWordsResetAllLetterStates() {
        for i in 0..<animalWordsReelSymbols.count {
            // Reset all states to normal, including used states (for new spin)
            animalWordsReelSymbols[i].animalWordsState = .normal
        }
    }
    
    func animalWordsClearSelection() {
        animalWordsSelectedLetters.removeAll()
        animalWordsClearLetterStates()
    }
    
    private func animalWordsMarkUsedLetters() {
        for index in animalWordsSelectedLetters {
            animalWordsReelSymbols[index].animalWordsState = .used
        }
    }
    
    // MARK: - Word Validation and Scoring
    func animalWordsSubmitSelectedWord() {
        guard !animalWordsSelectedLetters.isEmpty,
              animalWordsSelectedLetters.count >= 2 else {
            animalWordsShowValidationMessage("Select at least 2 letters to form a word")
            return
        }
        
        let selectedWord = animalWordsSelectedLetters
            .map { animalWordsReelSymbols[$0].animalWordsLetter }
            .joined()
        
        Task {
            let validation = await animalWordsWordValidator.animalWordsValidateWord(selectedWord)
            
            DispatchQueue.main.async {
                if validation.animalWordsIsValid {
                    self.animalWordsHandleValidWord(selectedWord)
                } else {
                    self.animalWordsHandleInvalidWord(selectedWord)
                }
            }
        }
    }
    
    private func animalWordsHandleValidWord(_ word: String) {
        // Check if word was already found
        if animalWordsFoundWords.contains(word.lowercased()) {
            animalWordsShowValidationMessage("You already found '\(word.uppercased())'!")
            return
        }
        
        // Add to found words
        animalWordsFoundWords.append(word.lowercased())
        
        // Update score
        animalWordsCurrentScore.animalWordsPoints += animalWordsPointsPerWord
        animalWordsCurrentScore.animalWordsWordsCount += 1
        
        // Show success message
        animalWordsShowValidationMessage("Great! '\(word.uppercased())' is valid! +\(animalWordsPointsPerWord) points")
        
        // Mark used letters as unavailable
        animalWordsMarkUsedLetters()
        
        // Clear selection
        animalWordsClearSelection()
        
        // Add visual feedback
        animalWordsHighlightValidWord()
    }
    
    private func animalWordsHandleInvalidWord(_ word: String) {
        animalWordsShowValidationMessage("'\(word.uppercased())' is not a valid word. Try again!")
        
        // Highlight invalid selection briefly
        for index in animalWordsSelectedLetters {
            animalWordsReelSymbols[index].animalWordsState = .highlighted
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.animalWordsClearSelection()
        }
    }
    
    private func animalWordsHighlightValidWord() {
        // Add a brief highlight effect for valid words
        for index in animalWordsSelectedLetters {
            animalWordsReelSymbols[index].animalWordsState = .highlighted
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animalWordsClearLetterStates()
        }
    }
    
    private func animalWordsShowValidationMessage(_ message: String) {
        animalWordsLastValidationMessage = message
        animalWordsShowValidationAlert = true
        
        // Auto-hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.animalWordsShowValidationAlert = false
        }
    }
    
    // MARK: - Game End
    func animalWordsEndGame() {
        animalWordsStopTimer()
        animalWordsCurrentGameState = .finished
        
        // Save score if player found at least one word
        if animalWordsCurrentScore.animalWordsWordsCount > 0 {
            animalWordsDataManager.animalWordsSaveScore(animalWordsCurrentScore)
        }
    }
    
    func animalWordsReturnToMenu() {
        // Save score before returning to menu if player found at least one word
        if animalWordsCurrentScore.animalWordsWordsCount > 0 && 
           (animalWordsCurrentGameState == .playing || animalWordsCurrentGameState == .selecting || animalWordsCurrentGameState == .paused) {
            animalWordsDataManager.animalWordsSaveScore(animalWordsCurrentScore)
        }
        
        animalWordsStopTimer()
        animalWordsCurrentGameState = .menu
        animalWordsSelectedLetters.removeAll()
        animalWordsFoundWords.removeAll()
        animalWordsLastValidationMessage = ""
    }
    
    func animalWordsPauseGame() {
        if animalWordsCurrentGameState == .playing || animalWordsCurrentGameState == .selecting {
            animalWordsCurrentGameState = .paused
            animalWordsStopTimer()
        }
    }
    
    func animalWordsResumeGame() {
        if animalWordsCurrentGameState == .paused {
            animalWordsCurrentGameState = .playing
            if animalWordsCurrentGameMode == .timed {
                animalWordsStartTimer()
            }
        }
    }
    
    // MARK: - Helper Methods
    func animalWordsGetSelectedWord() -> String {
        return animalWordsSelectedLetters
            .map { animalWordsReelSymbols[$0].animalWordsLetter }
            .joined()
            .uppercased()
    }
    
    func animalWordsGetFormattedTime() -> String {
        let minutes = animalWordsTimeRemaining / 60
        let seconds = animalWordsTimeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    deinit {
        animalWordsStopTimer()
    }
} 