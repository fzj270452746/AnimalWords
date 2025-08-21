import Foundation

class AnimalWordsDataManager: ObservableObject {
    static let shared = AnimalWordsDataManager()
    
    private let animalWordsUserDefaults = UserDefaults.standard
    private let animalWordsScoresKey = "AnimalWordsScores"
    private let animalWordsStatsKey = "AnimalWordsStats"
    
    @Published var animalWordsEndlessScores: [AnimalWordsLeaderboardEntry] = []
    @Published var animalWordsTimedScores: [AnimalWordsLeaderboardEntry] = []
    @Published var animalWordsGameStats: AnimalWordsGameStats = AnimalWordsGameStats()
    
    private init() {
        animalWordsLoadData()
    }
    
    // MARK: - Data Loading
    private func animalWordsLoadData() {
        animalWordsLoadScores()
        animalWordsLoadStats()
    }
    
    private func animalWordsLoadScores() {
        if let data = animalWordsUserDefaults.data(forKey: animalWordsScoresKey) {
            do {
                let allScores = try JSONDecoder().decode([AnimalWordsLeaderboardEntry].self, from: data)
                animalWordsEndlessScores = allScores.filter { $0.animalWordsMode == .endless }
                animalWordsTimedScores = allScores.filter { $0.animalWordsMode == .timed }
            } catch {
                print("AnimalWords: Failed to load scores: \(error)")
            }
        }
    }
    
    private func animalWordsLoadStats() {
        if let data = animalWordsUserDefaults.data(forKey: animalWordsStatsKey) {
            do {
                animalWordsGameStats = try JSONDecoder().decode(AnimalWordsGameStats.self, from: data)
            } catch {
                print("AnimalWords: Failed to load stats: \(error)")
            }
        }
    }
    
    // MARK: - Data Saving
    func animalWordsSaveScore(_ score: AnimalWordsGameScore) {
        let entry = AnimalWordsLeaderboardEntry(from: score)
        
        switch score.animalWordsMode {
        case .endless:
            animalWordsEndlessScores.append(entry)
            animalWordsEndlessScores.sort { $0.animalWordsScore > $1.animalWordsScore }
            if animalWordsEndlessScores.count > 100 {
                animalWordsEndlessScores.removeLast()
            }
        case .timed:
            animalWordsTimedScores.append(entry)
            animalWordsTimedScores.sort { $0.animalWordsScore > $1.animalWordsScore }
            if animalWordsTimedScores.count > 100 {
                animalWordsTimedScores.removeLast()
            }
        }
        
        animalWordsGameStats.animalWordsUpdateStats(with: score)
        animalWordsSaveData()
    }
    
    private func animalWordsSaveData() {
        animalWordsSaveScores()
        animalWordsSaveStats()
    }
    
    private func animalWordsSaveScores() {
        let allScores = animalWordsEndlessScores + animalWordsTimedScores
        do {
            let data = try JSONEncoder().encode(allScores)
            animalWordsUserDefaults.set(data, forKey: animalWordsScoresKey)
        } catch {
            print("AnimalWords: Failed to save scores: \(error)")
        }
    }
    
    private func animalWordsSaveStats() {
        do {
            let data = try JSONEncoder().encode(animalWordsGameStats)
            animalWordsUserDefaults.set(data, forKey: animalWordsStatsKey)
        } catch {
            print("AnimalWords: Failed to save stats: \(error)")
        }
    }
    
    // MARK: - Leaderboard Methods
    func animalWordsGetSortedScores(for mode: AnimalWordsGameMode, sortBy: AnimalWordsLeaderboardSortOption) -> [AnimalWordsLeaderboardEntry] {
        let scores = mode == .endless ? animalWordsEndlessScores : animalWordsTimedScores
        
        switch sortBy {
        case .score:
            return scores.sorted { $0.animalWordsScore > $1.animalWordsScore }
        case .words:
            return scores.sorted { $0.animalWordsWordsCount > $1.animalWordsWordsCount }
        }
    }
    
    func animalWordsGetTopThree(for mode: AnimalWordsGameMode, sortBy: AnimalWordsLeaderboardSortOption) -> [AnimalWordsLeaderboardEntry] {
        let sortedScores = animalWordsGetSortedScores(for: mode, sortBy: sortBy)
        return Array(sortedScores.prefix(3))
    }
    
    // MARK: - Clear Data
    func animalWordsClearAllData() {
        animalWordsEndlessScores.removeAll()
        animalWordsTimedScores.removeAll()
        animalWordsGameStats = AnimalWordsGameStats()
        
        animalWordsUserDefaults.removeObject(forKey: animalWordsScoresKey)
        animalWordsUserDefaults.removeObject(forKey: animalWordsStatsKey)
    }
} 