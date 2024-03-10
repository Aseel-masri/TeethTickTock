import 'package:flutter/material.dart';
import 'package:untitled/MessagesUserList.dart';

class SelectedLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // toolbarTextStyle: TextStyle(color: customColor),
        // titleTextStyle: TextStyle(color: customColor),
        iconTheme: IconThemeData(color: customColor),
        backgroundColor: const Color(0xFF389AAB),
        title: Center(
          child: Image.asset(
            'images/logo4.png',
            width: 100.0,
            height: 100.0,
            color: const Color(0xFFBBF1FA),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 40,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Color.fromARGB(255, 56, 154, 171),
              Color.fromARGB(255, 74, 201, 224),
              Color.fromARGB(255, 187, 239, 250)
            ])),
        // color: const Color(0xFF389AAB),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300, // Adjust width to make the image larger
                height: 300, // Adjust height as needed
                child: Image.asset(
                  color: const Color(0xFFBBF1FA),
                  'images/logo2.png', // Adjust the path to match your image location
                ),
              ),
              // Optional
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.7, // Adjust button width as needed
                height: MediaQuery.of(context).size.height *
                    0.1, // Adjust button height as needed
                child: ElevatedButton(
                  onPressed: () {
                    // Handle user login
                    Navigator.pushNamed(context, "SignUp");
                  },
                  child: Text('Patient'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBBF1FA),
                    foregroundColor: const Color(0xFF389AAB),
                    textStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.7, // Adjust button width as needed
                height: MediaQuery.of(context).size.height *
                    0.1, // Adjust button height as needed
                child: ElevatedButton(
                  onPressed: () {
                    // Handle admin login
                    Navigator.pushNamed(context, "SignUpDoctor");
                  },
                  child: Text('Doctor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBBF1FA),
                    foregroundColor: const Color(0xFF389AAB),
                    textStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.7, // Adjust button width as needed
                height: MediaQuery.of(context).size.height *
                    0.1, // Adjust button height as needed
                // child: ElevatedButton(
                //   onPressed: () {
                //     // Handle doctor login
                //   },
                //   child: Text('Doctor'),
                //   style: ElevatedButton.styleFrom(
                //     foregroundColor: const Color(0xFF389AAB),
                //     backgroundColor: const Color(0xFFBBF1FA),
                //     textStyle:
                //         TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                //   ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
