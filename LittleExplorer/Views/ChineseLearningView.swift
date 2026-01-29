import SwiftUI

struct ChineseLearningView: View {
    @EnvironmentObject var userProgress: UserProgress
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: ChineseCategory?
    @State private var currentCharacterIndex = 0
    @State private var showQuiz = false
    @State private var quizScore = 0
    @State private var quizQuestions = 0
    @State private var showAnswer = false
    @State private var selectedAnswer: ChineseCharacter?
    @State private var isCorrect = false

    private var filteredCharacters: [ChineseCharacter] {
        guard let category = selectedCategory else {
            return ChineseCharacter.grade2Characters
        }
        return ChineseCharacter.grade2Characters.filter { $0.category == category }
    }

    var body: some View {
        ZStack {
            ThemeColors.chineseGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                if selectedCategory == nil {
                    categorySelectionView
                } else if showQuiz {
                    quizView
                } else {
                    learningView
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
    }

    // MARK: - Category Selection
    private var categorySelectionView: some View {
        VStack(spacing: 25) {
            Text("📚 汉字王国")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("选择学习类别")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15)
            ], spacing: 15) {
                ForEach(ChineseCategory.allCases, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        VStack(spacing: 12) {
                            Image(systemName: category.icon)
                                .font(.system(size: 35))
                                .foregroundStyle(category.color)

                            Text(category.rawValue)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(ThemeColors.deepPurple)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white.opacity(0.95))
                                .shadow(color: category.color.opacity(0.3), radius: 8, y: 4)
                        )
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }

    // MARK: - Learning View
    private var learningView: some View {
        VStack(spacing: 20) {
            // Category header
            HStack {
                Image(systemName: selectedCategory?.icon ?? "book")
                    .font(.system(size: 24))
                Text(selectedCategory?.rawValue ?? "")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(.white.opacity(0.3)))

            // Progress indicator
            Text("\(currentCharacterIndex + 1) / \(filteredCharacters.count)")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            // Character card
            if currentCharacterIndex < filteredCharacters.count {
                characterCard(filteredCharacters[currentCharacterIndex])
            }

            // Navigation buttons
            HStack(spacing: 20) {
                Button(action: previousCharacter) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(currentCharacterIndex > 0 ? 1 : 0.3))
                }
                .disabled(currentCharacterIndex == 0)

                Button(action: { showQuiz = true }) {
                    HStack {
                        Image(systemName: "pencil.and.list.clipboard")
                        Text("开始测验")
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

                Button(action: nextCharacter) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(currentCharacterIndex < filteredCharacters.count - 1 ? 1 : 0.3))
                }
                .disabled(currentCharacterIndex >= filteredCharacters.count - 1)
            }
        }
    }

    // MARK: - Character Card
    private func characterCard(_ character: ChineseCharacter) -> some View {
        VStack(spacing: 20) {
            // Main character
            Text(character.character)
                .font(.system(size: 120, weight: .medium))
                .foregroundStyle(ThemeColors.deepPurple)

            // Pinyin
            Text(character.pinyin)
                .font(.system(size: 32, weight: .medium, design: .rounded))
                .foregroundStyle(ThemeColors.coralOrange)

            // Meaning
            HStack(spacing: 10) {
                Text("意思:")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.gray)
                Text(character.meaning)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(ThemeColors.deepPurple)
            }

            // Stroke count
            HStack(spacing: 10) {
                Image(systemName: "pencil.line")
                    .foregroundStyle(ThemeColors.brightPink)
                Text("\(character.strokeCount) 笔画")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.white.opacity(0.95))
                .shadow(color: ThemeColors.coralOrange.opacity(0.3), radius: 15)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Quiz View
    private var quizView: some View {
        VStack(spacing: 25) {
            // Quiz header
            Text("🎯 汉字测验")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            // Score
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(ThemeColors.sunshineYellow)
                Text("\(quizScore) / \(quizQuestions)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(.white.opacity(0.3)))

            if quizQuestions < 5 {
                quizQuestionView
            } else {
                quizCompleteView
            }
        }
    }

    // MARK: - Quiz Question
    private var quizQuestionView: some View {
        let correctCharacter = filteredCharacters.randomElement()!
        let wrongAnswers = filteredCharacters
            .filter { $0.id != correctCharacter.id }
            .shuffled()
            .prefix(3)
        let allAnswers = ([correctCharacter] + wrongAnswers).shuffled()

        return VStack(spacing: 20) {
            // Question
            VStack(spacing: 15) {
                Text("这个字的拼音是什么？")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(.gray)

                Text(correctCharacter.character)
                    .font(.system(size: 80, weight: .medium))
                    .foregroundStyle(ThemeColors.deepPurple)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.white.opacity(0.95))
            )
            .padding(.horizontal, 20)

            // Answer choices
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15)
            ], spacing: 15) {
                ForEach(allAnswers) { answer in
                    Button(action: {
                        checkQuizAnswer(selected: answer, correct: correctCharacter)
                    }) {
                        Text(answer.pinyin)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(answerColor(for: answer, correct: correctCharacter))
                            )
                    }
                    .disabled(showAnswer)
                }
            }
            .padding(.horizontal, 20)

            // Feedback
            if showAnswer {
                Text(isCorrect ? "太棒了！✨" : "正确答案是: \(correctCharacter.pinyin)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding()
                    .background(
                        Capsule()
                            .fill(isCorrect ? Color.green : Color.red)
                    )
            }
        }
    }

    private func answerColor(for answer: ChineseCharacter, correct: ChineseCharacter) -> Color {
        if !showAnswer {
            return ThemeColors.deepPurple
        }
        if answer.id == correct.id {
            return .green
        }
        if answer.id == selectedAnswer?.id {
            return .red
        }
        return ThemeColors.deepPurple.opacity(0.5)
    }

    // MARK: - Quiz Complete
    private var quizCompleteView: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 70))

            Text("测验完成！")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("得分: \(quizScore) / 5")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    AnimatedStarView(filled: quizScore >= (index + 1) * 2)
                }
            }

            Button(action: resetQuiz) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("再测一次")
                }
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(ThemeColors.deepPurple)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(
                    Capsule()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.2), radius: 5)
                )
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.white.opacity(0.2))
        )
        .onAppear {
            let stars = quizScore >= 4 ? 3 : quizScore >= 2 ? 2 : quizScore >= 1 ? 1 : 0
            userProgress.addStars(stars)
            userProgress.chineseScore += quizScore
        }
    }

    // MARK: - Functions
    private func handleBack() {
        if showQuiz {
            showQuiz = false
            resetQuiz()
        } else if selectedCategory != nil {
            selectedCategory = nil
            currentCharacterIndex = 0
        } else {
            dismiss()
        }
    }

    private func nextCharacter() {
        if currentCharacterIndex < filteredCharacters.count - 1 {
            currentCharacterIndex += 1
        }
    }

    private func previousCharacter() {
        if currentCharacterIndex > 0 {
            currentCharacterIndex -= 1
        }
    }

    private func checkQuizAnswer(selected: ChineseCharacter, correct: ChineseCharacter) {
        selectedAnswer = selected
        isCorrect = selected.id == correct.id

        if isCorrect {
            quizScore += 1
        }

        withAnimation {
            showAnswer = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showAnswer = false
                quizQuestions += 1
                selectedAnswer = nil
            }
        }
    }

    private func resetQuiz() {
        quizScore = 0
        quizQuestions = 0
        showAnswer = false
        selectedAnswer = nil
    }
}

#Preview {
    NavigationStack {
        ChineseLearningView()
            .environmentObject(UserProgress())
    }
}
