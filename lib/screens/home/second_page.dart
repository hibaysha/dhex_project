import 'package:dhex_project/screens/home/third_page.dart';
import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  //pass data from page 1 to 2
  //define data in page 1, call same in page 2 w constructors as optional parameters or, positional arguments(required)
  //if using const, use final
  //then just add $and call where u want it
  final String? name;
  final String? email;
  const SecondPage({super.key, this.name, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('name: $name'),
            Text('email: $email'),
            //1
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdPage()),
                );
              },
              child: Text('go to third page'),
            ),
            //2
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('go back'),
            ),
          ],
        ),
      ),
    );
  }
}
