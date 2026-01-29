import SwiftUI

struct MathGameView: View {
    @EnvironmentObject var userProgress: UserProgress
    @Environment(\.dismiss) private var dismiss

    @State private var currentProblem: MathProblem = MathProblem.generate()
    @State private var choices: [Int] = []
    @State private var score = 0
    @State private var questionsAnswered = 0
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showCelebration = false
    @State private var difficulty = 1
    @State private var streak = 0

    private let totalQuestions = 10

    var body: some View {
        ZStack {
            // Background
            ThemeColors.mathGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                headerView

                Spacer()

                if questionsAnswered < totalQuestions {
                    // Question card
                    questionCard

                    // Answer choices
                    answerChoicesView
                } else {
                    // Game complete view
                    gameCompleteView
                }

                Spacer()
            }
            .padding()

            // Celebration overlay
            if showCelebration {
                celebrationOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
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
        .onAppear {
            generateNewProblem()
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // Score
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundStyle(ThemeColors.sunshineYellow)
                Text("\(score)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(.white.opacity(0.9)))

            Spacer()

            // Progress
            HStack(spacing: 8) {
                Text("第")
                Text("\(questionsAnswered + 1)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("/ \(totalQuestions) 题")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(.white.opacity(0.9)))

            Spacer()

            // Streak indicator
            if streak >= 3 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(streak)")
                        .font(.system(size: 20, weight: .bold))
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Capsule().fill(.white.opacity(0.9)))
            }
        }
        .foregroundStyle(ThemeColors.deepPurple)
    }

    // MARK: - Question Card
    private var questionCard: some View {
        VStack(spacing: 20) {
            // Cute math emoji
            Text("🔢")
                .font(.system(size: 60))

            // Problem display
            Text(currentProblem.questionText)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(ThemeColors.deepPurple)

            // Result feedback
            if showResult {
                HStack(spacing: 10) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 30))
                    Text(isCorrect ? "太棒了！" : "再试试！答案是 \(currentProblem.answer)")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(isCorrect ? .green : .red)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.white.opacity(0.95))
                .shadow(color: .orange.opacity(0.3), radius: 15)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Answer Choices
    private var answerChoicesView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 15),
            GridItem(.flexible(), spacing: 15)
        ], spacing: 15) {
            ForEach(choices, id: \.self) { choice in
                Button(action: { checkAnswer(choice) }) {
                    Text("\(choice)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [ThemeColors.coralOrange, ThemeColors.brightPink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .orange.opacity(0.4), radius: 8, y: 4)
                        )
                }
                .disabled(showResult)
                .opacity(showResult ? 0.7 : 1)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Game Complete View
    private var gameCompleteView: some View {
        VStack(spacing: 25) {
            Text("🎉")
                .font(.system(size: 80))

            Text("太棒了！")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(ThemeColors.deepPurple)

            Text("你完成了所有题目！")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(ThemeColors.deepPurple.opacity(0.8))

            // Stars earned
            HStack(spacing: 10) {
                ForEach(0..<3) { index in
                    AnimatedStarView(filled: score >= (index + 1) * 3)
                }
            }

            // Score summary
            VStack(spacing: 10) {
                Text("得分: \(score) / \(totalQuestions)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("获得 \(starsEarned) 颗星星！")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
            }
            .foregroundStyle(ThemeColors.deepPurple)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.9))
            )

            // Play again button
            Button(action: restartGame) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("再玩一次")
                }
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                .background(
                    Capsule()
                        .fill(ThemeColors.deepPurple)
                        .shadow(color: .purple.opacity(0.4), radius: 8, y: 4)
                )
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.white.opacity(0.95))
                .shadow(color: .orange.opacity(0.3), radius: 15)
        )
        .padding(.horizontal, 20)
        .onAppear {
            userProgress.addStars(starsEarned)
            userProgress.mathScore += score
        }
    }

    // MARK: - Celebration Overlay
    private var celebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack {
                Text("🌟")
                    .font(.system(size: 100))
                Text("连续答对 \(streak) 题!")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .transition(.scale)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showCelebration = false
                }
            }
        }
    }

    // MARK: - Helper Properties
    private var starsEarned: Int {
        if score >= 9 { return 3 }
        if score >= 6 { return 2 }
        if score >= 3 { return 1 }
        return 0
    }

    // MARK: - Functions
    private func generateNewProblem() {
        currentProblem = MathProblem.generate(difficulty: difficulty)
        choices = currentProblem.generateChoices()
        showResult = false
    }

    private func checkAnswer(_ answer: Int) {
        isCorrect = answer == currentProblem.answer

        withAnimation(.spring()) {
            showResult = true

            if isCorrect {
                score += 1
                streak += 1

                if streak == 5 || streak == 10 {
                    showCelebration = true
                }

                // Increase difficulty after consecutive correct answers
                if streak >= 5 {
                    difficulty = min(difficulty + 1, 3)
                }
            } else {
                streak = 0
                difficulty = max(difficulty - 1, 1)
            }
        }

        // Move to next question after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                questionsAnswered += 1
                if questionsAnswered < totalQuestions {
                    generateNewProblem()
                }
            }
        }
    }

    private func restartGame() {
        score = 0
        questionsAnswered = 0
        streak = 0
        difficulty = 1
        generateNewProblem()
    }
}

#Preview {
    NavigationStack {
        MathGameView()
            .environmentObject(UserProgress())
    }
}
