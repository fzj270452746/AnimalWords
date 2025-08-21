import SwiftUI

struct AnimalWordsLeaderboardView: View {
    @EnvironmentObject var dataManager: AnimalWordsDataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var animalWordsSelectedMode: AnimalWordsGameMode = .endless
    @State private var animalWordsSortOption: AnimalWordsLeaderboardSortOption = .score
    
    var body: some View {
        NavigationView {
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
                
                VStack(spacing: 0) {
                    // Header
                    animalWordsHeader
                    
                    // Mode and Sort Selection
                    animalWordsControlSection
                    
                    // Leaderboard Content
                    animalWordsLeaderboardContent
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var animalWordsHeader: some View {
        VStack(spacing: 15) {
            HStack {
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                .font(.headline)
                
                Spacer()
                
                VStack(spacing: 5) {
                    Text("🏆")
                        .font(.system(size: 40))
                    
                    Text("Leaderboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Placeholder for balance
                Text("Close")
                    .foregroundColor(.clear)
                    .font(.headline)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    private var animalWordsControlSection: some View {
        VStack(spacing: 20) {
            // Mode Selection
            HStack(spacing: 15) {
                Text("Mode:")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                Picker("Mode", selection: $animalWordsSelectedMode) {
                    ForEach(AnimalWordsGameMode.allCases, id: \.self) { mode in
                        Text(mode.animalWordsDisplayName)
                            .tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            }
            
            // Sort Selection
            HStack(spacing: 15) {
                Text("Sort by:")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                Picker("Sort", selection: $animalWordsSortOption) {
                    ForEach(AnimalWordsLeaderboardSortOption.allCases, id: \.self) { option in
                        Text(option.animalWordsDisplayName)
                            .tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
    
    private var animalWordsLeaderboardContent: some View {
        let scores = dataManager.animalWordsGetSortedScores(for: animalWordsSelectedMode, sortBy: animalWordsSortOption)
        
        return VStack(spacing: 15) {
            if scores.isEmpty {
                animalWordsEmptyState
            } else {
                // Top 3 Podium
                animalWordsTopThreePodium(scores: scores)
                
                // Rest of the scores
                animalWordsScoresList(scores: scores)
            }
        }
        .padding(.top, 20)
    }
    
    private var animalWordsEmptyState: some View {
        VStack(spacing: 20) {
            Text("🎮")
                .font(.system(size: 80))
            
            Text("No scores yet!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Play some games to see your scores here")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button("Start Playing") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                Capsule()
                    .fill(Color.green)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            )
        }
        .padding(.top, 50)
    }
    
    private func animalWordsTopThreePodium(scores: [AnimalWordsLeaderboardEntry]) -> some View {
        let topThree = Array(scores.prefix(3))
        
        return VStack(spacing: 15) {
            Text("🏆 Top 3 Champions 🏆")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
            
            HStack(alignment: .bottom, spacing: 10) {
                // Second Place
                if topThree.count > 1 {
                    animalWordsPodiumItem(
                        entry: topThree[1],
                        rank: 2,
                        height: 80,
                        color: .silver
                    )
                }
                
                // First Place
                if !topThree.isEmpty {
                    animalWordsPodiumItem(
                        entry: topThree[0],
                        rank: 1,
                        height: 100,
                        color: .gold
                    )
                }
                
                // Third Place
                if topThree.count > 2 {
                    animalWordsPodiumItem(
                        entry: topThree[2],
                        rank: 3,
                        height: 60,
                        color: .bronze
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                )
        )
        .padding(.horizontal, 20)
    }
    
    private func animalWordsPodiumItem(entry: AnimalWordsLeaderboardEntry, rank: Int, height: CGFloat, color: Color) -> some View {
        VStack(spacing: 8) {
            // Crown/Medal
            Text(rank == 1 ? "👑" : rank == 2 ? "🥈" : "🥉")
                .font(.system(size: 30))
            
            // Player info
            VStack(spacing: 4) {
                Text(entry.animalWordsPlayerName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(animalWordsSortOption == .score ? "\(entry.animalWordsScore) pts" : "\(entry.animalWordsWordsCount) words")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("#\(rank)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color, lineWidth: 2)
                    )
            )
            
            // Podium base
            Rectangle()
                .fill(color.opacity(0.8))
                .frame(height: height)
                .cornerRadius(8)
        }
        .frame(maxWidth: 100)
    }
    
    private func animalWordsScoresList(scores: [AnimalWordsLeaderboardEntry]) -> some View {
        let remainingScores = scores.count > 3 ? Array(scores.dropFirst(3)) : []
        
        return VStack(spacing: 10) {
            if !remainingScores.isEmpty {
                Text("All Rankings")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(remainingScores.enumerated()), id: \.element.id) { index, entry in
                            animalWordsScoreRow(entry: entry, rank: index + 4)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private func animalWordsScoreRow(entry: AnimalWordsLeaderboardEntry, rank: Int) -> some View {
        HStack(spacing: 15) {
            // Rank
            Text("#\(rank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 40, alignment: .leading)
            
            // Player name
            Text(entry.animalWordsPlayerName)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            // Score/Words
            VStack(alignment: .trailing, spacing: 2) {
                Text(animalWordsSortOption == .score ? "\(entry.animalWordsScore)" : "\(entry.animalWordsWordsCount)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(animalWordsSortOption == .score ? "points" : "words")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Date
            Text(animalWordsFormatDate(entry.animalWordsDate))
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func animalWordsFormatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Color Extensions
extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let silver = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let bronze = Color(red: 0.8, green: 0.5, blue: 0.2)
} 