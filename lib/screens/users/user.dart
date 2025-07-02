import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("user").get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data here :('));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final user = doc.data() as Map<String, dynamic>;

              return Dismissible(
                key: ValueKey(doc.id),
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Update on swipe right
                    final newName = await _showEditDialog(user['name']);
                    if (newName != null && newName.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection("user")
                          .doc(doc.id)
                          .update({'name': newName});
                      setState(() {}); // Refresh the list
                    }
                    return false; // Don't dismiss the tile
                  } else if (direction == DismissDirection.endToStart) {
                    // Delete on swipe left
                    await FirebaseFirestore.instance
                        .collection("user")
                        .doc(doc.id)
                        .delete();
                    return true; // Remove from list
                  }
                  return false;
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['image'] ?? ''),
                  ),
                  title: Text(user['name'] ?? 'No name'),
                  subtitle: Text(user['email'] ?? 'No email'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _showEditDialog(String currentName) async {
    final controller = TextEditingController(text: currentName);
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Name'),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
