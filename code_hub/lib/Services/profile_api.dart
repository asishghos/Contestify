import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_hub/Models/profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as Developer;

class ProfileApi {
  // Use singleton pattern to avoid multiple instances and redundant API calls
  static final ProfileApi _instance = ProfileApi._internal();
  factory ProfileApi() => _instance;
  ProfileApi._internal();

  String atcoder = "";
  String codeforces = "";
  String codechef = "";
  String leetcode = "";

  Future<void> fetchUserData() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        Developer.log("Fetching data for user with UID: $uid");

        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await FirebaseFirestore.instance
                .collection('username')
                .doc(uid)
                .get();

        if (documentSnapshot.exists) {
          Developer.log('Document exists for UID: $uid');
          Map<String, dynamic>? data = documentSnapshot.data();

          if (data != null) {
            atcoder = data['AtCoder'] ?? '';
            codeforces = data['Codeforces'] ?? '';
            codechef = data['CodeChef'] ?? '';
            leetcode = data['LeetCode'] ?? '';

            Developer.log(
                'Data fetched: AtCoder: $atcoder, Codeforces: $codeforces, CodeChef: $codechef, LeetCode: $leetcode');
          } else {
            Developer.log('No data found in the document.');
          }
        } else {
          Developer.log('No document found for the user with UID: $uid');
        }
      } else {
        Developer.log('User is not logged in.');
      }
    } catch (e) {
      Developer.log('Error fetching user data: $e');
      throw e; // Propagate the error for proper error handling
    }
  }

  Future<CodeforcesModel> fetchDataCodeforces() async {
    await fetchUserData(); // Ensure we have the latest username
    if (codeforces.isEmpty) {
      throw Exception('Codeforces username not found');
    }

    final Uri url =
        Uri.parse("https://competeapi.vercel.app/user/codeforces/$codeforces");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CodeforcesModel.fromJson(data);
    } else {
      throw Exception(
          'Failed to load data: ${response.statusCode}, ${response.body}');
    }
  }

  Future<CodechefModel> fetchDataCodechef() async {
    await fetchUserData(); // Ensure we have the latest username
    if (codechef.isEmpty) {
      throw Exception('CodeChef username not found');
    }

    final Uri url =
        Uri.parse("https://competeapi.vercel.app/user/codechef/$codechef");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CodechefModel.fromJson(data);
    } else {
      throw Exception(
          'Failed to load data: ${response.statusCode}, ${response.body}');
    }
  }

  Future<LeetcodeModel> fetchDataLeetcode() async {
    await fetchUserData(); // Ensure we have the latest username
    if (leetcode.isEmpty) {
      throw Exception('LeetCode username not found');
    }

    final Uri url =
        Uri.parse("https://competeapi.vercel.app/user/leetcode/$leetcode");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LeetcodeModel.fromJson(data);
    } else {
      throw Exception(
          'Failed to load data: ${response.statusCode}, ${response.body}');
    }
  }
}
