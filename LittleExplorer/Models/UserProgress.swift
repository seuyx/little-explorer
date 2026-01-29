import SwiftUI

class UserProgress: ObservableObject {
    @Published var totalStars: Int {
        didSet {
            UserDefaults.standard.set(totalStars, forKey: "totalStars")
        }
    }

    @Published var mathScore: Int {
        didSet {
            UserDefaults.standard.set(mathScore, forKey: "mathScore")
        }
    }

    @Published var chineseScore: Int {
        didSet {
            UserDefaults.standard.set(chineseScore, forKey: "chineseScore")
        }
    }

    @Published var englishScore: Int {
        didSet {
            UserDefaults.standard.set(englishScore, forKey: "englishScore")
        }
    }

    @Published var memoryBestScore: Int {
        didSet {
            UserDefaults.standard.set(memoryBestScore, forKey: "memoryBestScore")
        }
    }

    @Published var drawingsCount: Int {
        didSet {
            UserDefaults.standard.set(drawingsCount, forKey: "drawingsCount")
        }
    }

    init() {
        self.totalStars = UserDefaults.standard.integer(forKey: "totalStars")
        self.mathScore = UserDefaults.standard.integer(forKey: "mathScore")
        self.chineseScore = UserDefaults.standard.integer(forKey: "chineseScore")
        self.englishScore = UserDefaults.standard.integer(forKey: "englishScore")
        self.memoryBestScore = UserDefaults.standard.integer(forKey: "memoryBestScore")
        self.drawingsCount = UserDefaults.standard.integer(forKey: "drawingsCount")
    }

    func addStars(_ count: Int) {
        withAnimation(.spring()) {
            totalStars += count
        }
    }

    func resetProgress() {
        totalStars = 0
        mathScore = 0
        chineseScore = 0
        englishScore = 0
        memoryBestScore = 0
        drawingsCount = 0
    }
}
