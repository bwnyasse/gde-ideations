import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';

class AppColors {
  // Monochrome Blue/White on Dark Theme
  static const Color primary = Color(0xFF0066CC);
  static const Color background = Colors.black;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color unfilledDot = Color(0xFF3A3A3C); // Dark gray for unfilled

  // White for achieved, blue for missed
  static const Color achievedDot = Colors.white; // Pure white for achieved
  static const Color missedDot = Color(0xFF195090); // Darker blue for missed

  static const Color cardBackground = Color(0xFF282828);
  static const Color cardBorder = Color(0xFF424242);
  static const Color progressBarBackground = Color(0xFF424242);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Required for SystemChrome
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Year Visualizer',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: '.SF Pro Display',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const YearVisualizerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class YearVisualizerPage extends StatefulWidget {
  const YearVisualizerPage({super.key});

  @override
  State<YearVisualizerPage> createState() => _YearVisualizerPageState();
}

class _YearVisualizerPageState extends State<YearVisualizerPage> {
  // Configuration
  final int daysPerRow = 18; // Increased dots per row for more compactness
  final int totalDays = 365;
  late int rows;

  // Activity types with their colors (Apple-inspired, dark theme)
  final Map<String, Map<String, dynamic>> activityTypes = {
    'achieved': {
      'color': AppColors.achievedDot, // Apple achieved
      'label': 'Achieved'
    },
    'missed': {
      'color': AppColors.missedDot, // Apple red
      'label': 'Missed'
    },
    'none': {
      'color': AppColors.unfilledDot, // Dark gray for unfilled
      'label': 'Unfilled'
    },
  };

  late List<Map<String, dynamic>> daysData = [];
  late int dayOfYear;
  late int remainingDays;
  late int percentRemaining;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    rows = (totalDays / daysPerRow).ceil();

    // Calculate current day of year
    final currentDate = DateTime.now();
    final startOfYear = DateTime(currentDate.year, 1, 1);
    dayOfYear = currentDate.difference(startOfYear).inDays + 1;
    remainingDays = totalDays - dayOfYear;
    percentRemaining = ((remainingDays / totalDays) * 100).round();

    // Load data from JSON file
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      // Load the JSON file from assets
      final String jsonString =
          await rootBundle.loadString('assets/days_data.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);

      // Convert JSON to our data format
      daysData =
          jsonData.map((item) => Map<String, dynamic>.from(item)).toList();

      // Make sure we have exactly 365 days
      if (daysData.length != totalDays) {
        generateDaysData();
      }

      // Reverse the list to fill from bottom to top
      daysData = daysData.reversed.toList();
    } catch (e) {
      print('Error loading JSON data: $e');
      // If there's an error, generate default data
      generateDaysData();
    }

    // Set loading to false when data is ready
    setState(() {
      isLoading = false;
    });
  }

  void generateDaysData() {
    // Generate default days data with current date as reference
    final currentDate = DateTime.now();
    final startOfYear = DateTime(currentDate.year, 1, 1);

    daysData = List.generate(totalDays, (index) {
      final date = startOfYear.add(Duration(days: index));
      final day = index + 1;

      // Default all days to unfilled
      String type = 'none';

      // For demo purposes, set some days as achieved or missed
      if (index < dayOfYear) {
        // For past days, randomly distribute achievements and misses
        final rand = Random().nextDouble();
        if (rand < 0.7) {
          type = 'achieved';
        } else if (rand < 0.9) {
          type = 'missed';
        }
      }

      return {
        'day': day,
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'type': type
      };
    });

    // Reverse to fill from bottom to top
    daysData = daysData.reversed.toList();
  }

  // Calculate statistics
  Map<String, dynamic> get stats {
    final achieved = daysData.where((d) => d['type'] == 'achieved').length;
    final missed = daysData.where((d) => d['type'] == 'missed').length;
    final successRate =
        dayOfYear > 0 ? ((achieved / dayOfYear) * 100).round() : 0;

    return {
      'achieved': achieved,
      'missed': missed,
      'successRate': successRate,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(12.0), // Reduced padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Motivational quote - compact version with signature
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          "STOP THINKING",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "START BUILDING",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.achievedDot,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "- Boris-Wilfried Nyasse",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Grid of dots - more compact with smaller dots
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(12), // Reduced padding
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Keep it compact
                      children: List.generate(rows, (rowIndex) {
                        final start = rowIndex * daysPerRow;
                        final end = min((rowIndex + 1) * daysPerRow, totalDays);
                        final rowDays = daysData.sublist(start, end);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: rowDays.map((day) {
                            return Container(
                              width: 16, // Slightly smaller for compactness
                              height: 16, // Slightly smaller for compactness
                              margin:
                                  const EdgeInsets.all(1.5), // Reduced margin
                              decoration: BoxDecoration(
                                color: activityTypes[day['type']]!['color'],
                                shape: BoxShape.circle,
                                // Removed shadows to prevent unwanted reflections
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ),
                  ),

                  // Year and percentage - simpler and larger
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        // Large year and percentage display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '2025',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 24,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$percentRemaining% LEFT',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        // Progress bar
                        Container(
                          width: double.infinity,
                          height: 8, // Slightly thicker
                          decoration: BoxDecoration(
                            color: AppColors.progressBarBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentRemaining / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Statistics - larger and clearer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'ACHIEVED',
                            value: '${stats['achieved']}',
                            color: AppColors.achievedDot,
                            iconData: Icons.check_circle_outline,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            title: 'SUCCESS',
                            value: '${stats['successRate']}%',
                            color: AppColors.primary,
                            iconData: Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Legend - larger and more prominent
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegendItem(
                          color: activityTypes['achieved']!['color'],
                          label: 'ACHIEVED',
                        ),
                        _buildLegendItem(
                          color: activityTypes['missed']!['color'],
                          label: 'MISSED',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData iconData,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                color: color,
                size: 20, // Slightly larger
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16, // Larger
                    fontWeight: FontWeight.w600, // Bolder
                    color: AppColors.textPrimary,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32, // Much larger
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 20, // Larger dot
          height: 20, // Larger dot
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18, // Larger text
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600, // Bolder
          ),
        ),
      ],
    );
  }
}
