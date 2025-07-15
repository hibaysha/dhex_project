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

  Future<void> saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', user.email ?? '');
    await prefs.setString('name', user.displayName ?? '');
    await prefs.setString('image', user.photoURL ?? '');
  }

  Future<void> uploadSigninInfo() async {
    try {
      final email = userCredential.value?.user?.email;
      if (email == null) return;

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection("user")
              .where("email", isEqualTo: email)
              .get();

      if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection("user").add({
          "email": email,
          "image": userCredential.value?.user?.photoURL,
          "name": userCredential.value?.user?.displayName,
        });
      }
    } catch (e) {
      print('Firestore upload failed: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Sign-in failed: $e');
      return null;
    }
  }

  void _signInWithGoogle() async {
    final result = await signInWithGoogle();
    if (result != null) {
      userCredential.value = result;
      await uploadSigninInfo();
      await saveUserToPrefs(result.user!);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Navigation()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            );
          },
        ),
      ),
    );
  }
}
