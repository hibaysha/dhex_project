import 'dart:io';
import 'package:dhex_project/constants/apis.dart';
import 'package:dhex_project/provider/user_provider.dart';
import 'package:dhex_project/screens/signin/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  File? _selectedImage; // Stores picked image file
  final ImagePicker _picker = ImagePicker(); // For camera/gallery access
  bool _isUploading = false;
  final TextEditingController _nameController = TextEditingController();

  // Extract user ID from the existing API URL
  String getUserIdFromApi() {
    final url = Apis.getUserData();
    final uri = Uri.parse(url);
    return uri.queryParameters['id'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadUserFirstName();
      userProvider.loadUserProfileData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source, // Camera or Gallery
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85, // Compression (85%)
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          // File size check (max 5MB)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size must be less than 5MB'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImage = file; // Store selected image
        });

        await uploadProfileImage(); // Auto-uploads immediately after selection
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    //Shows popup with Camera/Gallery options, User taps their preference & Calls image picker with selected source
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

  void _showEditNameDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = userProvider.firstName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context);
                  await _updateFirstName(newName);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateFirstName(String newName) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final success = await userProvider.updateFirstName(newName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Name updated successfully!' : 'Failed to update name',
            ),
            backgroundColor: success ? Colors.green : Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating name: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> uploadProfileImage() async {
    if (_selectedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an image first.")),
        );
      }
      return;
    }

    final userId = getUserIdFromApi();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User ID not found in API configuration."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final uri = Uri.parse(Apis.updateUserData());

    try {
      // Create multipart request
      var request = http.MultipartRequest('PUT', uri);

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('keyImage', _selectedImage!.path),
      );

      // IMPORTANT: Add the firstName field to preserve it during image upload
      // Preserve existing name during image upload
      if (userProvider.firstName.isNotEmpty) {
        //requestbodyil add cheyyua
        request.fields['firstName'] = userProvider.firstName;
        request.fields['id'] = "6778f7447fc6f415e56910d5";
      }

      debugPrint('Uploading image to: $uri');
      debugPrint('Request fields: ${request.fields}');
      debugPrint('Request files: ${request.files.map((f) => f.field)}');

      var response = await request.send();

      // Handle response
      final responseBody = await response.stream.bytesToString();
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Profile image uploaded successfully');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile image updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );

          // Reload user data to get updated profile image URL
          await userProvider.loadUserProfileData();
        }
      } else {
        debugPrint('Upload failed with status: ${response.statusCode}');
        debugPrint('Response body: $responseBody');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Upload failed: ${response.reasonPhrase ?? 'Unknown error'}",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Upload error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Network error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  String getProfileImageUrl(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) return '';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color.fromARGB(255, 255, 251, 219),
        elevation: 4,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              //Sign out from Google & Firebase
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();

              //Clear saved login data from SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('email');
              await prefs.remove('name');
              await prefs.remove('image');

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Signin()),
                  (route) => false, // remove all previous routes
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 6),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  // Editable Name
                  return GestureDetector(
                    onTap: _isUploading ? null : _showImageSourceDialog,
                    child: Stack(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: getImageInfo(userProvider.profileImage),
                              fit: BoxFit.cover,
                              onError: (_, __) => setState(() {}),
                            ),
                            color: const Color.fromARGB(255, 255, 249, 231),
                          ),
                        ),
                        if (_isUploading)
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
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
              return GestureDetector(
                onTap: _showEditNameDialog,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.edit, size: 16, color: Colors.grey),
                  ],
                ),
              );
            },
          ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Uploading...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
