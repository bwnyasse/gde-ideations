// lib/src/providers/game_session_provider.dart
import 'package:flutter/foundation.dart';
import 'package:oloodi_scrabble_moderator_app/src/models/game_session.dart';
import 'package:oloodi_scrabble_moderator_app/src/services/firebase_service.dart';
import 'package:oloodi_scrabble_moderator_app/src/services/qr_service.dart';

class GameSessionProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final QRService _qrService = QRService();

  GameSession? _currentSession;
  bool _isLoading = false;
  String? _error;

  // Getters
  GameSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveSession =>
      _currentSession != null && _currentSession!.isActive;

  // Create new game session
  Future<void> createGameSession(String player1Name, String player2Name) async {
    try {
      _setLoading(true);
      _clearError();

      // Create session in Firebase
      final session = await _firebaseService.createGameSession(
        player1Name: player1Name,
        player2Name: player2Name,
      );

      // Generate QR code data string
      final qrCodeData = _qrService.generateQRCodeData(session.id);

      // Update session with QR code data
      _currentSession = await _firebaseService.updateSessionQRCode(
        session.id,
        qrCodeData,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to create game session: $e');
    } finally {
      _setLoading(false);
    }
  }

  // End current session
  Future<void> endCurrentSession() async {
    if (_currentSession == null) return;

    try {
      _setLoading(true);
      _clearError();

      await _firebaseService.updateSessionStatus(
        _currentSession!.id,
        false,
      );

      _currentSession = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to end session: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add move to current session
  Future<void> addMove({
    required String word,
    required int score,
    required String playerId,
    required List<Map<String, dynamic>> tiles,
  }) async {
    if (_currentSession == null) {
      _setError('No active session');
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      await _firebaseService.addMoveToSession(
        sessionId: _currentSession!.id,
        word: word,
        score: score,
        playerId: playerId,
        tiles: tiles,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to add move: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load existing session
  Future<void> loadSession(String sessionId) async {
    try {
      _setLoading(true);
      _clearError();

      _currentSession = await _firebaseService.getSession(sessionId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load session: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Get stream of all sessions
  Stream<List<GameSession>> getSessions() {
    return _firebaseService.getGameSessions().map((snapshot) => snapshot.docs
        .map((doc) => GameSession.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Delete multiple sessions
  Future<void> deleteSessions(List<String> sessionIds) async {
    try {
      _setLoading(true);
      _clearError();

      for (final sessionId in sessionIds) {
        await _firebaseService.deleteSession(sessionId);
      }
    } catch (e) {
      _setError('Failed to delete sessions: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get session statistics
  Future<Map<String, dynamic>> getSessionStats(String sessionId) async {
    try {
      final moves = await _firebaseService.getSessionMoves(sessionId).first;
      final remainingLetters =
          await _firebaseService.getRemainingLetters(sessionId);

      return {
        'totalMoves': moves.length,
        'remainingLetters': remainingLetters,
        'player1Score': moves
            .where((m) => m['playerId'] == 'p1')
            .fold(0, (sum, m) => sum + (m['score'] as int)),
        'player2Score': moves
            .where((m) => m['playerId'] == 'p2')
            .fold(0, (sum, m) => sum + (m['score'] as int)),
      };
    } catch (e) {
      _setError('Failed to get session stats: $e');
      rethrow;
    }
  }
}
