import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final Map<String, bool> isEditing = {};
  final Map<String, TextEditingController> controllers = {};
  final Map<String, String> userData = {
    'name': '',
    'email': '',
    'Codeforces': '',
    'CodeChef': '',
    'AtCoder': '',
    'LeetCode': '',
    'collegeName': '',
    'major': '',
    'graduationYear': '',
    'currentSemester': '',
    'githubHandle': '',
    'linkedinProfile': '',
    'preferredLanguage': '',
    'imageURL': '',
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
          .collection('username')
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

  Future<void> resetPasswordEmail() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: userData['email'] ?? '');
      Get.snackbar(
        'Success',
        'Email sent successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: textPrimaryColor,
        duration: Duration(seconds: 1),
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error to reset password',
        e.message!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: textPrimaryColor,
        duration: Duration(seconds: 2),
      );
    }
  }

  File _selectedImage = File('');
  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
        });
        updateField('imageURL', result.files.single.path!);
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
// Define custom colors for dark theme
  final Color primaryColor = const Color(0xFF1E88E5); // Slightly muted blue
  final Color backgroundColor = const Color(0xFF121212); // Dark background
  final Color surfaceColor = const Color(0xFF1E1E1E); // Slightly lighter dark
  final Color accentColor = const Color(0xFF64B5F6); // Light blue accent
  final Color textPrimaryColor = const Color(0xFFE0E0E0); // Light grey text
  final Color textSecondaryColor = const Color(0xFF9E9E9E); // Medium grey text
  final Color cardColor = const Color(0xFF252525); // Dark card background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: surfaceColor,
        title: Text(
          'Profile Settings',
          style: TextStyle(
            color: textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: accentColor),
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
                      color: cardColor,
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: surfaceColor,
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              File(userData['imageURL']!),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: backgroundColor, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: primaryColor,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18),
                        color: textPrimaryColor,
                        onPressed: () {
                          _pickImage();
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
          _buildHandleTile('name', 'name', Icons.person_outline),
          _buildHandleTile('email', 'Email', Icons.email_outlined),

          const SizedBox(height: 16),

          // Competitive Programming Section
          _buildSectionHeader('Competitive Programming Profiles'),
          _buildHandleTile('Codeforces', 'Codeforces Handle', Icons.code),
          _buildHandleTile('CodeChef', 'CodeChef Handle', Icons.code),
          _buildHandleTile('AtCoder', 'AtCoder Handle', Icons.code),
          _buildHandleTile('LeetCode', 'LeetCode Handle', Icons.code),

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
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Enable Notifications',
                      style: TextStyle(
                          color: textPrimaryColor,
                          fontWeight: FontWeight.w500)),
                  subtitle: Text('Receive push notifications',
                      style: TextStyle(color: textSecondaryColor)),
                  value: notificationsEnabled,
                  activeColor: primaryColor,
                  onChanged: (bool value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),
                Divider(height: 1, color: surfaceColor),
                SwitchListTile(
                  title: Text('Dark Mode',
                      style: TextStyle(
                          color: textPrimaryColor,
                          fontWeight: FontWeight.w500)),
                  subtitle: Text('Enable dark theme',
                      style: TextStyle(color: textSecondaryColor)),
                  value: darkModeEnabled,
                  activeColor: primaryColor,
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
              backgroundColor: primaryColor,
              foregroundColor: textPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Get.defaultDialog(
                backgroundColor: cardColor,
                buttonColor: primaryColor,
                cancelTextColor: textSecondaryColor,
                confirmTextColor: textPrimaryColor,
                title: 'Are you sure you want to reset your password?',
                titleStyle: TextStyle(color: textPrimaryColor),
                onCancel: () {},
                onConfirm: () async {
                  await resetPasswordEmail();
                },
              );
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
          color: accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHandleTile(String field, String displayName, IconData icon) {
    return Card(
      elevation: 0,
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(
          displayName,
          style: TextStyle(
            color: textPrimaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: isEditing[field] == true
            ? TextField(
                controller: controllers[field],
                style: TextStyle(color: textPrimaryColor),
                decoration: InputDecoration(
                  hintText: 'Enter your $displayName',
                  hintStyle: TextStyle(color: textSecondaryColor),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) => updateField(field, value),
              )
            : Text(
                userData[field] ?? '',
                style: TextStyle(color: textSecondaryColor),
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
                icon: Icon(Icons.edit, color: accentColor),
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
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Logout', style: TextStyle(color: accentColor)),
          content: Text('Are you sure you want to logout?',
              style: TextStyle(color: textPrimaryColor, fontSize: 20)),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: textSecondaryColor,
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
                      color: Colors.redAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
