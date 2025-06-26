import 'package:dhex_project/constants/apis.dart';
import 'package:dhex_project/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  // Method to get complete image URL
  String getProfileImageUrl(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) {
      return '';
    }
    // append
    return '${Apis.imageAppend}$profileImage';
  }

  ImageProvider getImageInfo(String? apiProfileImage) {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (apiProfileImage != null && apiProfileImage.isNotEmpty) {
      return NetworkImage(getProfileImageUrl(apiProfileImage));
    } else {
      return const AssetImage('assets/profile.jpg');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUserFirstName();
      // Load user profile data including profile image
      Provider.of<UserProvider>(context, listen: false).loadUserProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color.fromARGB(255, 255, 251, 219),
        elevation: 4,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 6),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: getImageInfo(userProvider.profileImage),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Handle network image error by falling back to asset image
                            setState(() {
                              // This will trigger a rebuild with the fallback image
                            });
                          },
                        ),
                        color: Colors.brown,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final name =
                  userProvider.firstName.isNotEmpty
                      ? userProvider.firstName
                      : 'No name set';
              return Text(name, style: const TextStyle(fontSize: 17));
            },
          ),
        ],
      ),
    );
  }
}
