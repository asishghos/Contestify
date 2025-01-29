import 'package:code_hub/Pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CodingProfilesPage extends StatefulWidget {
  const CodingProfilesPage({Key? key}) : super(key: key);

  @override
  _CodingProfilesPageState createState() => _CodingProfilesPageState();
}

class _CodingProfilesPageState extends State<CodingProfilesPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'Codeforces': TextEditingController(),
    'CodeChef': TextEditingController(),
    'AtCoder': TextEditingController(),
    'LeetCode': TextEditingController(),
  };

  // Custom colors
  final Color primaryColor = const Color(0xFF1E88E5);
  final Color backgroundColor = const Color(0xFF121212);
  final Color surfaceColor = const Color(0xFF1E1E1E);
  final Color accentColor = const Color(0xFF64B5F6);
  final Color textPrimaryColor = const Color(0xFFE0E0E0);
  final Color textSecondaryColor = const Color(0xFF9E9E9E);
  final Color cardColor = const Color(0xFF252525);

  Map<String, String> initialValues = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExistingData();
  }

  @override
  void dispose() {
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> fetchExistingData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("username")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          controllers.forEach((key, controller) {
            controller.text = data?[key] ?? '';
            initialValues[key] = data?[key] ?? '';
          });
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> uploadUsername() async {
    try {
      Map<String, dynamic> updateData = {
        'uid': FirebaseAuth.instance.currentUser!.uid,
      };

      controllers.forEach((key, controller) {
        if (controller.text.trim() != initialValues[key]) {
          updateData[key] = controller.text.trim();
        }
      });

      if (updateData.length > 1) {
        await FirebaseFirestore.instance
            .collection("username")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set(updateData, SetOptions(merge: true));

        Get.snackbar(
          'Success',
          'Profiles updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: primaryColor.withOpacity(0.2),
          colorText: textPrimaryColor,
          duration: const Duration(seconds: 2),
        );
      }

      Get.back();
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'Failed to update profiles',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: textPrimaryColor,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        cardColor: cardColor,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: accentColor,
          surface: surfaceColor,
          background: backgroundColor,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Coding Profiles',
              style: TextStyle(color: textPrimaryColor)),
          backgroundColor: surfaceColor,
          elevation: 0,
          iconTheme: IconThemeData(color: textPrimaryColor),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  surfaceColor,
                                  cardColor,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.code,
                                  size: 56,
                                  color: accentColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Edit Your Coding Profiles',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Update your competitive programming usernames',
                                  style: TextStyle(
                                    color: textSecondaryColor,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...controllers.entries
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: TextFormField(
                                  controller: entry.value,
                                  style: TextStyle(color: textPrimaryColor),
                                  decoration: InputDecoration(
                                    labelText: entry.key,
                                    labelStyle:
                                        TextStyle(color: textSecondaryColor),
                                    hintText:
                                        'Enter your ${entry.key} username',
                                    hintStyle: TextStyle(
                                        color: textSecondaryColor
                                            .withOpacity(0.7)),
                                    filled: true,
                                    fillColor: surfaceColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: primaryColor.withOpacity(0.5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: accentColor),
                                    ),
                                    prefixIcon: Icon(Icons.person_outline,
                                        color: primaryColor),
                                    suffixIcon: entry.value.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(Icons.clear,
                                                color: textSecondaryColor),
                                            onPressed: () {
                                              setState(() {
                                                entry.value.clear();
                                              });
                                            },
                                          )
                                        : null,
                                  ),
                                  validator: (value) {
                                    if (value != null &&
                                        value.isNotEmpty &&
                                        value.length < 3) {
                                      return 'Username must be at least 3 characters long';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            )
                            .toList(),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await uploadUsername();
                              Get.to(HomePage());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            //onPrimary: textPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
}
