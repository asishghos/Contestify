import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ContestDetailsPage extends StatelessWidget {
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

  Color getPlatformColor(int id) {
    switch (id) {
      case 1:
        return Colors.blue; // Codeforces
      case 2:
        return Colors.brown; // CodeChef
      case 93:
        return Colors.blue[800]!; // AtCoder
      case 126:
        return Colors.green; // GeeksforGeeks
      case 136:
        return Colors.orange; // Naukri
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

  Future<void> _addToCalendar() async {
    final Event event = Event(
      title: this.event,
      description: 'Coding contest on ${getPlatformName(platformId)}',
      location: link,
      startDate: DateTime.parse(startTime),
      endDate: DateTime.parse(endTime),
    );
    await Add2Calendar.addEvent2Cal(event);
  }

  // Future<void> _setReminder(BuildContext context) async {
  //   final FlutterLocalNotificationsPlugin notifications =
  //       FlutterLocalNotificationsPlugin();

  //   final startDate = DateTime.parse(startTime);
  //   final reminderTime = startDate.subtract(const Duration(minutes: 30));

  //   final AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //     'contest_reminders',
  //     'Contest Reminders',
  //     channelDescription: 'Notifications for coding contests',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //     color: getPlatformColor(platformId),
  //   );

  //   final NotificationDetails details =
  //       NotificationDetails(android: androidDetails);

  //   await notifications.schedule(
  //     platformId, // Use platformId as notification id
  //     'Contest Reminder: $event',
  //     'Contest starts in 30 minutes on ${getPlatformName(platformId)}',
  //     reminderTime,
  //     details,
  //   );

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Reminder set for $event'),
  //       backgroundColor: getPlatformColor(platformId),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final platformColor = getPlatformColor(platformId);
    final time = double.parse(duration) / 60;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: platformColor.withOpacity(0.1),
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
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: platformColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Platform Icon and Name
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "https://clist.by" + iconUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.code,
                          color: platformColor,
                          size: 40,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    getPlatformName(platformId),
                    style: TextStyle(
                      color: platformColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Contest Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Time Details
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Start Time',
                    formatDateTime(startTime),
                    platformColor,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'End Time',
                    formatDateTime(endTime),
                    platformColor,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.timer_outlined,
                    'Duration',
                    '$time minutes',
                    platformColor,
                  ),
                  const SizedBox(height: 32),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Add Reminder',
                          Icons.notifications_active,
                          platformColor,
                          () {
                            //  _setReminder(context)
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'Add to Calendar',
                          Icons.calendar_month,
                          platformColor,
                          _addToCalendar,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'Register Now',
                    Icons.login,
                    platformColor,
                    () async {
                      final url = Uri.parse(link);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ],
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
