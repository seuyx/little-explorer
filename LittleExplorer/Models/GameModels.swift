import SwiftUI

// MARK: - Math Game Models
struct MathProblem {
    let num1: Int
    let num2: Int
    let operation: MathOperation
    let answer: Int

    var questionText: String {
        "\(num1) \(operation.symbol) \(num2) = ?"
    }

    static func generate(difficulty: Int = 1) -> MathProblem {
        let operations: [MathOperation] = difficulty > 2 ? [.add, .subtract, .multiply] : [.add, .subtract]
        let operation = operations.randomElement() ?? .add

        let maxNum = min(10 + (difficulty * 5), 50)
        var num1 = Int.random(in: 1...maxNum)
        var num2 = Int.random(in: 1...maxNum)

        // Ensure subtraction doesn't go negative for young kids
        if operation == .subtract && num2 > num1 {
            swap(&num1, &num2)
        }

        // Keep multiplication simpler
        if operation == .multiply {
            num1 = Int.random(in: 1...10)
            num2 = Int.random(in: 1...10)
        }

        let answer: Int
        switch operation {
        case .add:
            answer = num1 + num2
        case .subtract:
            answer = num1 - num2
        case .multiply:
            answer = num1 * num2
        }

        return MathProblem(num1: num1, num2: num2, operation: operation, answer: answer)
    }

    func generateChoices() -> [Int] {
        var choices = Set<Int>()
        choices.insert(answer)

        while choices.count < 4 {
            let offset = Int.random(in: -5...5)
            if offset != 0 {
                let wrong = answer + offset
                if wrong >= 0 {
                    choices.insert(wrong)
                }
            }
        }

        return Array(choices).shuffled()
    }
}

enum MathOperation {
    case add, subtract, multiply

    var symbol: String {
        switch self {
        case .add: return "+"
        case .subtract: return "-"
        case .multiply: return "×"
        }
    }
}

// MARK: - Chinese Learning Models
struct ChineseCharacter: Identifiable {
    let id = UUID()
    let character: String
    let pinyin: String
    let meaning: String
    let strokeCount: Int
    let category: ChineseCategory

    static let grade2Characters: [ChineseCharacter] = [
        // Animals
        ChineseCharacter(character: "猫", pinyin: "māo", meaning: "cat", strokeCount: 11, category: .animals),
        ChineseCharacter(character: "狗", pinyin: "gǒu", meaning: "dog", strokeCount: 8, category: .animals),
        ChineseCharacter(character: "鸟", pinyin: "niǎo", meaning: "bird", strokeCount: 5, category: .animals),
        ChineseCharacter(character: "鱼", pinyin: "yú", meaning: "fish", strokeCount: 8, category: .animals),
        ChineseCharacter(character: "马", pinyin: "mǎ", meaning: "horse", strokeCount: 3, category: .animals),
        ChineseCharacter(character: "牛", pinyin: "niú", meaning: "cow", strokeCount: 4, category: .animals),
        ChineseCharacter(character: "羊", pinyin: "yáng", meaning: "sheep", strokeCount: 6, category: .animals),
        ChineseCharacter(character: "兔", pinyin: "tù", meaning: "rabbit", strokeCount: 8, category: .animals),

        // Nature
        ChineseCharacter(character: "花", pinyin: "huā", meaning: "flower", strokeCount: 7, category: .nature),
        ChineseCharacter(character: "草", pinyin: "cǎo", meaning: "grass", strokeCount: 9, category: .nature),
        ChineseCharacter(character: "树", pinyin: "shù", meaning: "tree", strokeCount: 9, category: .nature),
        ChineseCharacter(character: "山", pinyin: "shān", meaning: "mountain", strokeCount: 3, category: .nature),
        ChineseCharacter(character: "水", pinyin: "shuǐ", meaning: "water", strokeCount: 4, category: .nature),
        ChineseCharacter(character: "云", pinyin: "yún", meaning: "cloud", strokeCount: 4, category: .nature),
        ChineseCharacter(character: "雨", pinyin: "yǔ", meaning: "rain", strokeCount: 8, category: .nature),
        ChineseCharacter(character: "风", pinyin: "fēng", meaning: "wind", strokeCount: 4, category: .nature),

        // Family
        ChineseCharacter(character: "爸", pinyin: "bà", meaning: "dad", strokeCount: 8, category: .family),
        ChineseCharacter(character: "妈", pinyin: "mā", meaning: "mom", strokeCount: 6, category: .family),
        ChineseCharacter(character: "爷", pinyin: "yé", meaning: "grandpa", strokeCount: 6, category: .family),
        ChineseCharacter(character: "奶", pinyin: "nǎi", meaning: "grandma", strokeCount: 5, category: .family),
        ChineseCharacter(character: "哥", pinyin: "gē", meaning: "brother", strokeCount: 10, category: .family),
        ChineseCharacter(character: "姐", pinyin: "jiě", meaning: "sister", strokeCount: 8, category: .family),

        // Colors
        ChineseCharacter(character: "红", pinyin: "hóng", meaning: "red", strokeCount: 6, category: .colors),
        ChineseCharacter(character: "黄", pinyin: "huáng", meaning: "yellow", strokeCount: 11, category: .colors),
        ChineseCharacter(character: "蓝", pinyin: "lán", meaning: "blue", strokeCount: 13, category: .colors),
        ChineseCharacter(character: "绿", pinyin: "lǜ", meaning: "green", strokeCount: 11, category: .colors),
        ChineseCharacter(character: "白", pinyin: "bái", meaning: "white", strokeCount: 5, category: .colors),
        ChineseCharacter(character: "黑", pinyin: "hēi", meaning: "black", strokeCount: 12, category: .colors),

        // Numbers
        ChineseCharacter(character: "一", pinyin: "yī", meaning: "one", strokeCount: 1, category: .numbers),
        ChineseCharacter(character: "二", pinyin: "èr", meaning: "two", strokeCount: 2, category: .numbers),
        ChineseCharacter(character: "三", pinyin: "sān", meaning: "three", strokeCount: 3, category: .numbers),
        ChineseCharacter(character: "四", pinyin: "sì", meaning: "four", strokeCount: 5, category: .numbers),
        ChineseCharacter(character: "五", pinyin: "wǔ", meaning: "five", strokeCount: 4, category: .numbers),
        ChineseCharacter(character: "六", pinyin: "liù", meaning: "six", strokeCount: 4, category: .numbers),
        ChineseCharacter(character: "七", pinyin: "qī", meaning: "seven", strokeCount: 2, category: .numbers),
        ChineseCharacter(character: "八", pinyin: "bā", meaning: "eight", strokeCount: 2, category: .numbers),
        ChineseCharacter(character: "九", pinyin: "jiǔ", meaning: "nine", strokeCount: 2, category: .numbers),
        ChineseCharacter(character: "十", pinyin: "shí", meaning: "ten", strokeCount: 2, category: .numbers),
    ]
}

enum ChineseCategory: String, CaseIterable {
    case animals = "动物"
    case nature = "自然"
    case family = "家人"
    case colors = "颜色"
    case numbers = "数字"

    var icon: String {
        switch self {
        case .animals: return "pawprint.fill"
        case .nature: return "leaf.fill"
        case .family: return "heart.fill"
        case .colors: return "paintpalette.fill"
        case .numbers: return "number"
        }
    }

    var color: Color {
        switch self {
        case .animals: return ThemeColors.coralOrange
        case .nature: return ThemeColors.mintGreen
        case .family: return ThemeColors.brightPink
        case .colors: return ThemeColors.deepPurple
        case .numbers: return ThemeColors.magicBlue
        }
    }
}

// MARK: - English Learning Models
struct EnglishWord: Identifiable {
    let id = UUID()
    let word: String
    let meaning: String
    let category: EnglishCategory
    let imageSymbol: String

    static let grade2Words: [EnglishWord] = [
        // Animals
        EnglishWord(word: "Cat", meaning: "猫", category: .animals, imageSymbol: "cat.fill"),
        EnglishWord(word: "Dog", meaning: "狗", category: .animals, imageSymbol: "dog.fill"),
        EnglishWord(word: "Bird", meaning: "鸟", category: .animals, imageSymbol: "bird.fill"),
        EnglishWord(word: "Fish", meaning: "鱼", category: .animals, imageSymbol: "fish.fill"),
        EnglishWord(word: "Rabbit", meaning: "兔子", category: .animals, imageSymbol: "hare.fill"),
        EnglishWord(word: "Bear", meaning: "熊", category: .animals, imageSymbol: "pawprint.fill"),

        // Colors
        EnglishWord(word: "Red", meaning: "红色", category: .colors, imageSymbol: "circle.fill"),
        EnglishWord(word: "Blue", meaning: "蓝色", category: .colors, imageSymbol: "circle.fill"),
        EnglishWord(word: "Green", meaning: "绿色", category: .colors, imageSymbol: "circle.fill"),
        EnglishWord(word: "Yellow", meaning: "黄色", category: .colors, imageSymbol: "circle.fill"),
        EnglishWord(word: "Pink", meaning: "粉色", category: .colors, imageSymbol: "circle.fill"),
        EnglishWord(word: "Purple", meaning: "紫色", category: .colors, imageSymbol: "circle.fill"),

        // Food
        EnglishWord(word: "Apple", meaning: "苹果", category: .food, imageSymbol: "apple.logo"),
        EnglishWord(word: "Cake", meaning: "蛋糕", category: .food, imageSymbol: "birthday.cake.fill"),
        EnglishWord(word: "Milk", meaning: "牛奶", category: .food, imageSymbol: "cup.and.saucer.fill"),
        EnglishWord(word: "Bread", meaning: "面包", category: .food, imageSymbol: "takeoutbag.and.cup.and.straw.fill"),
        EnglishWord(word: "Water", meaning: "水", category: .food, imageSymbol: "drop.fill"),

        // Family
        EnglishWord(word: "Mom", meaning: "妈妈", category: .family, imageSymbol: "figure.stand"),
        EnglishWord(word: "Dad", meaning: "爸爸", category: .family, imageSymbol: "figure.stand"),
        EnglishWord(word: "Sister", meaning: "姐妹", category: .family, imageSymbol: "figure.2"),
        EnglishWord(word: "Brother", meaning: "兄弟", category: .family, imageSymbol: "figure.2"),
        EnglishWord(word: "Baby", meaning: "宝宝", category: .family, imageSymbol: "figure.and.child.holdinghands"),

        // Body
        EnglishWord(word: "Eye", meaning: "眼睛", category: .body, imageSymbol: "eye.fill"),
        EnglishWord(word: "Ear", meaning: "耳朵", category: .body, imageSymbol: "ear.fill"),
        EnglishWord(word: "Nose", meaning: "鼻子", category: .body, imageSymbol: "nose.fill"),
        EnglishWord(word: "Hand", meaning: "手", category: .body, imageSymbol: "hand.raised.fill"),
        EnglishWord(word: "Foot", meaning: "脚", category: .body, imageSymbol: "figure.walk"),

        // Nature
        EnglishWord(word: "Sun", meaning: "太阳", category: .nature, imageSymbol: "sun.max.fill"),
        EnglishWord(word: "Moon", meaning: "月亮", category: .nature, imageSymbol: "moon.fill"),
        EnglishWord(word: "Star", meaning: "星星", category: .nature, imageSymbol: "star.fill"),
        EnglishWord(word: "Cloud", meaning: "云", category: .nature, imageSymbol: "cloud.fill"),
        EnglishWord(word: "Rain", meaning: "雨", category: .nature, imageSymbol: "cloud.rain.fill"),
        EnglishWord(word: "Tree", meaning: "树", category: .nature, imageSymbol: "tree.fill"),
        EnglishWord(word: "Flower", meaning: "花", category: .nature, imageSymbol: "camera.macro"),
    ]
}

enum EnglishCategory: String, CaseIterable {
    case animals = "Animals"
    case colors = "Colors"
    case food = "Food"
    case family = "Family"
    case body = "Body"
    case nature = "Nature"

    var chineseName: String {
        switch self {
        case .animals: return "动物"
        case .colors: return "颜色"
        case .food: return "食物"
        case .family: return "家人"
        case .body: return "身体"
        case .nature: return "自然"
        }
    }

    var icon: String {
        switch self {
        case .animals: return "pawprint.fill"
        case .colors: return "paintpalette.fill"
        case .food: return "fork.knife"
        case .family: return "heart.fill"
        case .body: return "figure.arms.open"
        case .nature: return "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .animals: return ThemeColors.coralOrange
        case .colors: return ThemeColors.deepPurple
        case .food: return ThemeColors.sunshineYellow
        case .family: return ThemeColors.brightPink
        case .body: return ThemeColors.magicBlue
        case .nature: return ThemeColors.mintGreen
        }
    }
}

// MARK: - Memory Game Models
struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let symbol: String
    var isFaceUp = false
    var isMatched = false

    static func == (lhs: MemoryCard, rhs: MemoryCard) -> Bool {
        lhs.id == rhs.id
    }

    static let cardPairs: [(String, String)] = [
        ("Princess", "crown.fill"),
        ("Heart", "heart.fill"),
        ("Star", "star.fill"),
        ("Flower", "camera.macro"),
        ("Butterfly", "leaf.fill"),
        ("Rainbow", "rainbow"),
        ("Moon", "moon.stars.fill"),
        ("Sun", "sun.max.fill"),
        ("Cat", "cat.fill"),
        ("Dog", "dog.fill"),
        ("Bird", "bird.fill"),
        ("Fish", "fish.fill"),
    ]

    static func createPairs(count: Int) -> [MemoryCard] {
        let selected = Array(cardPairs.prefix(count))
        var cards: [MemoryCard] = []

        for (content, symbol) in selected {
            cards.append(MemoryCard(content: content, symbol: symbol))
            cards.append(MemoryCard(content: content, symbol: symbol))
        }

        return cards.shuffled()
    }
}

// MARK: - Drawing Models
struct DrawingPath: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
}
