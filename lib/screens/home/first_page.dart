import 'package:dhex_project/screens/home/second_page.dart';
import 'package:flutter/material.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    String name = 'hiba';
    String email = 'hiba@gmail.com';
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondPage(name: name, email: email),
                ),
              );
            },
            child: Text('go to second  page'),
          ),
        ],
      ),
    );
  }
}
