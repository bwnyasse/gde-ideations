# Scrabble Digital Companion Suite

## 🎯 Elevator Pitch
The Scrabble Digital Companion Suite is a personal project aimed at enhancing family game nights by bridging the gap between traditional physical Scrabble gameplay and digital score tracking. By combining AI-powered board recognition with real-time game state management, it enhances the classic Scrabble experience while maintaining the tactile pleasure of the physical game.

## 🌟 Project Overview
This suite consists of two complementary applications designed to work together seamlessly:

### 1. Scrabble Moderator (Game Master)
A powerful tool for the game moderator (typically a family member) to:
- Manage game sessions
- Capture board states
- Validate moves
- Track scores accurately
Using AI-powered image recognition, it translates physical board states into digital data, ensuring accurate scoring and game progression tracking.

### 2. Scrabble Companion (Player View)
A digital scoreboard and game state viewer that provides real-time updates of the physical game. Players can:
- View the current board state
- Track scores
- Review move history
All without interrupting the traditional gameplay experience.

## 🎮 Current Features

### Scrabble Moderator (Game Master)
- [ ] **Game Session Management**: Create and manage game sessions
- [ ] **Player Registration**: Set up players for each game
- [ ] **Board State Capture**: Photograph the board after each move
- [ ] **Move Validation**: Ensure moves follow Scrabble rules
- [ ] **QR Code Generation**: Share game session with players
- [ ] **Real-time Updates**: Push changes to companion app

### Scrabble Companion (Player View)
- [x] **Real-time Board Visualization**: Digital representation of the physical game
- [x] **Score Tracking**: Automatic calculation and display
- [x] **Move History**: Chronological list of all moves
- [x] **Player Statistics**: Basic performance metrics
- [x] **Modern UI**: Dark theme optimized for iPad

## 🔄 How It Works

1. **Game Initiation** (Moderator App):
   - Moderator creates new game session
   - Enters player names
   - Generates unique game QR code/ID

2. **Game Connection** (Companion App):
   - Players can view available game sessions
   - Select their game from the list
   - Or scan QR code to join specific session

3. **Gameplay Loop**:
   - Physical game proceeds normally
   - After each move:
     - Moderator captures board state
     - AI analyzes the image
     - Scores are calculated
     - All companion apps update automatically

## 🛠 Technical Stack

### Frontend
- Flutter for cross-platform development
- Provider for state management
- Material Design UI components

### Backend
- Firebase Firestore: Real-time game state
- Firebase Auth: Session management
- Firebase Storage: Image storage (if needed)

### AI/ML
- Google's Gemini API for:
  - Board state recognition
  - Move validation
  - Score calculation

## 📱 Platform Support
- Moderator App: iOS/Android phones
- Companion App: iPad (primary), other tablets (future)

## 🎯 Initial Target Audience
Developed primarily for enhancing family game nights, with a focus on:
- Making score tracking effortless
- Eliminating scoring disputes
- Creating a record of family game sessions
- Making the game more engaging for younger players

## 🔜 Future Enhancements
- Voice Commentary: AI-powered narration of moves and scores
- Tournament Mode: Support for competitive play
- Statistics Dashboard: Detailed player analytics
- Move Suggestions: AI-powered learning tools
- Multi-language Support: Particularly French
- Social Sharing: Share game highlights
- Cross-Platform Support: Web and Android tablets

## 📋 Project Status
Currently in active development. See [TASKS.md](TASKS.md) for current development status and upcoming features.

## 🤝 Contributing
This is currently a personal project focused on family use, but suggestions and feedback are welcome! Open an issue to discuss potential improvements.

## 📝 License
[Add your chosen license]

---

## Development Progress
- ✅ Basic board visualization
- ✅ Score calculation logic
- ✅ Move history tracking
- ✅ Player management
- ✅ iPad-optimized UI
- 🔄 Firebase integration (in progress)
- 🔄 AI board recognition (in progress)
- ⏳ Session management
- ⏳ Real-time synchronization
- ⏳ QR code implementation