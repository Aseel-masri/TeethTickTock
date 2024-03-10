import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color customColor = const Color(0xFFBBF1FA); // Define custom color
    Color buttonColor = const Color(0xFF389AAB); // Custom button color
    // Color textColor = Colors.white; // Text color for the button

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        color: customColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'images/logo2.png', // Adjust the path to match your image location
              width: 600, // Adjust width to make the image larger
              height: 400, // Adjust height as needed
            ),
            SizedBox(
              height: 20,
            ), // Optional spacing between image and other content
            Text(
              textAlign: TextAlign.center,
              'Learn about dentists and their specialties and book easily',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(
                    255, 56, 154, 171), // Use the custom text color
              ),
            ),
            SizedBox(
              height: 70,
            ), // Optional spacing between text and button

            Container(
              height: 70,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "LogIn");
                  // Navigator.pushNamed(context, "Messages");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor, // Background color
                  foregroundColor: customColor, //text color
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // Border radius
                  ),
                ),
                child: Container(
                  height: 70,
                  child: Text(
                    'Let\'s Start',
                    style: TextStyle(
                      color: customColor, // Text color
                      fontSize: 22.0,
                    ),
                  ),
                ),
              ),
            ), // Optional spacing between text and button
          ],
        ),
      ),
    );
  }
}
