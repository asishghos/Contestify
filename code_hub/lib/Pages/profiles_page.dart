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

  @override
  void dispose() {
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> uploadUsername() async {
    try {
      final data = await FirebaseFirestore.instance
          .collection("username")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'Codeforces': controllers['Codeforces']?.text.trim(),
        'CodeChef': controllers['CodeChef']?.text.trim(),
        'AtCoder': controllers['AtCoder']?.text.trim(),
        'LeetCode': controllers['LeetCode']?.text.trim(),
      });
      //print(data);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coding Profiles'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                          'Enter Your Coding Profiles',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add your competitive programming usernames',
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
                    await uploadUsername();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Profiles',
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
