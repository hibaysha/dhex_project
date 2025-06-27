import 'dart:convert';
import 'package:dhex_project/constants/apis.dart';
import 'package:dhex_project/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  String _firstName = '';
  String _profileImage = '';

  String get firstName => _firstName;
  String get profileImage => _profileImage;

  Future<void> loadUserFirstName() async {
    final url = Uri.parse(Apis.getUserData());
    debugPrint('Loading user data from: ${Apis.getUserData()}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('GET Response Status: ${response.statusCode}');
      debugPrint('GET Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final user = userModelFromJson(response.body);
        _firstName = user.firstName ?? '';
        _profileImage = user.profileImage ?? '';

        debugPrint('Extracted First Name: $_firstName');
        debugPrint('Extracted Profile Image: $_profileImage');
        notifyListeners();
      } else {
        debugPrint('Failed to fetch user data: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        throw Exception('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
      rethrow;
    }
  }

  Future<bool> updateFirstName(String newFirstName) async {
    if (newFirstName.trim().isEmpty) {
      debugPrint("First name cannot be empty");
      return false;
    }
    debugPrint("newFirst name is $newFirstName");

    final url = Uri.parse(Apis.updateUserData());

    final requestBody = jsonEncode({
      'firstName': newFirstName,
      "id": "6778f7447fc6f415e56910d5",
    });

    debugPrint('Updating first name to: $newFirstName');
    debugPrint('PUT URL: $url');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      debugPrint('PUT Response Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _firstName = newFirstName;
        notifyListeners();

        debugPrint('First name updated successfully');
        return true;
      } else {
        debugPrint('Failed to update first name');
        debugPrint('Body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint("🔥 Error updating first name: $e");
      return false;
    }
  }

  Future<void> loadUserProfileData() async {
    await loadUserFirstName();
  }
}
