import SwiftUI

struct ThemeColors {
    // Princess theme - soft pinks and purples
    static let primaryPink = Color(red: 1.0, green: 0.71, blue: 0.76)
    static let brightPink = Color(red: 1.0, green: 0.41, blue: 0.71)
    static let softPurple = Color(red: 0.85, green: 0.75, blue: 1.0)
    static let deepPurple = Color(red: 0.58, green: 0.44, blue: 0.86)
    static let magicBlue = Color(red: 0.68, green: 0.85, blue: 0.90)
    static let sunshineYellow = Color(red: 1.0, green: 0.93, blue: 0.55)
    static let mintGreen = Color(red: 0.60, green: 0.98, blue: 0.60)
    static let coralOrange = Color(red: 1.0, green: 0.50, blue: 0.31)

    // Gradients
    static let princessGradient = LinearGradient(
        colors: [primaryPink, softPurple, magicBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [.white, primaryPink.opacity(0.3)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let mathGradient = LinearGradient(
        colors: [sunshineYellow, coralOrange.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let chineseGradient = LinearGradient(
        colors: [Color.red.opacity(0.7), coralOrange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let englishGradient = LinearGradient(
        colors: [magicBlue, deepPurple.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let memoryGradient = LinearGradient(
        colors: [mintGreen, magicBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let drawingGradient = LinearGradient(
        colors: [brightPink, deepPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// Cute decorative elements
struct SparkleView: View {
    @State private var isAnimating = false
    let size: CGFloat

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: size))
            .foregroundStyle(ThemeColors.sunshineYellow)
            .shadow(color: .yellow.opacity(0.5), radius: 3)
            .scaleEffect(isAnimating ? 1.2 : 0.8)
            .opacity(isAnimating ? 1 : 0.6)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct FloatingHeartsView: View {
    @State private var hearts: [HeartParticle] = []

    var body: some View {
        ZStack {
            ForEach(hearts) { heart in
                Image(systemName: "heart.fill")
                    .font(.system(size: heart.size))
                    .foregroundStyle(heart.color)
                    .position(heart.position)
                    .opacity(heart.opacity)
            }
        }
        .onAppear {
            startHeartAnimation()
        }
    }

    private func startHeartAnimation() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            addHeart()
        }
    }

    private func addHeart() {
        let colors: [Color] = [ThemeColors.brightPink, ThemeColors.primaryPink, ThemeColors.softPurple]
        let heart = HeartParticle(
            position: CGPoint(x: CGFloat.random(in: 50...350), y: 800),
            size: CGFloat.random(in: 15...30),
            color: colors.randomElement() ?? ThemeColors.brightPink,
            opacity: 0.8
        )
        hearts.append(heart)

        withAnimation(.easeOut(duration: 4.0)) {
            if let index = hearts.firstIndex(where: { $0.id == heart.id }) {
                hearts[index].position.y = -50
                hearts[index].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            hearts.removeAll { $0.id == heart.id }
        }
    }
}

struct HeartParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let color: Color
    var opacity: Double
}

// Animated star for rewards
struct AnimatedStarView: View {
    @State private var isAnimating = false
    let filled: Bool

    var body: some View {
        Image(systemName: filled ? "star.fill" : "star")
            .font(.system(size: 30))
            .foregroundStyle(filled ? ThemeColors.sunshineYellow : .gray.opacity(0.3))
            .shadow(color: filled ? .yellow.opacity(0.5) : .clear, radius: 5)
            .scaleEffect(isAnimating && filled ? 1.1 : 1.0)
            .animation(
                filled ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default,
                value: isAnimating
            )
            .onAppear {
                if filled {
                    isAnimating = true
                }
            }
    }
}

// Princess crown decoration
struct CrownView: View {
    var body: some View {
        Image(systemName: "crown.fill")
            .font(.system(size: 40))
            .foregroundStyle(
                LinearGradient(
                    colors: [ThemeColors.sunshineYellow, .orange],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: .orange.opacity(0.3), radius: 3)
    }
}

// Game card button style
struct GameCardStyle: ButtonStyle {
    let gradient: LinearGradient

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}
