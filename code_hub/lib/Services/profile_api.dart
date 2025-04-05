import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_hub/Models/profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ProfileApi {
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

        if (documentSnapshot.exists) {
          Map<String, dynamic>? data = documentSnapshot.data();

          if (data != null) {
            atcoder = data['AtCoder'] ?? '';
            codeforces = data['Codeforces'] ?? '';
            codechef = data['CodeChef'] ?? '';
            leetcode = data['LeetCode'] ?? '';
          } else {}
        } else {}
      } else {}
    } catch (e) {
      rethrow;
    }
  }

  Future<CodeforcesModel> fetchDataCodeforces() async {
    await fetchUserData();
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
    await fetchUserData();
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
    await fetchUserData();
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
