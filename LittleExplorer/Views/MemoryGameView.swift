import SwiftUI

struct MemoryGameView: View {
    @EnvironmentObject var userProgress: UserProgress
    @Environment(\.dismiss) private var dismiss

    @State private var cards: [MemoryCard] = []
    @State private var firstFlippedIndex: Int?
    @State private var secondFlippedIndex: Int?
    @State private var moves = 0
    @State private var matchedPairs = 0
    @State private var isProcessing = false
    @State private var gameComplete = false
    @State private var difficulty: MemoryDifficulty = .easy
    @State private var showDifficultyPicker = true
    @State private var timer: Timer?
    @State private var timeElapsed = 0

    var body: some View {
        ZStack {
            ThemeColors.memoryGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                if showDifficultyPicker {
                    difficultyPickerView
                } else if gameComplete {
                    gameCompleteView
                } else {
                    gameHeaderView
                    gameGridView
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: handleBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("返回")
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.white.opacity(0.3)))
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Difficulty Picker
    private var difficultyPickerView: some View {
        VStack(spacing: 30) {
            Text("🧠 记忆配对")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Memory Match")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            Text("选择难度")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))

            VStack(spacing: 15) {
                ForEach(MemoryDifficulty.allCases, id: \.self) { diff in
                    Button(action: {
                        difficulty = diff
                        startGame()
                    }) {
                        HStack {
                            Image(systemName: diff.icon)
                                .font(.system(size: 30))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(diff.rawValue)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                Text(diff.description)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .opacity(0.8)
                            }

                            Spacer()

                            Text("\(diff.pairs) 对")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(diff.color)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white.opacity(0.95))
                                .shadow(color: diff.color.opacity(0.3), radius: 8, y: 4)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Game Header
    private var gameHeaderView: some View {
        HStack {
            // Moves counter
            HStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                Text("\(moves)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text("步")
            }
            .foregroundStyle(ThemeColors.deepPurple)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Capsule().fill(.white.opacity(0.9)))

            Spacer()

            // Timer
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                Text(timeString)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            .foregroundStyle(ThemeColors.deepPurple)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Capsule().fill(.white.opacity(0.9)))

            Spacer()

            // Pairs found
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("\(matchedPairs)/\(difficulty.pairs)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            .foregroundStyle(ThemeColors.deepPurple)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Capsule().fill(.white.opacity(0.9)))
        }
    }

    // MARK: - Game Grid
    private var gameGridView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: difficulty.columns)

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(cards.indices, id: \.self) { index in
                MemoryCardView(
                    card: cards[index],
                    isFlipped: cards[index].isFaceUp || cards[index].isMatched
                ) {
                    flipCard(at: index)
                }
                .aspectRatio(1, contentMode: .fit)
            }
        }
        .padding(.horizontal, 10)
    }

    // MARK: - Game Complete
    private var gameCompleteView: some View {
        VStack(spacing: 25) {
            Text("🎉")
                .font(.system(size: 80))

            Text("太棒了！")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            // Stats
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "clock.fill")
                    Text("用时: \(timeString)")
                }
                .font(.system(size: 22, weight: .medium, design: .rounded))

                HStack {
                    Image(systemName: "hand.tap.fill")
                    Text("步数: \(moves)")
                }
                .font(.system(size: 22, weight: .medium, design: .rounded))
            }
            .foregroundStyle(.white)

            // Stars
            HStack(spacing: 10) {
                ForEach(0..<3) { index in
                    AnimatedStarView(filled: starsEarned > index)
                }
            }

            Text("获得 \(starsEarned) 颗星星！")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(ThemeColors.sunshineYellow)

            HStack(spacing: 15) {
                Button(action: {
                    showDifficultyPicker = true
                    resetGame()
                }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("换难度")
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(ThemeColors.deepPurple)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.2), radius: 5)
                    )
                }

                Button(action: startGame) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("再玩一次")
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(ThemeColors.deepPurple)
                            .shadow(color: .purple.opacity(0.4), radius: 5)
                    )
                }
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.white.opacity(0.2))
        )
    }

    // MARK: - Helper Properties
    private var timeString: String {
        let minutes = timeElapsed / 60
        let seconds = timeElapsed % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var starsEarned: Int {
        let perfectMoves = difficulty.pairs * 2
        let ratio = Double(perfectMoves) / Double(max(moves, 1))

        if ratio >= 0.8 { return 3 }
        if ratio >= 0.5 { return 2 }
        if ratio >= 0.3 { return 1 }
        return 0
    }

    // MARK: - Functions
    private func handleBack() {
        if gameComplete || !showDifficultyPicker {
            showDifficultyPicker = true
            resetGame()
        } else {
            dismiss()
        }
    }

    private func startGame() {
        cards = MemoryCard.createPairs(count: difficulty.pairs)
        moves = 0
        matchedPairs = 0
        timeElapsed = 0
        gameComplete = false
        showDifficultyPicker = false
        firstFlippedIndex = nil
        secondFlippedIndex = nil

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeElapsed += 1
        }
    }

    private func resetGame() {
        timer?.invalidate()
        cards = []
        moves = 0
        matchedPairs = 0
        timeElapsed = 0
        gameComplete = false
        firstFlippedIndex = nil
        secondFlippedIndex = nil
    }

    private func flipCard(at index: Int) {
        guard !isProcessing,
              !cards[index].isFaceUp,
              !cards[index].isMatched else { return }

        withAnimation(.spring(response: 0.4)) {
            cards[index].isFaceUp = true
        }

        if firstFlippedIndex == nil {
            firstFlippedIndex = index
        } else if secondFlippedIndex == nil {
            secondFlippedIndex = index
            moves += 1
            checkForMatch()
        }
    }

    private func checkForMatch() {
        guard let first = firstFlippedIndex,
              let second = secondFlippedIndex else { return }

        isProcessing = true

        if cards[first].content == cards[second].content {
            // Match found
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring()) {
                    cards[first].isMatched = true
                    cards[second].isMatched = true
                    matchedPairs += 1

                    if matchedPairs == difficulty.pairs {
                        completeGame()
                    }
                }
                resetFlippedCards()
            }
        } else {
            // No match
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.spring(response: 0.4)) {
                    cards[first].isFaceUp = false
                    cards[second].isFaceUp = false
                }
                resetFlippedCards()
            }
        }
    }

    private func resetFlippedCards() {
        firstFlippedIndex = nil
        secondFlippedIndex = nil
        isProcessing = false
    }

    private func completeGame() {
        timer?.invalidate()
        gameComplete = true

        userProgress.addStars(starsEarned)
        if moves < userProgress.memoryBestScore || userProgress.memoryBestScore == 0 {
            userProgress.memoryBestScore = moves
        }
    }
}

// MARK: - Memory Card View
struct MemoryCardView: View {
    let card: MemoryCard
    let isFlipped: Bool
    let action: () -> Void

    @State private var rotation: Double = 0

    var body: some View {
        Button(action: action) {
            ZStack {
                // Back of card (princess themed)
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [ThemeColors.brightPink, ThemeColors.deepPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        VStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 25))
                            Text("?")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                    )
                    .opacity(isFlipped ? 0 : 1)

                // Front of card
                RoundedRectangle(cornerRadius: 15)
                    .fill(.white)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: card.symbol)
                                .font(.system(size: 35))
                                .foregroundStyle(ThemeColors.deepPurple)

                            Text(card.content)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.gray)
                        }
                    )
                    .opacity(isFlipped ? 1 : 0)
            }
            .shadow(color: card.isMatched ? .green.opacity(0.5) : .black.opacity(0.2), radius: 5, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(card.isMatched ? Color.green : Color.clear, lineWidth: 3)
            )
        }
        .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.4), value: isFlipped)
        .disabled(card.isMatched)
    }
}

// MARK: - Difficulty Enum
enum MemoryDifficulty: String, CaseIterable {
    case easy = "简单"
    case medium = "中等"
    case hard = "困难"

    var pairs: Int {
        switch self {
        case .easy: return 4
        case .medium: return 6
        case .hard: return 8
        }
    }

    var columns: Int {
        switch self {
        case .easy: return 4
        case .medium: return 4
        case .hard: return 4
        }
    }

    var icon: String {
        switch self {
        case .easy: return "star"
        case .medium: return "star.leadinghalf.filled"
        case .hard: return "star.fill"
        }
    }

    var description: String {
        switch self {
        case .easy: return "4对卡片"
        case .medium: return "6对卡片"
        case .hard: return "8对卡片"
        }
    }

    var color: Color {
        switch self {
        case .easy: return ThemeColors.mintGreen
        case .medium: return ThemeColors.sunshineYellow
        case .hard: return ThemeColors.coralOrange
        }
    }
}

#Preview {
    NavigationStack {
        MemoryGameView()
            .environmentObject(UserProgress())
    }
}
