import 'package:dhex_project/constants/apis.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  String _firstName = '';
  String _profileImage = '';

  String get firstName => _firstName;
  String get profileImage => _profileImage;

  Future<void> loadUserFirstName() async {
    final url = Uri.parse(Apis.getUserData());
    debugPrint(Apis.getUserData());

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final user = userModelFromJson(response.body);
        _firstName = user.firstName ?? '';
        _profileImage = user.profileImage ?? '';

        debugPrint('Extracted First Name: $_firstName');
        debugPrint('Extracted Profile Image: $_profileImage');
        notifyListeners();
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  Future<void> loadUserProfileData() async {
    await loadUserFirstName();
  }
}
