import SwiftUI

struct EnglishLearningView: View {
    @EnvironmentObject var userProgress: UserProgress
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: EnglishCategory?
    @State private var currentWordIndex = 0
    @State private var showSpelling = false
    @State private var spellingInput = ""
    @State private var spellingScore = 0
    @State private var spellingQuestions = 0
    @State private var showSpellingResult = false
    @State private var isSpellingCorrect = false
    @State private var showFlashcard = true

    private var filteredWords: [EnglishWord] {
        guard let category = selectedCategory else {
            return EnglishWord.grade2Words
        }
        return EnglishWord.grade2Words.filter { $0.category == category }
    }

    var body: some View {
        ZStack {
            ThemeColors.englishGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                if selectedCategory == nil {
                    categorySelectionView
                } else if showSpelling {
                    spellingGameView
                } else {
                    flashcardView
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
            Text("🔤 英语天地")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("English World")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            Text("选择学习类别")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15)
            ], spacing: 15) {
                ForEach(EnglishCategory.allCases, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        VStack(spacing: 10) {
                            Image(systemName: category.icon)
                                .font(.system(size: 30))
                                .foregroundStyle(category.color)

                            Text(category.rawValue)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(ThemeColors.deepPurple)

                            Text(category.chineseName)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.white.opacity(0.95))
                                .shadow(color: category.color.opacity(0.3), radius: 6, y: 3)
                        )
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }

    // MARK: - Flashcard View
    private var flashcardView: some View {
        VStack(spacing: 20) {
            // Category header
            HStack {
                Image(systemName: selectedCategory?.icon ?? "book")
                    .font(.system(size: 22))
                Text(selectedCategory?.rawValue ?? "")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text("(\(selectedCategory?.chineseName ?? ""))")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .opacity(0.8)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(.white.opacity(0.3)))

            // Progress
            Text("\(currentWordIndex + 1) / \(filteredWords.count)")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            // Flashcard
            if currentWordIndex < filteredWords.count {
                wordFlashcard(filteredWords[currentWordIndex])
            }

            // Navigation and spelling button
            HStack(spacing: 20) {
                Button(action: previousWord) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(currentWordIndex > 0 ? 1 : 0.3))
                }
                .disabled(currentWordIndex == 0)

                Button(action: { showSpelling = true }) {
                    HStack {
                        Image(systemName: "keyboard")
                        Text("拼写练习")
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

                Button(action: nextWord) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(currentWordIndex < filteredWords.count - 1 ? 1 : 0.3))
                }
                .disabled(currentWordIndex >= filteredWords.count - 1)
            }
        }
    }

    // MARK: - Word Flashcard
    private func wordFlashcard(_ word: EnglishWord) -> some View {
        VStack(spacing: 25) {
            // Icon
            if word.category == .colors {
                Circle()
                    .fill(colorForWord(word.word))
                    .frame(width: 80, height: 80)
                    .shadow(color: colorForWord(word.word).opacity(0.5), radius: 10)
            } else {
                Image(systemName: word.imageSymbol)
                    .font(.system(size: 60))
                    .foregroundStyle(word.category.color)
            }

            // English word
            Text(word.word)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(ThemeColors.deepPurple)

            // Chinese meaning
            HStack(spacing: 8) {
                Text("中文:")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.gray)
                Text(word.meaning)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(ThemeColors.coralOrange)
            }

            // Tap to hear (placeholder for future audio)
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                Text("点击朗读")
            }
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(ThemeColors.magicBlue)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .stroke(ThemeColors.magicBlue, lineWidth: 2)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.white.opacity(0.95))
                .shadow(color: ThemeColors.deepPurple.opacity(0.3), radius: 15)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Spelling Game View
    private var spellingGameView: some View {
        VStack(spacing: 25) {
            Text("⌨️ 拼写练习")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            // Score
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(ThemeColors.sunshineYellow)
                Text("\(spellingScore) / \(spellingQuestions)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(.white.opacity(0.3)))

            if spellingQuestions < 5 {
                spellingQuestionView
            } else {
                spellingCompleteView
            }
        }
    }

    // MARK: - Spelling Question
    private var spellingQuestionView: some View {
        let word = filteredWords[spellingQuestions % filteredWords.count]

        return VStack(spacing: 20) {
            // Question card
            VStack(spacing: 15) {
                Text("请拼写这个单词:")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.gray)

                Text(word.meaning)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(ThemeColors.deepPurple)

                if word.category == .colors {
                    Circle()
                        .fill(colorForWord(word.word))
                        .frame(width: 50, height: 50)
                } else {
                    Image(systemName: word.imageSymbol)
                        .font(.system(size: 40))
                        .foregroundStyle(word.category.color)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 25)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.white.opacity(0.95))
            )
            .padding(.horizontal, 20)

            // Text input
            TextField("输入英文单词...", text: $spellingInput)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.white)
                )
                .padding(.horizontal, 40)

            // Check button
            Button(action: { checkSpelling(word: word) }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("检查答案")
                }
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 35)
                .padding(.vertical, 15)
                .background(
                    Capsule()
                        .fill(ThemeColors.mintGreen)
                        .shadow(color: .green.opacity(0.4), radius: 5)
                )
            }

            // Result feedback
            if showSpellingResult {
                VStack(spacing: 8) {
                    Text(isSpellingCorrect ? "太棒了！ ✨" : "正确答案是:")
                        .font(.system(size: 20, weight: .medium, design: .rounded))

                    if !isSpellingCorrect {
                        Text(word.word)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                    }
                }
                .foregroundStyle(.white)
                .padding()
                .background(
                    Capsule()
                        .fill(isSpellingCorrect ? Color.green : Color.red)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Spelling Complete
    private var spellingCompleteView: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 70))

            Text("练习完成！")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("得分: \(spellingScore) / 5")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    AnimatedStarView(filled: spellingScore >= (index + 1) * 2)
                }
            }

            Button(action: resetSpelling) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("再练一次")
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
            let stars = spellingScore >= 4 ? 3 : spellingScore >= 2 ? 2 : spellingScore >= 1 ? 1 : 0
            userProgress.addStars(stars)
            userProgress.englishScore += spellingScore
        }
    }

    // MARK: - Helper Functions
    private func colorForWord(_ word: String) -> Color {
        switch word.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "pink": return ThemeColors.brightPink
        case "purple": return .purple
        default: return .gray
        }
    }

    private func handleBack() {
        if showSpelling {
            showSpelling = false
            resetSpelling()
        } else if selectedCategory != nil {
            selectedCategory = nil
            currentWordIndex = 0
        } else {
            dismiss()
        }
    }

    private func nextWord() {
        if currentWordIndex < filteredWords.count - 1 {
            currentWordIndex += 1
        }
    }

    private func previousWord() {
        if currentWordIndex > 0 {
            currentWordIndex -= 1
        }
    }

    private func checkSpelling(word: EnglishWord) {
        isSpellingCorrect = spellingInput.lowercased().trimmingCharacters(in: .whitespaces) == word.word.lowercased()

        if isSpellingCorrect {
            spellingScore += 1
        }

        withAnimation {
            showSpellingResult = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSpellingResult = false
                spellingQuestions += 1
                spellingInput = ""
            }
        }
    }

    private func resetSpelling() {
        spellingScore = 0
        spellingQuestions = 0
        spellingInput = ""
        showSpellingResult = false
    }
}

#Preview {
    NavigationStack {
        EnglishLearningView()
            .environmentObject(UserProgress())
    }
}
