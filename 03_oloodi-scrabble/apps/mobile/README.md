# Scrabble Companion App

A Flutter-based companion app for physical Scrabble games, designed primarily for iPad use. This app helps players track scores, moves, and game progress while playing traditional Scrabble.

## Features

### Current Implementation
- **Game Board Display**
  - 15x15 grid with standard Scrabble board layout
  - Special squares (TW, DW, TL, DL) with proper coloring
  - Interactive zoom and pan capabilities
  - Player-colored tile borders for move tracking

- **Move Tracking**
  - Simulated move placement for testing
  - Score calculation based on standard Scrabble rules
  - Move history tracking
  - Player turn management

- **Player Management**
  - Two-player support with distinct colors
  - Player avatars/images
  - Individual score tracking
  - Current player indication

- **UI/UX**
  - iPad-optimized landscape layout
  - Collapsible move history panel
  - Animated tile placement
  - Touch-enabled board interaction

### Planned Features
- **AI Integration**
  - [ ] Gemini SDK integration for board state analysis
  - [ ] Image processing for physical board capture
  - [ ] Move validation through AI
  - [ ] Word verification

- **Game Rules Enhancement**
  - [ ] Complete Scrabble rules implementation
  - [ ] Word dictionary integration
  - [ ] Score multiplier calculation
  - [ ] Cross-word formation validation

- **UI Improvements**
  - [ ] Game statistics dashboard
  - [ ] Enhanced move animations
  - [ ] Better touch gesture support
  - [ ] Dark mode support

- **Additional Features**
  - [ ] Game session saving/loading
  - [ ] Move undo/redo functionality
  - [ ] Player profiles and statistics
  - [ ] Game replay feature

## Technical Details

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  animations: ^2.0.11
  flutter_animate: ^4.5.0
  shared_preferences: ^2.2.2
  google_generative_ai: ^0.2.0 # For future AI integration
```

### Project Structure
```
lib/
├── models/
│   ├── board_square.dart
│   ├── move.dart
│   ├── player.dart
│   └── tile.dart
├── providers/
│   └── game_state_provider.dart
├── services/
│   ├── mock_game_service.dart
│   └── gemini_service.dart
├── screens/
│   └── home_screen.dart
└── widgets/
    ├── board_widget.dart
    ├── player_score_card.dart
    └── move_history_panel.dart
```

## Setup and Running

1. Requirements
   - Flutter SDK
   - Dart SDK
   - iOS/Android development tools

2. Installation
   ```bash
   flutter pub get
   ```

3. Running
   ```bash
   flutter run -d chrome --web-renderer canvaskit
   ```

## Development Guidelines

### Code Organization
- Models for data structures
- Providers for state management
- Services for business logic
- Widgets for UI components

### Styling Guidelines
- Use constants for colors and dimensions
- Follow Material Design guidelines
- Maintain consistent spacing
- Use proper widget hierarchy

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

[Add your license here]