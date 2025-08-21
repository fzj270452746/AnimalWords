import Foundation

// MARK: - Game Mode
enum AnimalWordsGameMode: String, CaseIterable, Codable {
    case endless = "endless"
    case timed = "timed"
    
    var animalWordsDisplayName: String {
        switch self {
        case .endless:
            return "Endless Mode"
        case .timed:
            return "Timed Mode"
        }
    }
    
    var animalWordsDescription: String {
        switch self {
        case .endless:
            return "Play without time limit"
        case .timed:
            return "60 seconds challenge"
        }
    }
}

// MARK: - Game State
enum AnimalWordsGameState {
    case menu
    case playing
    case spinning
    case selecting
    case paused
    case finished
}

// MARK: - Letter Selection State
enum AnimalWordsLetterState {
    case normal
    case selected
    case highlighted
    case used
}

// MARK: - Reel Symbol
struct AnimalWordsReelSymbol {
    let animalWordsLetter: String
    var animalWordsState: AnimalWordsLetterState = .normal
    let animalWordsImageName: String
    
    init(letter: String) {
        self.animalWordsLetter = letter.lowercased()
        self.animalWordsImageName = "letters-\(letter.lowercased())"
    }
}

// MARK: - Game Score
struct AnimalWordsGameScore: Codable {
    var animalWordsPoints: Int = 0
    var animalWordsWordsCount: Int = 0
    var animalWordsMode: AnimalWordsGameMode
    var animalWordsDate: Date = Date()
    var animalWordsPlayerName: String = "Player"
    
    init(mode: AnimalWordsGameMode) {
        self.animalWordsMode = mode
    }
}

// MARK: - Game Statistics
struct AnimalWordsGameStats: Codable {
    var animalWordsTotalGames: Int = 0
    var animalWordsBestScore: Int = 0
    var animalWordsBestWordsCount: Int = 0
    var animalWordsTotalWordsFound: Int = 0
    var animalWordsTotalPoints: Int = 0
    
    mutating func animalWordsUpdateStats(with score: AnimalWordsGameScore) {
        animalWordsTotalGames += 1
        animalWordsTotalPoints += score.animalWordsPoints
        animalWordsTotalWordsFound += score.animalWordsWordsCount
        
        if score.animalWordsPoints > animalWordsBestScore {
            animalWordsBestScore = score.animalWordsPoints
        }
        
        if score.animalWordsWordsCount > animalWordsBestWordsCount {
            animalWordsBestWordsCount = score.animalWordsWordsCount
        }
    }
}

// MARK: - Leaderboard Entry
struct AnimalWordsLeaderboardEntry: Codable, Identifiable {
    let id = UUID()
    var animalWordsPlayerName: String
    var animalWordsScore: Int
    var animalWordsWordsCount: Int
    var animalWordsDate: Date
    var animalWordsMode: AnimalWordsGameMode
    
    init(from gameScore: AnimalWordsGameScore) {
        self.animalWordsPlayerName = gameScore.animalWordsPlayerName
        self.animalWordsScore = gameScore.animalWordsPoints
        self.animalWordsWordsCount = gameScore.animalWordsWordsCount
        self.animalWordsDate = gameScore.animalWordsDate
        self.animalWordsMode = gameScore.animalWordsMode
    }
}

// MARK: - Sort Option
enum AnimalWordsLeaderboardSortOption: String, CaseIterable {
    case score = "score"
    case words = "words"
    
    var animalWordsDisplayName: String {
        switch self {
        case .score:
            return "By Score"
        case .words:
            return "By Words"
        }
    }
}

// MARK: - Word Validation Response
struct AnimalWordsValidationResponse: Codable {
    let animalWordsIsValid: Bool
    let animalWordsWord: String
    let animalWordsDefinition: String?
    
    init(isValid: Bool, word: String, definition: String? = nil) {
        self.animalWordsIsValid = isValid
        self.animalWordsWord = word
        self.animalWordsDefinition = definition
    }
} 