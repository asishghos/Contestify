import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final Map<String, bool> isEditing = {};
  final Map<String, TextEditingController> controllers = {};
  final Map<String, String> userData = {
    'username': '',
    'email': '',
    'codeforcesHandle': '',
    'codechefHandle': '',
    'atcoderHandle': '',
    'leetcodeHandle': '',
    'collegeName': '',
    'major': '',
    'graduationYear': '',
    'currentSemester': '',
    'githubHandle': '',
    'linkedinProfile': '',
    'preferredLanguage': '',
  };

  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for all fields
    userData.keys.forEach((field) {
      controllers[field] = TextEditingController();
    });
    fetchExistingData();
  }

  @override
  void dispose() {
    // Dispose all controllers
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> fetchExistingData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('username') // Changed from 'username' to 'username'
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          userData.forEach((key, _) {
            userData[key] = data[key] ?? 'Not set';
            controllers[key]?.text = userData[key] ?? '';
          });
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> updateField(String field, String value) async {
    try {
      await FirebaseFirestore.instance
          .collection('username')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({field: value}, SetOptions(merge: true));

      setState(() {
        userData[field] = value;
        isEditing[field] = false;
      });
    } catch (e) {
      debugPrint('Error updating $field: $e');
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $field')),
      );
    }
  }

  @override
  // Define custom colors
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color darkBlue = const Color(0xFF1565C0);
  final Color textGrey = const Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Profile Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: darkBlue),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Picture Section
          Center(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: lightBlue,
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: lightBlue,
                    child: Icon(Icons.person, size: 50, color: primaryBlue),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: primaryBlue,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18),
                        color: Colors.white,
                        onPressed: () {
                          // Add image picker functionality
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Personal Information Section
          _buildSectionHeader('Personal Information'),
          _buildHandleTile('username', 'Username', Icons.person_outline),
          _buildHandleTile('email', 'Email', Icons.email_outlined),

          const SizedBox(height: 16),

          // Competitive Programming Section
          _buildSectionHeader('Competitive Programming Profiles'),
          _buildHandleTile('codeforcesHandle', 'Codeforces', Icons.code),
          _buildHandleTile('codechefHandle', 'CodeChef', Icons.code),
          _buildHandleTile('atcoderHandle', 'AtCoder', Icons.code),
          _buildHandleTile('leetcodeHandle', 'LeetCode', Icons.code),

          const SizedBox(height: 16),

          // Educational Information Section
          _buildSectionHeader('Educational Information'),
          _buildHandleTile('collegeName', 'College', Icons.school_outlined),
          _buildHandleTile('major', 'Major', Icons.book_outlined),
          _buildHandleTile('graduationYear', 'Graduation Year',
              Icons.calendar_today_outlined),
          _buildHandleTile(
              'currentSemester', 'Current Semester', Icons.timeline_outlined),

          const SizedBox(height: 16),

          // Settings Section
          _buildSectionHeader('Settings'),
          Card(
            elevation: 0,
            color: lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Enable Notifications',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w500)),
                  subtitle: Text('Receive push notifications',
                      style: TextStyle(color: textGrey)),
                  value: notificationsEnabled,
                  activeColor: primaryBlue,
                  onChanged: (bool value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),
                Divider(height: 1, color: Colors.blue.withOpacity(0.1)),
                SwitchListTile(
                  title: Text('Dark Mode',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w500)),
                  subtitle: Text('Enable dark theme',
                      style: TextStyle(color: textGrey)),
                  value: darkModeEnabled,
                  activeColor: primaryBlue,
                  onChanged: (bool value) {
                    setState(() {
                      darkModeEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Change Password Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Add change password functionality
            },
            child: const Text(
              'Change Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: darkBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHandleTile(String field, String displayName, IconData icon) {
    return Card(
      elevation: 0,
      color: lightBlue,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: primaryBlue),
        title: Text(
          displayName,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: isEditing[field] == true
            ? TextField(
                controller: controllers[field],
                decoration: InputDecoration(
                  hintText: 'Enter your $displayName',
                  hintStyle: TextStyle(color: textGrey),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) => updateField(field, value),
              )
            : Text(
                userData[field] ?? '',
                style: TextStyle(color: textGrey),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditing[field] == true) ...[
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () =>
                    updateField(field, controllers[field]?.text ?? ''),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    controllers[field]?.text = userData[field] ?? '';
                    isEditing[field] = false;
                  });
                },
              ),
            ] else
              IconButton(
                icon: Icon(Icons.edit, color: primaryBlue),
                onPressed: () {
                  setState(() {
                    isEditing[field] = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Logout', style: TextStyle(color: Colors.blue)),
          content: Text('Are you sure you want to logout?',
              style: TextStyle(color: Colors.black, fontSize: 20)),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  print("User logged out successfully.");
                } catch (e) {
                  print("Error during logout: $e");
                }
                Get.back();
              },
              child: Text('Logout',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
