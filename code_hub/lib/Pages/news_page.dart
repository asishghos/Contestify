import 'package:flutter/material.dart';

// Define theme colors
class ThemeColors {
  static const Color primary = Color(0xFF1E88E5); // Slightly muted blue
  static const Color background = Color(0xFF121212); // Dark background
  static const Color surface = Color(0xFF1E1E1E); // Slightly lighter dark
  static const Color accent = Color(0xFF64B5F6); // Light blue accent
  static const Color textPrimary = Color(0xFFE0E0E0); // Light grey text
  static const Color textSecondary = Color(0xFF9E9E9E); // Medium grey text
  static const Color card = Color(0xFF252525); // Dark card background
}

class NewsItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String expectedSalary;

  NewsItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.expectedSalary,
  });
}

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final PageController _pageController = PageController();
  final List<NewsItem> _newsItems = [
    NewsItem(
      title: "Birlasoft Apprentice (Internship) 2025",
      subtitle: "Engineering & Non-Engineering",
      imageUrl: "assets/company_image.jpg",
      expectedSalary: "₹ 32,875 & 18,000 per month",
    ),
    NewsItem(
      title: "CGI Off Campus Drive 2025",
      subtitle: "Systems Administrator Infrastructure Management",
      imageUrl: "assets/company_image2.jpg",
      expectedSalary: "₹ 6 LPA (Expected)",
    ),
  ];

  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColors.surface,
        title: Row(
          children: [
            Text(
              'Browse new, ',
              style: TextStyle(
                color: ThemeColors.textSecondary,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'OPPORTUNITIES',
              style: TextStyle(
                color: ThemeColors.accent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Stacked cards background
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: ThemeColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: ThemeColors.surface.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Main PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _newsItems.length,
            itemBuilder: (context, index) {
              return _buildNewsCard(_newsItems[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(NewsItem newsItem) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 30),
      child: Card(
        elevation: 8,
        color: ThemeColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image with gradient
              ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      ThemeColors.background.withOpacity(0.9),
                    ],
                    stops: const [0.5, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.darken,
                child: Image.asset(
                  newsItem.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),

              // Content
              Column(
                children: [
                  // Top Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildActionButton(
                          icon:
                              _isSaved ? Icons.favorite : Icons.favorite_border,
                          color:
                              _isSaved ? Colors.red : ThemeColors.textPrimary,
                          onTap: () {
                            setState(() {
                              _isSaved = !_isSaved;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.link,
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.share,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Content Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          ThemeColors.background.withOpacity(0.95),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newsItem.title,
                          style: TextStyle(
                            color: ThemeColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          newsItem.subtitle,
                          style: TextStyle(
                            color: ThemeColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColors.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            newsItem.expectedSalary,
                            style: TextStyle(
                              color: ThemeColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeColors.surface.withOpacity(0.3),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
