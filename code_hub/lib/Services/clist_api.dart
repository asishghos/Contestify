import 'dart:convert';
import 'package:code_hub/Models/contest_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClistApi {
  Future<ContestModel> fetchData() async {
    final DateTime now = DateTime.now();
    final String currentDateTime =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T"
        "${now.hour.toString().padLeft(2, '0')}%3A${now.minute.toString().padLeft(2, '0')}%3A${now.second.toString().padLeft(2, '0')}";

    // TODO: SECURITY - Move API key to environment variables or secure storage
    // Never commit API keys to version control
    final Uri url = Uri.parse(
        "https://clist.by/api/v1/contest/?username=asishgh&api_key=311318ccc97f6fd1d41d57634c270146aeada4a2&end__gt=$currentDateTime&order_by=start&duration__lt=999999");

    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('contestData');
    final cacheTimestamp = prefs.getInt('contestDataTimestamp') ?? 0;
    
    // Cache expires after 1 hour (3600 seconds)
    const cacheExpirationSeconds = 3600;
    final cacheAge = (now.millisecondsSinceEpoch ~/ 1000) - cacheTimestamp;
    final isCacheValid = cachedData != null && cacheAge < cacheExpirationSeconds;

    if (isCacheValid) {
      final data = jsonDecode(cachedData);
      return ContestModel.fromJson(data);
    } else {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('contestData', jsonEncode(data));
        await prefs.setInt('contestDataTimestamp', now.millisecondsSinceEpoch ~/ 1000);

        return ContestModel.fromJson(data);
      } else {
        // If API fails but we have stale cache, return it
        if (cachedData != null) {
          final data = jsonDecode(cachedData);
          return ContestModel.fromJson(data);
        }
        throw Exception(
            'Failed to load data: ${response.statusCode}, ${response.body}');
      }
    }
  }
}
