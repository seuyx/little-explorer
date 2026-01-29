import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userProgress: UserProgress
    @State private var showStarAnimation = false
    @State private var selectedGame: GameType?

    var body: some View {
        ZStack {
            // Beautiful gradient background
            ThemeColors.princessGradient
                .ignoresSafeArea()

            // Floating decorations
            FloatingHeartsView()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // Header with crown and title
                    headerSection

                    // Star counter
                    starCounterView

                    // Game cards grid
                    gameCardsSection

                    Spacer(minLength: 30)
                }
                .padding()
            }
        }
        .navigationDestination(item: $selectedGame) { game in
            destinationView(for: game)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 10) {
            HStack {
                SparkleView(size: 25)
                CrownView()
                SparkleView(size: 25)
            }

            Text("小小探险家")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ThemeColors.deepPurple, ThemeColors.brightPink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .white.opacity(0.8), radius: 2)

            Text("Little Explorer")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(ThemeColors.deepPurple.opacity(0.7))

            // Cute princess emoji decoration
            HStack(spacing: 15) {
                Text("👸")
                    .font(.system(size: 35))
                Text("✨")
                    .font(.system(size: 25))
                Text("🦄")
                    .font(.system(size: 35))
                Text("✨")
                    .font(.system(size: 25))
                Text("🌸")
                    .font(.system(size: 35))
            }
            .padding(.top, 5)
        }
        .padding(.top, 20)
    }

    // MARK: - Star Counter
    private var starCounterView: some View {
        HStack(spacing: 15) {
            Image(systemName: "star.fill")
                .font(.system(size: 30))
                .foregroundStyle(ThemeColors.sunshineYellow)
                .shadow(color: .orange.opacity(0.5), radius: 3)

            Text("\(userProgress.totalStars)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(ThemeColors.deepPurple)

            Text("颗星星")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(ThemeColors.deepPurple.opacity(0.8))
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 15)
        .background(
            Capsule()
                .fill(.white.opacity(0.9))
                .shadow(color: ThemeColors.brightPink.opacity(0.3), radius: 10)
        )
        .scaleEffect(showStarAnimation ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: showStarAnimation)
    }

    // MARK: - Game Cards Section
    private var gameCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 20),
            GridItem(.flexible(), spacing: 20)
        ], spacing: 20) {
            ForEach(GameType.allCases, id: \.self) { game in
                GameCardView(game: game) {
                    selectedGame = game
                }
            }
        }
        .padding(.horizontal, 10)
    }

    @ViewBuilder
    private func destinationView(for game: GameType) -> some View {
        switch game {
        case .math:
            MathGameView()
        case .chinese:
            ChineseLearningView()
        case .english:
            EnglishLearningView()
        case .memory:
            MemoryGameView()
        case .drawing:
            DrawingCanvasView()
        }
    }
}

// MARK: - Game Type Enum
enum GameType: String, CaseIterable, Identifiable {
    case math = "数学乐园"
    case chinese = "汉字王国"
    case english = "英语天地"
    case memory = "记忆配对"
    case drawing = "创意画板"

    var id: String { rawValue }

    var englishName: String {
        switch self {
        case .math: return "Math Fun"
        case .chinese: return "Chinese"
        case .english: return "English"
        case .memory: return "Memory"
        case .drawing: return "Drawing"
        }
    }

    var icon: String {
        switch self {
        case .math: return "plus.forwardslash.minus"
        case .chinese: return "character.book.closed.fill.zh"
        case .english: return "a.book.closed.fill"
        case .memory: return "square.grid.2x2.fill"
        case .drawing: return "paintbrush.fill"
        }
    }

    var emoji: String {
        switch self {
        case .math: return "🔢"
        case .chinese: return "📚"
        case .english: return "🔤"
        case .memory: return "🧠"
        case .drawing: return "🎨"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .math: return ThemeColors.mathGradient
        case .chinese: return ThemeColors.chineseGradient
        case .english: return ThemeColors.englishGradient
        case .memory: return ThemeColors.memoryGradient
        case .drawing: return ThemeColors.drawingGradient
        }
    }

    var description: String {
        switch self {
        case .math: return "加减法练习"
        case .chinese: return "学习汉字"
        case .english: return "学习单词"
        case .memory: return "翻牌配对"
        case .drawing: return "自由绘画"
        }
    }
}

// MARK: - Game Card View
struct GameCardView: View {
    let game: GameType
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Emoji and icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 70, height: 70)

                    Text(game.emoji)
                        .font(.system(size: 40))
                }

                // Game name
                Text(game.rawValue)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(game.englishName)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))

                // Description
                Text(game.description)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.2))
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 25)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(game.gradient)
                    .shadow(color: game.gradient.stops.first?.color.opacity(0.4) ?? .clear, radius: 10, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(.white.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(GameCardStyle(gradient: game.gradient))
    }
}

extension LinearGradient {
    var stops: [Gradient.Stop] {
        []
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(UserProgress())
    }
}
