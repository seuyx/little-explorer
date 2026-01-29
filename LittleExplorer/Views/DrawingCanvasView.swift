import SwiftUI

struct DrawingCanvasView: View {
    @EnvironmentObject var userProgress: UserProgress
    @Environment(\.dismiss) private var dismiss

    @State private var paths: [DrawingPath] = []
    @State private var currentPath: [CGPoint] = []
    @State private var selectedColor: Color = ThemeColors.brightPink
    @State private var lineWidth: CGFloat = 8
    @State private var showColorPicker = false
    @State private var showSavedMessage = false
    @State private var canvasBackground: Color = .white

    private let colors: [Color] = [
        ThemeColors.brightPink,
        ThemeColors.deepPurple,
        ThemeColors.magicBlue,
        ThemeColors.mintGreen,
        ThemeColors.sunshineYellow,
        ThemeColors.coralOrange,
        .red,
        .orange,
        .green,
        .blue,
        .purple,
        .brown,
        .black,
        .gray
    ]

    private let brushSizes: [CGFloat] = [4, 8, 12, 18, 25]

    var body: some View {
        ZStack {
            ThemeColors.drawingGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with title
                headerView

                // Canvas area
                canvasView

                // Tool palette
                toolPaletteView
            }

            // Saved message overlay
            if showSavedMessage {
                savedMessageOverlay
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
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text("🎨 创意画板")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            // Undo button
            Button(action: undoLastPath) {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(paths.isEmpty ? 0.3 : 1))
            }
            .disabled(paths.isEmpty)

            // Clear button
            Button(action: clearCanvas) {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(paths.isEmpty ? 0.3 : 1))
            }
            .disabled(paths.isEmpty)

            // Save button
            Button(action: saveDrawing) {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }

    // MARK: - Canvas View
    private var canvasView: some View {
        GeometryReader { geometry in
            ZStack {
                // Canvas background
                RoundedRectangle(cornerRadius: 20)
                    .fill(canvasBackground)
                    .shadow(color: .black.opacity(0.2), radius: 10)

                // Drawing canvas
                Canvas { context, size in
                    // Draw all completed paths
                    for path in paths {
                        var bezierPath = Path()
                        if let firstPoint = path.points.first {
                            bezierPath.move(to: firstPoint)
                            for point in path.points.dropFirst() {
                                bezierPath.addLine(to: point)
                            }
                        }
                        context.stroke(
                            bezierPath,
                            with: .color(path.color),
                            style: StrokeStyle(
                                lineWidth: path.lineWidth,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                    }

                    // Draw current path
                    if !currentPath.isEmpty {
                        var bezierPath = Path()
                        bezierPath.move(to: currentPath[0])
                        for point in currentPath.dropFirst() {
                            bezierPath.addLine(to: point)
                        }
                        context.stroke(
                            bezierPath,
                            with: .color(selectedColor),
                            style: StrokeStyle(
                                lineWidth: lineWidth,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentPath.append(value.location)
                        }
                        .onEnded { _ in
                            if !currentPath.isEmpty {
                                paths.append(DrawingPath(
                                    points: currentPath,
                                    color: selectedColor,
                                    lineWidth: lineWidth
                                ))
                                currentPath = []
                            }
                        }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Cute corner decorations
                VStack {
                    HStack {
                        Image(systemName: "sparkle")
                            .foregroundStyle(ThemeColors.brightPink.opacity(0.3))
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundStyle(ThemeColors.sunshineYellow.opacity(0.3))
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(ThemeColors.brightPink.opacity(0.3))
                        Spacer()
                        Image(systemName: "sparkle")
                            .foregroundStyle(ThemeColors.deepPurple.opacity(0.3))
                    }
                }
                .font(.system(size: 20))
                .padding(15)
                .allowsHitTesting(false)
            }
            .padding(.horizontal, 15)
        }
    }

    // MARK: - Tool Palette
    private var toolPaletteView: some View {
        VStack(spacing: 15) {
            // Color picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(colors, id: \.self) { color in
                        Button(action: { selectedColor = color }) {
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .shadow(color: color.opacity(0.5), radius: selectedColor == color ? 5 : 2)
                        }
                    }

                    // Rainbow/gradient option
                    Button(action: { showColorPicker.toggle() }) {
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                                    center: .center
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16, weight: .bold))
                            )
                    }
                }
                .padding(.horizontal, 20)
            }

            // Brush size picker
            HStack(spacing: 15) {
                Text("画笔:")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)

                ForEach(brushSizes, id: \.self) { size in
                    Button(action: { lineWidth = size }) {
                        Circle()
                            .fill(selectedColor)
                            .frame(width: size + 10, height: size + 10)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: lineWidth == size ? 2 : 0)
                            )
                    }
                }

                Spacer()

                // Background color toggle
                Button(action: toggleBackground) {
                    HStack(spacing: 6) {
                        Image(systemName: "paintbrush.fill")
                        Text("背景")
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(ThemeColors.deepPurple)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.white)
                    )
                }
            }
            .padding(.horizontal, 20)

            // Stamp tools (cute shapes)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    Text("印章:")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)

                    ForEach(stampOptions, id: \.symbol) { stamp in
                        Button(action: { }) {
                            VStack(spacing: 4) {
                                Image(systemName: stamp.symbol)
                                    .font(.system(size: 25))
                                    .foregroundStyle(stamp.color)
                                Text(stamp.name)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.2))
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Saved Message Overlay
    private var savedMessageOverlay: some View {
        VStack(spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)

            Text("画作已保存！")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("+1 颗星星 ⭐")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(ThemeColors.sunshineYellow)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(ThemeColors.deepPurple)
                .shadow(color: .black.opacity(0.3), radius: 15)
        )
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Stamp Options
    private var stampOptions: [(symbol: String, name: String, color: Color)] {
        [
            ("heart.fill", "爱心", ThemeColors.brightPink),
            ("star.fill", "星星", ThemeColors.sunshineYellow),
            ("moon.fill", "月亮", ThemeColors.deepPurple),
            ("sun.max.fill", "太阳", .orange),
            ("cloud.fill", "云朵", ThemeColors.magicBlue),
            ("leaf.fill", "叶子", ThemeColors.mintGreen),
            ("butterfly.fill", "蝴蝶", ThemeColors.brightPink),
            ("crown.fill", "皇冠", ThemeColors.sunshineYellow),
        ]
    }

    // MARK: - Functions
    private func undoLastPath() {
        if !paths.isEmpty {
            paths.removeLast()
        }
    }

    private func clearCanvas() {
        withAnimation {
            paths.removeAll()
            currentPath.removeAll()
        }
    }

    private func toggleBackground() {
        withAnimation {
            if canvasBackground == .white {
                canvasBackground = ThemeColors.primaryPink.opacity(0.3)
            } else if canvasBackground == ThemeColors.primaryPink.opacity(0.3) {
                canvasBackground = ThemeColors.magicBlue.opacity(0.3)
            } else if canvasBackground == ThemeColors.magicBlue.opacity(0.3) {
                canvasBackground = ThemeColors.sunshineYellow.opacity(0.3)
            } else {
                canvasBackground = .white
            }
        }
    }

    private func saveDrawing() {
        // In a real app, this would save to photo library
        // For now, we just show a success message and award a star
        withAnimation(.spring()) {
            showSavedMessage = true
            userProgress.addStars(1)
            userProgress.drawingsCount += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSavedMessage = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        DrawingCanvasView()
            .environmentObject(UserProgress())
    }
}
