import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhex_project/nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  ValueNotifier<UserCredential?> userCredential = ValueNotifier(null);
  String? savedEmail;
  String? savedName;
  String? savedImage;

  // Save the user's data locally using SharedPreferences
  Future<void> saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', user.email ?? '');
    await prefs.setString('name', user.displayName ?? '');
    await prefs.setString('image', user.photoURL ?? '');
  }

  // Load user data from local storage to skip login if already signed in
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    savedEmail = prefs.getString('email');
    savedName = prefs.getString('name');
    savedImage = prefs.getString('image');

    if (savedEmail != null && savedName != null && savedImage != null) {
      // Navigate to home automatically
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigation()),
        );
      });
    }
  }

  // Upload user info to Firestore if not already present (one document per email)
  Future<void> uploadSigninInfo() async {
    try {
      final email = userCredential.value?.user?.email;

      if (email == null) return;

      // => Check if a document with this email already exists
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection("user")
              .where("email", isEqualTo: email)
              .get();

      // If not found, then add new user info
      if (querySnapshot.docs.isEmpty) {
        final data = await FirebaseFirestore.instance.collection("user").add({
          "email": email,
          "image": userCredential.value?.user?.photoURL,
          "name": userCredential.value?.user?.displayName,
        });

        print('=====Firestore upload successful. Document ID: ${data.id}');
      } else {
        print('=====User already exists in Firestore. No new upload needed.');
      }
    } catch (e) {
      print('=====Firestore upload failed: $e');
    }
  }

  // Initiates Google Sign-In process
  Future<UserCredential?> signInWithGoogle() async {
    try {
      //Triggering Google Sign-In i.e., Opens the Google account picker. If the user cancels, googleUser is null.
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        debugPrint("======Google Sign-In cancelled by user");
        return null;
      }

      debugPrint("=======Google account selected: ${googleUser.email}");

      //Retrieves Authentication Tokens - accessToken and idToken needed for Firebase.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      //Combines the tokens into a format Firebase can understand
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint('=====Sign-in failed: $e');
      return null;
    }
  }

  // Optional sign-out method if needed elsewhere
  Future<bool> signOutFromGoogle() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    return true;
  }

  // Main logic for signing in with Google and saving data
  void _signInWithGoogle() async {
    final result = await signInWithGoogle();

    if (result != null) {
      //Save the UserCredential to a local variable - Stores the signed-in user in a ValueNotifier for UI display and upload
      userCredential.value = result;
      await uploadSigninInfo(); // only upload if login worked
      await saveUserToPrefs(result.user!); // <--- save to shared prefs

      debugPrint('====Signed in as ${result.user!.email}');

      if (mounted) {
        //Navigate to Next Page on Success - Redirects user to the main app after successful sign-in.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigation()),
        );
      }
    } else {
      debugPrint('Google Sign-In failed or cancelled');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserFromPrefs(); // Load local sign-in info on startup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: userCredential,
          builder: (context, value, child) {
            return (userCredential.value == null && savedEmail == null)
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Sign In using Google",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          userCredential.value?.user?.photoURL ??
                              savedImage ??
                              '',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userCredential.value?.user?.displayName ??
                            savedName ??
                            '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userCredential.value?.user?.email ?? savedEmail ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
          },
        ),
      ),
    );
  }
}
