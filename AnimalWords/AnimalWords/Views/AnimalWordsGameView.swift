import SwiftUI

struct AnimalWordsGameView: View {
    @ObservedObject var gameManager: AnimalWordsGameManager
    @State private var animalWordsShowPauseMenu = false
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    // Top HUD
                    animalWordsTopHUD(geometry: geometry)
                    
                    // Slot Machine Section
                    animalWordsSlotMachineSection(geometry: geometry)
                    
                    // Selected Word Display
                    animalWordsSelectedWordSection
                    
                    // Control Buttons
                    animalWordsControlButtonsSection(geometry: geometry)
                    
                    // Found Words List
                    animalWordsFoundWordsSection(geometry: geometry)
                    
                    Spacer()
                }
                .frame(maxWidth: geometry.size.width - 40)
                Spacer()
            }
        }
        .overlay(
            // Validation Alert
            animalWordsValidationAlert,
            alignment: .bottom
        )
        .sheet(isPresented: $animalWordsShowPauseMenu) {
            AnimalWordsPauseView(gameManager: gameManager)
        }
    }
    
    // MARK: - Top HUD
    private func animalWordsTopHUD(geometry: GeometryProxy) -> some View {
        HStack {
            // Pause Button
            Button(action: {
                animalWordsShowPauseMenu = true
            }) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Score and Timer
            VStack(alignment: .center, spacing: 4) {
                HStack(spacing: 20) {
                    // Score
                    VStack(spacing: 2) {
                        Text("SCORE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(gameManager.animalWordsCurrentScore.animalWordsPoints)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Words Count
                    VStack(spacing: 2) {
                        Text("WORDS")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(gameManager.animalWordsCurrentScore.animalWordsWordsCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                // Timer (for timed mode)
                if gameManager.animalWordsCurrentGameMode == .timed {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(gameManager.animalWordsGetFormattedTime())
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(gameManager.animalWordsTimeRemaining <= 10 ? .red : .white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                    )
                }
            }
            
            Spacer()
            
            // Home Button
            Button(action: {
                gameManager.animalWordsReturnToMenu()
            }) {
                Image(systemName: "house.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    // MARK: - Slot Machine Section
    private func animalWordsSlotMachineSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            // Slot Machine Frame
            animalWordsSlotMachineFrame(geometry: geometry)
            
            // Spin Button
            animalWordsSpinButton
        }
    }
    
    private func animalWordsSlotMachineFrame(geometry: GeometryProxy) -> some View {
        let availableWidth = geometry.size.width - 80 // Account for main padding and frame padding
        let reelWidth = min(availableWidth / 5 - 5, 70) // Account for spacing
        let reelHeight = reelWidth * 1.2
        
        return HStack(spacing: 5) {
            Spacer()
            ForEach(0..<gameManager.animalWordsReelSymbols.count, id: \.self) { index in
                animalWordsReelView(
                    symbol: gameManager.animalWordsReelSymbols[index],
                    index: index,
                    width: reelWidth,
                    height: reelHeight
                )
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.9, green: 0.9, blue: 0.9).opacity(0.95),
                            Color(red: 0.8, green: 0.8, blue: 0.8).opacity(0.9)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.8), lineWidth: 3)
        )
    }
    
    private func animalWordsReelView(symbol: AnimalWordsReelSymbol, index: Int, width: CGFloat, height: CGFloat) -> some View {
        Button(action: {
            gameManager.animalWordsToggleLetterSelection(at: index)
        }) {
            ZStack {
                // Reel background
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.95, green: 0.95, blue: 1.0),
                                Color(red: 0.9, green: 0.9, blue: 0.95)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(animalWordsGetBorderColor(for: symbol.animalWordsState), lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                
                // Letter image or spinning animation
                if gameManager.animalWordsIsSpinning {
                    animalWordsSpinningAnimation(width: width, height: height, reelIndex: index)
                } else {
                    animalWordsLetterImage(for: symbol)
                }
                
                // Selection overlay
                if symbol.animalWordsState == .selected {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.3))
                } else if symbol.animalWordsState == .highlighted {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.3))
                } else if symbol.animalWordsState == .used {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.4))
                }
            }
            .frame(width: width, height: height)
            .scaleEffect(symbol.animalWordsState == .selected ? 1.1 : 
                        symbol.animalWordsState == .used ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: symbol.animalWordsState)
        }
        .disabled(gameManager.animalWordsIsSpinning || gameManager.animalWordsCurrentGameState != .selecting)
    }
    
    private func animalWordsLetterImage(for symbol: AnimalWordsReelSymbol) -> some View {
        Group {
            if let image = UIImage(named: symbol.animalWordsImageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(8)
            } else {
                // Fallback text if image not found
                Text(symbol.animalWordsLetter.uppercased())
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    }
    }
}

// MARK: - Slot Machine Spinning Animation
struct AnimalWordsSlotMachineSpinningView: View {
    let reelIndex: Int
    let width: CGFloat
    let height: CGFloat
    
    @State private var animalWordsCurrentLetterIndex: Int = 0
    @State private var animalWordsSpinTimer: Timer?
    @State private var animalWordsSpinSpeed: Double = 0.05
    @State private var animalWordsIsJumping: Bool = false
    
    private let animalWordsAlphabet = Array("abcdefghijklmnopqrstuvwxyz")
    
    var body: some View {
        VStack {
            Image("letters-\(animalWordsAlphabet[animalWordsCurrentLetterIndex])")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width * 0.75, height: height * 0.75)
                .scaleEffect(animalWordsIsJumping ? 1.3 : 1.0)
                .rotationEffect(.degrees(animalWordsIsJumping ? Double.random(in: -10...10) : 0))
                .animation(.easeInOut(duration: 0.08), value: animalWordsIsJumping)
                .id("letter-\(animalWordsCurrentLetterIndex)") // Force view update
        }
        .frame(width: width, height: height)
        .onAppear {
            startSpinning()
        }
        .onDisappear {
            stopSpinning()
        }
    }
    
    private func startSpinning() {
        // Start with fast spinning
        scheduleNextSpin()
        
        // Each reel stops at different times for realistic effect
        let baseDelay = Double(reelIndex) * 0.3
        
        // Gradually slow down the spinning
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 + baseDelay) {
            self.animalWordsSpinSpeed = 0.08
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + baseDelay) {
            self.animalWordsSpinSpeed = 0.12
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5 + baseDelay) {
            self.animalWordsSpinSpeed = 0.18
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0 + baseDelay) {
            self.animalWordsSpinSpeed = 0.25
            
            // Stop spinning after total delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.stopSpinning()
            }
        }
    }
    
    private func scheduleNextSpin() {
        animalWordsSpinTimer = Timer.scheduledTimer(withTimeInterval: animalWordsSpinSpeed, repeats: false) { _ in
            // Trigger jump animation
            withAnimation(.easeInOut(duration: 0.05)) {
                self.animalWordsIsJumping = true
            }
            
            // Change letter and reset jump after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.animalWordsCurrentLetterIndex = Int.random(in: 0..<self.animalWordsAlphabet.count)
                
                withAnimation(.easeInOut(duration: 0.05)) {
                    self.animalWordsIsJumping = false
                }
            }
            
            // Continue spinning if speed is still fast enough
            if self.animalWordsSpinSpeed < 0.3 {
                self.scheduleNextSpin()
            }
        }
    }
    
    private func stopSpinning() {
        animalWordsSpinTimer?.invalidate()
        animalWordsSpinTimer = nil
    }
}
    
    private func animalWordsSpinningAnimation(width: CGFloat, height: CGFloat, reelIndex: Int) -> some View {
        AnimalWordsSlotMachineSpinningView(reelIndex: reelIndex, width: width, height: height)
    }
    
    private func animalWordsGetBorderColor(for state: AnimalWordsLetterState) -> Color {
        switch state {
        case .normal:
            return Color.gray.opacity(0.3)
        case .selected:
            return Color.green
        case .highlighted:
            return Color.orange
        case .used:
            return Color.red.opacity(0.6)
        }
    }
    
    // MARK: - Spin Button
    private var animalWordsSpinButton: some View {
        Button(action: {
            gameManager.animalWordsSpin()
        }) {
            HStack(spacing: 10) {
                Image(systemName: gameManager.animalWordsIsSpinning ? "arrow.triangle.2.circlepath" : "arrow.clockwise.circle.fill")
                    .font(.title2)
                    .rotationEffect(.degrees(gameManager.animalWordsIsSpinning ? 360 : 0))
                    .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: gameManager.animalWordsIsSpinning)
                Text(gameManager.animalWordsIsSpinning ? "SPINNING..." : "SPIN")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                Capsule()
                    .fill(gameManager.animalWordsIsSpinning ? Color.gray : Color.red)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            )
        }
        .disabled(gameManager.animalWordsIsSpinning || (gameManager.animalWordsCurrentGameState != .playing && gameManager.animalWordsCurrentGameState != .selecting))
        .scaleEffect(gameManager.animalWordsIsSpinning ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: gameManager.animalWordsIsSpinning)
    }
    
    // MARK: - Selected Word Section
    private var animalWordsSelectedWordSection: some View {
        VStack(spacing: 10) {
            Text("Selected Word")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            Text(gameManager.animalWordsGetSelectedWord().isEmpty ? "Select letters to form a word" : gameManager.animalWordsGetSelectedWord())
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .padding(.vertical, 15)
    }
    
    // MARK: - Control Buttons Section
    private func animalWordsControlButtonsSection(geometry: GeometryProxy) -> some View {
        HStack(spacing: 20) {
            // Clear Selection Button
            animalWordsControlButton(
                title: "Clear",
                icon: "xmark.circle",
                color: .orange,
                action: {
                    gameManager.animalWordsClearSelection()
                }
            )
            .disabled(gameManager.animalWordsSelectedLetters.isEmpty)
            
            // Submit Word Button
            animalWordsControlButton(
                title: "Submit",
                icon: "checkmark.circle",
                color: .green,
                action: {
                    gameManager.animalWordsSubmitSelectedWord()
                }
            )
            .disabled(gameManager.animalWordsSelectedLetters.count < 2)
        }
        .padding(.bottom, 20)
    }
    
    private func animalWordsControlButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(color)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
            )
        }
        .buttonStyle(AnimalWordsBouncyButtonStyle())
    }
    
    // MARK: - Found Words Section
    private func animalWordsFoundWordsSection(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if !gameManager.animalWordsFoundWords.isEmpty {
                Text("Found Words (\(gameManager.animalWordsFoundWords.count))")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(gameManager.animalWordsFoundWords, id: \.self) { word in
                            Text(word.uppercased())
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.9))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 40)
            }
        }
    }
    
    // MARK: - Validation Alert
    private var animalWordsValidationAlert: some View {
        Group {
            if gameManager.animalWordsShowValidationAlert {
                Text(gameManager.animalWordsLastValidationMessage)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.8))
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: -2)
                    )
                    .padding(.bottom, 120)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: gameManager.animalWordsShowValidationAlert)
            }
        }
    }
} 