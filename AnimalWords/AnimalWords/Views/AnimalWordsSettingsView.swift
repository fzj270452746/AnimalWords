import SwiftUI

struct AnimalWordsSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: AnimalWordsDataManager
    @State private var animalWordsShowClearDataAlert = false
    @State private var animalWordsShowInstructions = false
    @State private var animalWordsShowFeedback = false
    
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
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        animalWordsHeader
                        
                        // Settings Content
                        animalWordsSettingsContent
                        
                        // Bottom spacing for safe area
                        Spacer()
                            .frame(height: 50)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $animalWordsShowInstructions) {
            AnimalWordsInstructionsView()
        }
        .sheet(isPresented: $animalWordsShowFeedback) {
            AnimalWordsFeedbackView()
        }
        .alert(isPresented: $animalWordsShowClearDataAlert) {
            Alert(
                title: Text("Clear All Data"),
                message: Text("This will permanently delete all your scores and statistics. This action cannot be undone."),
                primaryButton: .destructive(Text("Clear All")) {
                    dataManager.animalWordsClearAllData()
                },
                secondaryButton: .cancel()
            )
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
                    Text("⚙️")
                        .font(.system(size: 40))
                    
                    Text("Settings")
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
    
    private var animalWordsSettingsContent: some View {
        VStack(spacing: 20) {
            // Game Statistics
            animalWordsGameStats
            
            // Settings Options
            animalWordsSettingsOptions
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    private var animalWordsGameStats: some View {
        VStack(spacing: 15) {
            Text("Your Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                animalWordsStatCard(
                    title: "Games Played",
                    value: "\(dataManager.animalWordsGameStats.animalWordsTotalGames)",
                    icon: "gamecontroller.fill",
                    color: .blue
                )
                
                animalWordsStatCard(
                    title: "Best Score",
                    value: "\(dataManager.animalWordsGameStats.animalWordsBestScore)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                animalWordsStatCard(
                    title: "Total Words",
                    value: "\(dataManager.animalWordsGameStats.animalWordsTotalWordsFound)",
                    icon: "text.book.closed.fill",
                    color: .green
                )
                
                animalWordsStatCard(
                    title: "Total Points",
                    value: "\(dataManager.animalWordsGameStats.animalWordsTotalPoints)",
                    icon: "trophy.fill",
                    color: .orange
                )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private func animalWordsStatCard(title: String, value: String, icon: String, color: Color) -> some View {
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
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var animalWordsSettingsOptions: some View {
        VStack(spacing: 15) {
            // How to Play
            animalWordsSettingsButton(
                title: "How to Play",
                subtitle: "Learn the game rules",
                icon: "questionmark.circle.fill",
                color: .blue
            ) {
                animalWordsShowInstructions = true
            }
            
            // Feedback
            animalWordsSettingsButton(
                title: "Feedback",
                subtitle: "Send us your thoughts",
                icon: "envelope.fill",
                color: .green
            ) {
                animalWordsShowFeedback = true
            }
            
            // Clear Data
            animalWordsSettingsButton(
                title: "Clear All Data",
                subtitle: "Reset scores and statistics",
                icon: "trash.fill",
                color: .red
            ) {
                animalWordsShowClearDataAlert = true
            }
            
            // App Info
            animalWordsAppInfo
        }
    }
    
    private func animalWordsSettingsButton(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(AnimalWordsBouncyButtonStyle())
    }
    
    private var animalWordsAppInfo: some View {
        VStack(spacing: 10) {
            Text("Animal Slot Words")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Version 1.0")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Made with ❤️ for word game lovers")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Instructions View
struct AnimalWordsInstructionsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    VStack(spacing: 10) {
                        Text("🎮")
                            .font(.system(size: 60))
                        
                        Text("How to Play")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                    
                    // Instructions
                    animalWordsInstructionSection(
                        title: "1. Spin the Reels",
                        description: "Tap the SPIN button to randomize the 5 letter reels. Each reel will show a random letter from A to Z.",
                        icon: "arrow.clockwise.circle.fill"
                    )
                    
                    animalWordsInstructionSection(
                        title: "2. Select Letters",
                        description: "Tap on letters to select them. Selected letters will be highlighted in green. You need at least 2 letters to form a word.",
                        icon: "hand.tap.fill"
                    )
                    
                    animalWordsInstructionSection(
                        title: "3. Submit Words",
                        description: "Once you've selected letters, tap SUBMIT to check if they form a valid English word. Valid words earn you 10 points!",
                        icon: "checkmark.circle.fill"
                    )
                    
                    animalWordsInstructionSection(
                        title: "4. Game Modes",
                        description: "• Endless Mode: Play without time limits\n• Timed Mode: Find as many words as possible in 60 seconds",
                        icon: "gamecontroller.fill"
                    )
                    
                    animalWordsInstructionSection(
                        title: "5. Scoring",
                        description: "• Each valid word = 10 points\n• Track your word count and total score\n• Compete on the leaderboards!",
                        icon: "trophy.fill"
                    )
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 15) {
                        Text("💡 Pro Tips")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("• Look for common short words like 'CAT', 'DOG', 'THE'\n• Try animal names - they're often valid!\n• Don't forget about 2-letter words like 'IS', 'AT', 'OF'\n• Letters can be selected in any order")
                            .font(.body)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .navigationTitle("Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func animalWordsInstructionSection(title: String, description: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Feedback View
struct AnimalWordsFeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var animalWordsFeedbackText = ""
    @State private var animalWordsShowThankYou = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Text("📝")
                        .font(.system(size: 60))
                    
                    Text("Send Feedback")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("We'd love to hear your thoughts!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Feedback form
                VStack(alignment: .leading, spacing: 15) {
                    Text("Your Feedback")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $animalWordsFeedbackText)
                        .frame(minHeight: 150)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        )
                    
                    Text("Tell us about bugs, suggestions, or what you love about the game!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                
                // Send button
                Button(action: {
                    animalWordsSendFeedback()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "paperplane.fill")
                        Text("Send Feedback")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
                }
                .disabled(animalWordsFeedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Spacer()
            }
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .alert(isPresented: $animalWordsShowThankYou) {
            Alert(
                title: Text("Thank You!"),
                message: Text("Thanks for your feedback! We appreciate you taking the time to help us improve the game."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func animalWordsSendFeedback() {
        // In a real app, you would send this feedback to your backend
        // For now, we'll just show a thank you message
        animalWordsShowThankYou = true
    }
} 