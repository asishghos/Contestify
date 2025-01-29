import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class ContestDetailsPage extends StatefulWidget {
  final String event;
  final String platformName;
  final String iconUrl;
  final String startTime;
  final String endTime;
  final String duration;
  final String link;
  final int platformId;

  ContestDetailsPage({
    Key? key,
    required this.event,
    required this.platformName,
    required this.iconUrl,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.link,
    required this.platformId,
  }) : super(key: key);

  @override
  State<ContestDetailsPage> createState() => _ContestDetailsPageState();
}

class _ContestDetailsPageState extends State<ContestDetailsPage> {
  // Custom colors for dark theme
  final Color backgroundColor = const Color(0xFF121212);

  final Color surfaceColor = const Color(0xFF1E1E1E);

  final Color cardColor = const Color(0xFF252525);

  final Color textPrimaryColor = const Color(0xFFE0E0E0);

  final Color textSecondaryColor = const Color(0xFF9E9E9E);

  Color getPlatformColor(int id) {
    switch (id) {
      case 1:
        return const Color(0xFF1E88E5); // Codeforces - using our primary blue
      case 2:
        return const Color(0xFF8D6E63); // CodeChef - warmer brown
      case 93:
        return const Color(0xFF1565C0); // AtCoder - darker blue
      case 126:
        return const Color(0xFF66BB6A); // GeeksforGeeks - softer green
      case 136:
        return const Color(0xFFFF9800); // Naukri - warmer orange
      default:
        return const Color(0xFF9E9E9E); // Default - neutral grey
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
        return widget.platformName;
    }
  }

  String formatDateTime(String isoString) {
    final date = DateTime.parse(isoString);
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _requestCalendarPermissions() async {
    final status = await Permission.calendar.request();
    if (status.isGranted) {
      print('Calendar permission granted');
    } else if (status.isDenied) {
      print('Calendar permission denied');
    } else if (status.isPermanentlyDenied) {
      print(
          'Calendar permission permanently denied. Open settings to grant permission.');
      await openAppSettings();
    }
  }

  Future<void> _addToCalendar() async {
    await _requestCalendarPermissions();
    try {
      final Event event = Event(
        title: this.widget.event,
        description: 'Coding contest on ${getPlatformName(widget.platformId)}',
        location: widget.link,
        startDate: DateTime.parse(widget.startTime),
        endDate: DateTime.parse(widget.endTime),
      );
      await Add2Calendar.addEvent2Cal(event);
      Get.snackbar('Success', 'Event successfully added to calendar.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1));
      print('Event successfully added to calendar.');
    } catch (e) {
      print('Error adding event to calendar: $e');
    }
  }

  var height;

  var width;

  @override
  Widget build(BuildContext context) {
    final platformColor = getPlatformColor(widget.platformId);
    final time = double.parse(widget.duration) / 60;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        cardColor: cardColor,
        colorScheme: ColorScheme.dark(
          surface: surfaceColor,
          background: backgroundColor,
          primary: platformColor,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: platformColor),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      surfaceColor,
                      backgroundColor,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Platform Icon with glow effect
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: platformColor.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          "https://clist.by" + widget.iconUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: platformColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.code,
                                color: platformColor,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      getPlatformName(widget.platformId),
                      style: TextStyle(
                        color: platformColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Contest Details
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event,
                      style: TextStyle(
                        color: textPrimaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Time Details with enhanced styling
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Start Time',
                      formatDateTime(widget.startTime),
                      platformColor,
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'End Time',
                      formatDateTime(widget.endTime),
                      platformColor,
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      Icons.timer_outlined,
                      'Duration',
                      '${time.toStringAsFixed(0)} minutes',
                      platformColor,
                    ),
                    const SizedBox(height: 40),
                    // Action Buttons with gradient
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            'Add Reminder',
                            Icons.notifications_active,
                            platformColor,
                            () {},
                            //wdth: width * 0.1,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            'Add to Calendar',
                            Icons.calendar_month,
                            platformColor,
                            () async {
                              await _addToCalendar();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    _buildActionButton(
                      'Register Now',
                      Icons.login,
                      platformColor,
                      () async {
                        final url = Uri.parse(widget.link);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          Get.snackbar('Error', 'Could not launch the URL.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1));
                        }
                      },
                      fullWidth: true,
                      isPrimary: true,
                      //wdth: width * 0.8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
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
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool fullWidth = false,
    bool isPrimary = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              )
            : null,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.transparent : cardColor,
          foregroundColor: isPrimary ? textPrimaryColor : color,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          elevation: isPrimary ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: color.withOpacity(0.2)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isPrimary ? textPrimaryColor : color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
