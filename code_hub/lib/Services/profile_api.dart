import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_hub/Models/profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileApi {
  // Future<DocumentSnapshot> getUserProfile() async {
  //   DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //       .collection("username")
  //       .doc(FirebaseAuth.instance.currentUser?.uid)
  //       .get();
  //   return snapshot;
  // }
  String atcoder = "";
  String codeforces = "";
  String codechef = "";
  String leetcode = "";

  Future<void> fetchUserData() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await FirebaseFirestore.instance
                .collection('username')
                .doc(uid)
                .get();

        // Access fields from the document data
        Map<String, dynamic>? data = documentSnapshot.data();
        if (data != null) {
          atcoder = data['Atcoder'];
          codeforces = data['Codeforces'];
          codechef = data['Codechef'];
          leetcode = data['Leetcode'];
        } else {
          print('No data found for the user.');
        }
      } else {
        print('User is not logged in.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<CodeforcesModel> fetchDataCodeforces() async {
    final Uri url =
        Uri.parse("https://competeapi.vercel.app/user/codeforces/$codeforces");
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('codeforcesProfileData');

    if (cachedData != null) {
      final data = jsonDecode(cachedData);
      return CodeforcesModel.fromJson(data);
    } else {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        prefs.setString('codeforcesProfileData', jsonEncode(data));

        return CodeforcesModel.fromJson(data);
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode}, ${response.body}');
      }
    }
  }

  Future<CodechefModel> fetchDataCodechef() async {
    final Uri url =
        Uri.parse("https://competeapi.vercel.app/user/codechef/$codechef");
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('codechefProfileData');

    if (cachedData != null) {
      final data = jsonDecode(cachedData);
      return CodechefModel.fromJson(data);
    } else {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        prefs.setString('codechefProfileData', jsonEncode(data));

        return CodechefModel.fromJson(data);
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode}, ${response.body}');
      }
    }
  }

  Future<LeetcodeModel> fetchDataLeetcode() async {
    final Uri url =
        Uri.parse("https://competeapi.vercel.app/user/leetcode/$leetcode");
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('leetcodeProfileData');

    if (cachedData != null) {
      final data = jsonDecode(cachedData);
      return LeetcodeModel.fromJson(data);
    } else {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        prefs.setString('leetcodeProfileData', jsonEncode(data));

        return LeetcodeModel.fromJson(data);
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode}, ${response.body}');
      }
    }
  }
}
