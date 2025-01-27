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

  // Track initial values for comparison
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

      // Only include fields that have changed
      controllers.forEach((key, controller) {
        if (controller.text.trim() != initialValues[key]) {
          updateData[key] = controller.text.trim();
        }
      });

      // If there are changes, update Firestore
      if (updateData.length > 1) {
        // > 1 because 'uid' is always included
        await FirebaseFirestore.instance
            .collection("username")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set(updateData, SetOptions(merge: true));

        Get.snackbar(
          'Success',
          'Profiles updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
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
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coding Profiles'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.code,
                                size: 48,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Edit Your Coding Profiles',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Update your competitive programming usernames',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
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
                                decoration: InputDecoration(
                                  labelText: entry.key,
                                  hintText: 'Enter your ${entry.key} username',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.person_outline),
                                  suffixIcon: entry.value.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
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
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Show a loading indicator or do something before saving
                            await uploadUsername();
                            Get.snackbar(
                              "Success",
                              "Username saved successfully.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: Duration(seconds: 2),
                            );
                            Get.to(HomePage());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 18),
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
