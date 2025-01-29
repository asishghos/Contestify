import 'package:code_hub/Models/contest_model.dart';
import 'package:code_hub/Models/profile_model.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:code_hub/Pages/contest_details_page.dart';
import 'package:code_hub/Pages/profiles_page.dart';
import 'package:code_hub/Services/clist_api.dart';
import 'package:code_hub/Services/profile_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Define custom colors for dark theme
  final Color primaryColor = const Color(0xFF1E88E5); // Slightly muted blue
  final Color backgroundColor = const Color(0xFF121212); // Dark background
  final Color surfaceColor = const Color(0xFF1E1E1E); // Slightly lighter dark
  final Color accentColor = const Color(0xFF64B5F6); // Light blue accent
  final Color textPrimaryColor = const Color(0xFFE0E0E0); // Light grey text
  final Color textSecondaryColor = const Color(0xFF9E9E9E); // Medium grey text
  final Color cardColor = const Color(0xFF252525); // Dark card background

  int _selectedTimeFilter = 1;
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Future<ContestModel> _dataFuture;
  late Future<CodeforcesModel> _dataFuture1;
  late Future<CodechefModel> _dataFuture2;
  late Future<LeetcodeModel> _dataFuture3;

  @override
  void initState() {
    super.initState();
    _dataFuture = ClistApi().fetchData();
    _dataFuture1 = ProfileApi().fetchDataCodeforces();
    _dataFuture2 = ProfileApi().fetchDataCodechef();
    _dataFuture3 = ProfileApi().fetchDataLeetcode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  var width;
  var height;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                _buildCarousel(),
                _buildCarouselIndicators(),
                _buildTimeFilter(),
                const SizedBox(height: 10),
                _buildContestList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: height * 0.41,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.3,
        onPageChanged: (index, reason) {
          setState(() {
            _currentPage = index;
          });
        },
        scrollDirection: Axis.horizontal,
      ),
      items: [
        _buildCarouselItem<CodeforcesModel>(
          future: _dataFuture1,
          onData: (data) => _buildCardCarousel(
            username: data.user.handle,
            rating: data.user.rating.toString(),
            rank: data.user.rank.toString(),
            platform: "Codeforces",
            image: data.user.avatar,
          ),
        ),
        _buildCarouselItem<CodechefModel>(
          future: _dataFuture2,
          onData: (data) => _buildCardCarousel(
            username: data.username,
            rating: data.rating.toString(),
            rank: data.ratingNumber.toString(),
            platform: "Codechef",
            image:
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaUqSojztqZnRXSFvvlm_sX78WOWk7w4ZNxQ&s",
          ),
        ),
        _buildCarouselItem<LeetcodeModel>(
          future: _dataFuture3,
          onData: (data) => _buildCardCarousel(
            username: data.data!.matchedUser!.username ?? 'Unknown',
            rating: data.data?.userContestRanking?.rating?.toString() ?? 'N/A',
            rank: data.data?.userContestRanking?.globalRanking.toString() ??
                'N/A',
            platform: "Leetcode",
            image: data.data?.matchedUser?.profile?.userAvatar ??
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaUqSojztqZnRXSFvvlm_sX78WOWk7w4ZNxQ&s",
          ),
        ),
        _buildCarouselItem<void>(
          future: _dataFuture1,
          onData: (_) => _buildCardCarousel(
            username: "",
            rating: "",
            rank: " ",
            platform: " ",
            image:
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaUqSojztqZnRXSFvvlm_sX78WOWk7w4ZNxQ&s",
          ),
        ),
      ],
    );
  }

  /// Helper method to build a single carousel item with a FutureBuilder.
  Widget _buildCarouselItem<T>({
    required Future<T> future,
    required Widget Function(T data) onData,
  }) {
    return InkWell(
      onTap: () {
        Get.to(CodingProfilesPage());
      },
      child: SizedBox(
        width: width,
        height: height,
        child: FutureBuilder<T>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${snapshot.error}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Please enter your username in the Profile Settings',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Or click here to enter your username',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              return onData(snapshot.data!);
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildCardCarousel({
    required String username,
    required String rating,
    required String rank,
    required String platform,
    required String image,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surfaceColor, cardColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage(image),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            username,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            icon: Icons.star_rounded,
            label: 'Rating',
            value: rating,
            iconColor: Colors.amber,
          ),
          const SizedBox(height: 5),
          _buildStatRow(
            icon: Icons.military_tech_rounded,
            label: 'Rank',
            value: rank,
            iconColor: Colors.purple,
          ),
          const SizedBox(height: 5),
          _buildStatRow(
            icon: Icons.games_rounded,
            label: 'Platform',
            value: platform,
            iconColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Container _buildCarouselIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: _currentPage == index
                  ? LinearGradient(
                      colors: [primaryColor, accentColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: _currentPage == index ? null : surfaceColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: _currentPage == index
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 2,
      backgroundColor: surfaceColor,
      shadowColor: Colors.black26,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello,',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: textSecondaryColor,
            ),
          ),
          Text(
            FirebaseAuth.instance.currentUser!.displayName ?? 'User',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(vertical: 15),
            child: IconButton(
              onPressed: () {
                openAppSettings();
              },
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFilter() {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTimeFilterChip('Later\nToday', 1),
          _buildTimeFilterChip('Later\nIn Future', 2),
          _buildTimeFilterChip('On\nGoing', 3),
          _buildTimeFilterChip('Events', 0),
        ],
      ),
    );
  }

  Widget _buildTimeFilterChip(String label, int index) {
    final isSelected = _selectedTimeFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : textSecondaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  ListView _buildContestList() {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      children: [
        FutureBuilder<ContestModel>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data?.objects == null) {
              return const Center(
                child: Text('No contests available.'),
              );
            } else {
              final data = snapshot.data!;
              final DateTime now = DateTime.now();
              final startOfDay = DateTime(now.year, now.month, now.day);
              final endOfDay = startOfDay.add(const Duration(days: 1));
// Initial filtering with platform IDs and basic validation
              final data2 = data.objects!.where((result) {
                final resultStart = DateTime.parse(result.start!);
                return (result.resource!.id == 93 ||
                        result.resource!.id == 1 ||
                        result.resource!.id == 2 ||
                        result.resource!.id == 126 ||
                        result.resource!.id == 136) &&
                    result.duration != null &&
                    result.event != null &&
                    result.href != null &&
                    result.resource?.name != null &&
                    result.start != null &&
                    result.end != null &&
                    DateTime.tryParse(result.start!) != null &&
                    DateTime.tryParse(result.end!) != null &&
                    DateTime.parse(result.end!)
                        .isAfter(DateTime.parse(result.start!)) &&
                    resultStart.isAfter(startOfDay);
              }).toList();

// Filter for long duration contests
              final dataEvents = data2.where((result) {
                final now = DateTime.now();
                final startTime = DateTime.parse(result.start!);
                final endTime = DateTime.parse(result.end!);

                return result.duration! >= 18000 &&
                    endTime.isAfter(now) &&
                    endTime.difference(startTime).inSeconds >= result.duration!;
              }).toList();

// Filter for today's contests

              final dataToday = data2.where((result) {
                final resultStart = DateTime.parse(result.start!);
                final resultEnd = DateTime.parse(result.end!);

                return resultStart.isAfter(startOfDay) &&
                    resultStart.isBefore(endOfDay) &&
                    resultEnd.isAfter(now) &&
                    result.duration! > 0;
              }).toList();

// Filter for ongoing contests
              final dataOngoing = data2.where((result) {
                final resultStart = DateTime.parse(result.start!);
                final resultEnd = DateTime.parse(result.end!);
                final now = DateTime.now();

                return resultStart.isBefore(now) &&
                    resultEnd.isAfter(now) &&
                    result.duration! > 0 &&
                    now.difference(resultStart).inSeconds <= result.duration! &&
                    resultEnd.difference(resultStart).inSeconds >=
                        result.duration! &&
                    resultEnd.difference(now).inMinutes > 5;
              }).toList();
// Using a column to avoid nested scrolling issues
              if ((data2.isEmpty && _selectedTimeFilter == 2) ||
                  (dataEvents.isEmpty && _selectedTimeFilter == 0) ||
                  (dataToday.isEmpty && _selectedTimeFilter == 1) ||
                  (dataOngoing.isEmpty && _selectedTimeFilter == 3)) {
                return _buildContestItem(
                    duration: 0.toString(),
                    event: "No Contest",
                    link: "",
                    platformName: "Enjoy",
                    endTime: "0000-00-00T00:00:00",
                    iconUrl: "",
                    startTime: "0000-00-00T00:00:00",
                    platformId: 0);
              }
              if (_selectedTimeFilter == 2) {
                return Column(
                  children: data2.map(
                    (result) {
                      return _buildContestItem(
                          duration: result.duration.toString(),
                          event: result.event!,
                          link: result.href!,
                          platformName: result.resource!.name!,
                          endTime: result.end!,
                          iconUrl: result.resource!.icon!,
                          startTime: result.start!,
                          platformId: result.resource!.id ?? 0);
                    },
                  ).toList(),
                );
              }
              if (_selectedTimeFilter == 0) {
                return Column(
                  children: dataEvents.map(
                    (result) {
                      return _buildContestItem(
                          duration: result.duration.toString(),
                          event: result.event!,
                          link: result.href!,
                          platformName: result.resource!.name!,
                          endTime: result.end!,
                          iconUrl: result.resource!.icon!,
                          startTime: result.start!,
                          platformId: result.resource!.id ?? 0);
                    },
                  ).toList(),
                );
              }
              if (_selectedTimeFilter == 1) {
                return Column(
                  children: dataToday.map(
                    (result) {
                      return _buildContestItem(
                          duration: result.duration.toString(),
                          event: result.event!,
                          link: result.href!,
                          platformName: result.resource!.name!,
                          endTime: result.end!,
                          iconUrl: result.resource!.icon!,
                          startTime: result.start!,
                          platformId: result.resource!.id ?? 0);
                    },
                  ).toList(),
                );
              }
              if (_selectedTimeFilter == 3) {
                return Column(
                  children: dataOngoing.map(
                    (result) {
                      return _buildContestItem(
                          duration: result.duration.toString(),
                          event: result.event!,
                          link: result.href!,
                          platformName: result.resource!.name!,
                          endTime: result.end!,
                          iconUrl: result.resource!.icon!,
                          startTime: result.start!,
                          platformId: result.resource!.id ?? 0);
                    },
                  ).toList(),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Container _buildContestItem({
    required String event,
    required String platformName,
    required String iconUrl,
    required String startTime,
    required String endTime,
    required String duration,
    required String link,
    required int platformId,
  }) {
    // Platform-specific styling
    Color getPlatformColor(int id) {
      switch (id) {
        case 1:
          return const Color(0xFF42A5F5); // Codeforces - lighter blue
        case 2:
          return const Color(0xFFBCAAA4); // CodeChef - lighter brown
        case 93:
          return const Color(0xFF64B5F6); // AtCoder - light blue
        case 126:
          return const Color(0xFF81C784); // GeeksforGeeks - lighter green
        case 136:
          return const Color(0xFFFFB74D); // Naukri - lighter orange
        default:
          return Colors.grey[400]!;
      }
    }

    String getPlatformName(int id) {
      switch (id) {
        case 1:
          return 'Codeforces';
        case 2:
          return 'CodeChef';
        case 93:
          return 'AtCoder';
        case 126:
          return 'GeeksforGeeks';
        case 136:
          return 'Naukri';
        default:
          return platformName;
      }
    }

    String formatDateTime(String isoString) {
      final date = DateTime.parse(isoString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }

    var time = double.parse(duration) / 60;
    final platformColor = getPlatformColor(platformId);
    final formattedStartTime = formatDateTime(startTime);
    final formattedEndTime = formatDateTime(endTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(ContestDetailsPage(
              duration: duration,
              endTime: endTime,
              event: event,
              iconUrl: iconUrl,
              link: link,
              platformId: platformId,
              platformName: platformName,
              startTime: startTime,
            ));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        "https://clist.by" + iconUrl,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.code,
                            color: platformColor,
                            size: 14,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        getPlatformName(platformId),
                        style: TextStyle(
                          color: platformColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Upcoming',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event,
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: textSecondaryColor),
                    const SizedBox(width: 4),
                    Text(
                      formattedStartTime,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.timer_outlined,
                        size: 14, color: textSecondaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '$time min',
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
