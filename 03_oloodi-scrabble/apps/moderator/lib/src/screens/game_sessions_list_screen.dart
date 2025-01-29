// lib/src/screens/game_sessions_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/game_session_provider.dart';
import '../models/game_session.dart';
import 'game_setup_screen.dart';
import 'game_monitoring_screen.dart';

class GameSessionsListScreen extends StatefulWidget {
  const GameSessionsListScreen({super.key});

  @override
  State<GameSessionsListScreen> createState() => _GameSessionsListScreenState();
}

class _GameSessionsListScreenState extends State<GameSessionsListScreen> {
  final Set<String> _selectedSessions = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Sessions'),
        actions: [
          if (_selectedSessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedSessions,
            ),
        ],
      ),
      body: StreamBuilder<List<GameSession>>(
        stream: context.read<GameSessionProvider>().getSessions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_esports_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No game sessions yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a new game to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildSessionCard(session);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToGameSetup(context),
        icon: const Icon(Icons.add),
        label: const Text('Start Game'),
      ),
    );
  }

  Widget _buildSessionCard(GameSession session) {
    final dateFormat = DateFormat('MMM d, y – h:mm a');
    final isSelected = _selectedSessions.contains(session.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToSession(session),
        onLongPress: () => _toggleSessionSelection(session.id),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${session.player1Name} vs ${session.player2Name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (session.isActive)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(session.startTime),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.blue)
                  else
                    const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              if (session.isActive) ...[
                const SizedBox(height: 16),
                _buildGameStats(session),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameStats(GameSession session) {
    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<GameSessionProvider>().getSessionStats(session.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final stats = snapshot.data!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Moves', stats['totalMoves']?.toString() ?? '0'),
            _buildStatItem('Letters Remaining', stats['remainingLetters']?.toString() ?? '-'),
            _buildStatItem('Duration', _formatDuration(session.startTime)),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDuration(DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  void _toggleSessionSelection(String sessionId) {
    setState(() {
      if (_selectedSessions.contains(sessionId)) {
        _selectedSessions.remove(sessionId);
      } else {
        _selectedSessions.add(sessionId);
      }
    });
  }

  Future<void> _deleteSelectedSessions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sessions'),
        content: Text(
          'Are you sure you want to delete ${_selectedSessions.length} selected session(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<GameSessionProvider>().deleteSessions(_selectedSessions.toList());
        setState(() {
          _selectedSessions.clear();
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting sessions: $e')),
          );
        }
      }
    }
  }

  void _navigateToSession(GameSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameMonitoringScreen(sessionId: session.id),
      ),
    );
  }

  void _navigateToGameSetup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameSetupScreen(),
      ),
    );
  }
}