import 'dart:convert';
import 'package:code_hub/Models/contest_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClistApi {
  Future<ContestModel> fetchData() async {
    // Get the current date and time in the required format
    final DateTime now = DateTime.now();
    final String currentDateTime =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T"
        "${now.hour.toString().padLeft(2, '0')}%3A${now.minute.toString().padLeft(2, '0')}%3A${now.second.toString().padLeft(2, '0')}";

    // Replace the date in the URL
    final Uri url = Uri.parse(
        "https://clist.by/api/v1/contest/?username=asishgh&api_key=311318ccc97f6fd1d41d57634c270146aeada4a2&end__gt=$currentDateTime&order_by=start&duration__lt=999999");

    // Check if data is already saved in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('contestData');

    if (cachedData != null) {
      // If cached data is available, use it
      final data = jsonDecode(cachedData);
      return ContestModel.fromJson(data);
    } else {
      // If no cached data, fetch from API
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save data to SharedPreferences for future use
        prefs.setString('contestData', jsonEncode(data));

        return ContestModel.fromJson(data);
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode}, ${response.body}');
      }
    }
  }
}
