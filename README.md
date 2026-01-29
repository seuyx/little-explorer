# Little Explorer (小小探险家)

A fun, educational iPad app designed for children aged 7-9 (Grade 2). Built with SwiftUI and featuring a beautiful princess/cute theme.

## Features

### Math Adventure (数学乐园)
- Addition and subtraction practice
- Adaptive difficulty based on performance
- Streak bonuses for consecutive correct answers
- Score tracking with star rewards

### Chinese Learning (汉字王国)
- Learn Chinese characters by category (Animals, Nature, Family, Colors, Numbers)
- Pinyin and meaning display
- Stroke count information
- Quiz mode to test knowledge

### English World (英语天地)
- Vocabulary flashcards with categories
- Chinese translations
- Spelling practice mode
- Visual icons for each word

### Memory Match (记忆配对)
- Card matching game with princess theme
- Three difficulty levels (Easy, Medium, Hard)
- Timer and move counter
- Best score tracking

### Drawing Canvas (创意画板)
- Free drawing with multiple colors
- Various brush sizes
- Multiple background colors
- Undo and clear functions

## Requirements

- iOS 17.0+
- iPad recommended
- Xcode 15.0+

## Installation

1. Clone this repository
2. Open `LittleExplorer.xcodeproj` in Xcode
3. Select your iPad or iPad Simulator as the target device
4. Build and run (Cmd+R)

## Project Structure

```
LittleExplorer/
├── LittleExplorerApp.swift    # App entry point
├── ContentView.swift           # Main navigation
├── Views/
│   ├── HomeView.swift          # Princess-themed home screen
│   ├── MathGameView.swift      # Math practice game
│   ├── ChineseLearningView.swift # Chinese character learning
│   ├── EnglishLearningView.swift # English vocabulary
│   ├── MemoryGameView.swift    # Memory matching game
│   └── DrawingCanvasView.swift # Creative drawing canvas
├── Models/
│   ├── GameModels.swift        # Game data models
│   └── UserProgress.swift      # Progress tracking
├── Helpers/
│   └── ThemeColors.swift       # Theme colors and UI components
└── Assets.xcassets/            # App icons and colors
```

## License

MIT License - See LICENSE file for details
