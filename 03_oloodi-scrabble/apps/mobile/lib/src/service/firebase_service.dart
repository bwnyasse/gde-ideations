import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/move.dart';
import '../models/player.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _gameId;

  // Listen to game updates
  Stream<DocumentSnapshot> listenToGame(String gameId) {
    _gameId = gameId;
    return _firestore.collection('games').doc(gameId).snapshots();
  }

  // Listen to moves
  Stream<QuerySnapshot> listenToMoves() {
    if (_gameId == null) throw Exception('Game ID not set');
    return _firestore
        .collection('games')
        .doc(_gameId)
        .collection('moves')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Get player information
  Future<List<Player>> getPlayers() async {
    if (_gameId == null) throw Exception('Game ID not set');
    final gameDoc = await _firestore.collection('games').doc(_gameId).get();
    final data = gameDoc.data() as Map<String, dynamic>;

    return [
      Player(
        id: 'p1',
        displayName: data['player1Name'],
        color: data['player1Color'],
        imagePath: data['player1Image'],
      ),
      Player(
        id: 'p2',
        displayName: data['player2Name'],
        color: data['player2Color'],
        imagePath: data['player2Image'],
      ),
    ];
  }

  Future<QuerySnapshot> getAllMoves(String gameId) async {
    return await _firestore
        .collection('games')
        .doc(gameId)
        .collection('moves')
        .orderBy('timestamp', descending: false)
        .get();
  }
}
