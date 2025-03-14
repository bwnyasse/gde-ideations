import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:flutter_earth_globe/sphere_style.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oloodi World',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OloodiWorldHome(),
    );
  }
}

class OloodiWorldHome extends StatefulWidget {
  const OloodiWorldHome({Key? key}) : super(key: key);

  @override
  _OloodiWorldHomeState createState() => _OloodiWorldHomeState();
}

class _OloodiWorldHomeState extends State<OloodiWorldHome> with TickerProviderStateMixin {
  late FlutterEarthGlobeController _controller;
  bool _isListening = false;
  String? _activePrompt;
  int _factIndex = 0;
  bool _showInfoCard = false;
  Map<String, dynamic> _infoCardContent = {
    'title': '',
    'content': '',
    'type': '',
  };

  // Sample data for the application
  final List<String> _predefinedPrompts = [
    "Where is the Amazon rainforest?",
    "What animals live in the Arctic?",
    "Tell me about the Great Wall of China",
    "How many oceans are there?",
    "Show me the tallest mountain"
  ];
  
  final List<String> _didYouKnowFacts = [
    "The Earth is not perfectly round, but slightly flattened at the poles",
    "There are more stars in the universe than grains of sand on all the beaches on Earth",
    "A day on Venus is longer than a year on Venus",
    "The Great Barrier Reef is the largest living structure on Earth",
    "Antarctica is the only continent with no reptiles or snakes"
  ];
  
  final List<Map<String, dynamic>> _pointsOfInterest = [
    {'name': "Paris", 'lat': 48.8566, 'lng': 2.3522},
    {'name': "Amazon Rainforest", 'lat': -3.4653, 'lng': -62.2159},
    {'name': "Great Wall of China", 'lat': 40.4319, 'lng': 116.5704},
    {'name': "Mount Everest", 'lat': 27.9881, 'lng': 86.9250},
    {'name': "Great Barrier Reef", 'lat': -18.2871, 'lng': 147.6992}
  ];

  List<Point> _globePoints = [];
  Timer? _factTimer;

  @override
  void initState() {
    super.initState();
    
    // Initialize the globe controller
    _controller = FlutterEarthGlobeController(
      rotationSpeed: 0.8,
      zoom: 0.8,
      isRotating: true,
      isBackgroundFollowingSphereRotation: true,
      background: AssetImage('assets/2k_stars.jpg'),
      surface: AssetImage('assets/2k_earth-day.jpg'),
    );

    // Create points for the globe
    _createGlobePoints();
    
    // Add points to controller
    for (var point in _globePoints) {
      _controller.addPoint(point);
    }
    
    // Set up the timer for rotating facts
    _factTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _factIndex = (_factIndex + 1) % _didYouKnowFacts.length;
      });
    });
  }

  @override
  void dispose() {
    _factTimer?.cancel();
    super.dispose();
  }

  void _createGlobePoints() {
    _globePoints = _pointsOfInterest.map((poi) {
      return Point(
        id: poi['name'],
        coordinates: GlobeCoordinates(poi['lat'], poi['lng']),
        label: poi['name'],
        style: const PointStyle(color: Colors.amber, size: 5),
        onTap: () {
          _focusOnLocation(poi['name']);
        },
      );
    }).toList();
  }

  void _handleVoiceActivation() {
    setState(() {
      _isListening = true;
    });
    
    // In a real implementation, this would activate the voice recognition API
    // For this demo, we'll simulate a response after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (_activePrompt != null) {
        _handleQuery(_activePrompt!);
      }
      setState(() {
        _isListening = false;
      });
    });
  }

  void _handlePromptClick(String prompt) {
    setState(() {
      _activePrompt = prompt;
    });
    _handleVoiceActivation();
  }

  void _handleQuery(String query) {
    // Simulate responses to different queries
    if (query.toLowerCase().contains("amazon")) {
      _focusOnLocation("Amazon Rainforest");
      _showInfo("Amazon Rainforest", "The Amazon is the world's largest rainforest, spanning 9 countries and home to 10% of the world's known species.", "location");
    } else if (query.toLowerCase().contains("arctic") || query.toLowerCase().contains("animals")) {
      _showInfo("Arctic Animals", "The Arctic is home to polar bears, Arctic foxes, walruses, seals, and many bird species that have adapted to the cold climate.", "animals");
    } else if (query.toLowerCase().contains("great wall")) {
      _focusOnLocation("Great Wall of China");
      _showInfo("Great Wall of China", "The Great Wall of China is over 13,000 miles long and was built over 2,000 years ago. It's one of the most impressive structures ever built by humans.", "location");
    } else if (query.toLowerCase().contains("oceans")) {
      _showInfo("Earth's Oceans", "There are five oceans on Earth: the Pacific, Atlantic, Indian, Southern, and Arctic Oceans. The Pacific is the largest and deepest.", "geography");
    } else if (query.toLowerCase().contains("mountain") || query.toLowerCase().contains("tallest")) {
      _focusOnLocation("Mount Everest");
      _showInfo("Mount Everest", "Mount Everest is the tallest mountain on Earth, standing at 29,032 feet (8,849 meters) above sea level.", "location");
    }
  }

  void _focusOnLocation(String locationName) {
    final poi = _pointsOfInterest.firstWhere(
      (poi) => poi['name'] == locationName,
      orElse: () => _pointsOfInterest[0],
    );
    
    _controller.focusOnCoordinates(
      GlobeCoordinates(poi['lat'], poi['lng']), 
      animate: true,
    );
  }

  void _showInfo(String title, String content, String type) {
    setState(() {
      _infoCardContent = {
        'title': title,
        'content': content,
        'type': type,
      };
      _showInfoCard = true;
    });
  }

  void _handleGlobeInteraction(String action) {
    switch (action) {
      case 'zoomIn':
        _controller.setZoom(_controller.zoom + 0.1);
        break;
      case 'zoomOut':
        _controller.setZoom(_controller.zoom - 0.1);
        break;
      case 'toggleRotation':
        setState(() {
          if (_controller.isRotating) {
            _controller.stopRotation();
          } else {
            _controller.startRotation();
          }
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo and title
                      Row(
                        children: [
                          Icon(Icons.public, size: 32, color: Colors.lightBlue[300]),
                          const SizedBox(width: 8),
                          Text(
                            'Oloodi World',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue[300],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Globe container (positioned toward right)
              Positioned.fill(
                left: MediaQuery.of(context).size.width < 600 
                    ? MediaQuery.of(context).size.width * 0.25 + 30
                    : 280,
                child: Center(
                  child: FlutterEarthGlobe(
                    controller: _controller,
                    radius: MediaQuery.of(context).size.width < 600
                        ? MediaQuery.of(context).size.width * 0.35
                        : 240,
                    onTap: (coordinates) {
                      // Handle tap on globe
                    },
                  ),
                ),
              ),
              
              // Globe controls (bottom)
              Positioned(
                bottom: 20,
                left: MediaQuery.of(context).size.width < 600 
                    ? MediaQuery.of(context).size.width * 0.25 + 30
                    : 280,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Zoom in button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => _handleGlobeInteraction('zoomIn'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Zoom out button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () => _handleGlobeInteraction('zoomOut'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Rotation toggle
                    Container(
                      decoration: BoxDecoration(
                        color: _controller.isRotating 
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.sync, color: Colors.white),
                        onPressed: () => _handleGlobeInteraction('toggleRotation'),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Info card (when visible)
              if (_showInfoCard)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 500,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _infoCardContent['title'],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _showInfoCard = false;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _infoCardContent['content'],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          if (_infoCardContent['type'] == 'location') ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.location_on),
                              label: const Text('View on globe'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: () {
                                _focusOnLocation(_infoCardContent['title']);
                                setState(() {
                                  _showInfoCard = false;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Left panel content (facts, voice activation, prompts)
              Positioned(
                top: 100,
                bottom: 20,
                left: 20,
                width: MediaQuery.of(context).size.width < 600 
                    ? MediaQuery.of(context).size.width * 0.25
                    : 250,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Did you know facts
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.purple[900]?.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Did you know?',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _didYouKnowFacts[_factIndex],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Voice activation
                            const Text(
                              'Ask a question:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[800]?.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  // Voice input display
                                  Text(
                                    _isListening 
                                        ? 'Listening...' 
                                        : _activePrompt ?? 'Ask about places, animals, or facts...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[300],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  // Mic button
                                  Center(
                                    child: GestureDetector(
                                      onTap: _handleVoiceActivation,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _isListening 
                                              ? Colors.red 
                                              : Colors.blue[600],
                                        ),
                                        child: const Icon(
                                          Icons.mic,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Predefined prompts
                            const Text(
                              'Try asking:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Prompts list (as column for left panel)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _predefinedPrompts.map((prompt) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: InkWell(
                                    onTap: () => _handlePromptClick(prompt),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.chat_bubble_outline,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              prompt,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}