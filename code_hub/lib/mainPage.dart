import 'package:code_hub/Pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:code_hub/Pages/home_page.dart';
import 'package:code_hub/Pages/news_page.dart';
import 'package:code_hub/Pages/profile_settings_page.dart';

class ThemeColors {
  static const Color primary = Color(0xFF1E88E5); // Slightly muted blue
  static const Color background = Color(0xFF121212); // Dark background
  static const Color surface = Color(0xFF1E1E1E); // Slightly lighter dark
  static const Color accent = Color(0xFF64B5F6); // Light blue accent
  static const Color textPrimary = Color(0xFFE0E0E0); // Light grey text
  static const Color textSecondary = Color(0xFF9E9E9E); // Medium grey text
  static const Color card = Color(0xFF252525); // Dark card background
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // List of pages
  final List<Widget> _pages = [
    HomePage(),
    NewsPage(),
    ProfileSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: ThemeColors.primary,
        scaffoldBackgroundColor: ThemeColors.background,
        cardColor: ThemeColors.card,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: ThemeColors.textPrimary),
          bodyMedium: TextStyle(color: ThemeColors.textSecondary),
        ),
      ),
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(),
          child: CurvedNavigationBar(
            key: _bottomNavigationKey,
            index: _selectedIndex,
            items: const [
              Icon(Icons.home_rounded, size: 30),
              Icon(Icons.newspaper_rounded, size: 30),
              Icon(Icons.person_rounded, size: 30),
            ],
            color: ThemeColors.primary,
            backgroundColor: ThemeColors.background,
            buttonBackgroundColor: ThemeColors.accent,
            height: 70,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
