import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:untitled/BookedAppointments.dart';
import 'package:untitled/Categories.dart';
import 'package:untitled/HomePage.dart';
import 'package:untitled/Messages.dart';
import 'package:untitled/MessagesUserList.dart';
import 'package:untitled/Posts.dart';
import 'package:untitled/Profile/doctorHomePage.dart';
import 'package:untitled/Profile/Review.dart';
import 'package:untitled/Quickconsultation.dart';
import 'package:untitled/SendEmail.dart';
import 'package:untitled/UserProfile.dart';
import 'package:untitled/auth/LogIn.dart';
import 'package:untitled/auth/SelectedLogIn.dart';
import 'package:untitled/auth/SignUp.dart';
import 'package:untitled/auth/SignUpDoctor.dart';
import 'package:untitled/auth/WelcomePage.dart';
import 'package:untitled/servicies/api.dart';
import 'package:untitled/specialty.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'package:untitled/auth/WelcomePage.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:untitled/auth/WelcomePage.dart';

// //run when app is terminated //in the background //send notification
// Future backgroundMessage(RemoteMessage message) async {
//   print("********************background notification");
//   print("${message.notification!.body}");
// }
var fbm = FirebaseMessaging.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(backgroundMessage);
/*     StreamSubscription<void>updateOnTimeFieldSubscription = Api.streamUpdateOnTimeField().listen((_) {
    print("onTime field updated (real-time)");

    // Update your UI or perform actions based on updating onTime field
  }); */
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  //var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      android:
          initializationSettingsAndroid /* , iOS: initializationSettingsIOS */);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  print("==================================================");
  fbm.getToken().then((token) {
    print(token);
  });
  print("aseel==================================================");
  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

//** aseel noti*/
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

  // Display the notification using local notifications
  displayNotification(message.data);
}

void displayNotification(Map<String, dynamic> data) async {
  // Notification details
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id', // Change this to a unique channel ID
    'Your channel name',
    importance: Importance.high,
    priority: Priority.high,
  );
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  // Build the notification
  await FlutterLocalNotificationsPlugin().show(
    0, // Notification ID (you can use a different ID for each notification)
    data['title'] ?? 'New Notification',
    data['body'] ?? 'You have a new notification',
    platformChannelSpecifics,
    payload: jsonEncode(data),
  );
}

/**** */
// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  Color textColor = const Color(0xFFBBF1FA); // Define custom color
  Color primaryColor = const Color(0xFF389AAB); // Custom button color
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
      // home: DoctorHomePage(),
      // home: BookedAppointments(),
      // home: Messages(),
      // home: Posts(),
      routes: {
        "LogIn": (context) => LogIn(),
        "SignUp": (context) => SignUp(),
        "SignUpDoctor": (context) => SignUpDoctor(),
        "HomePage": (context) => HomePage(),
        "SelectedLogin": (context) => SelectedLogin(),
        "Categories": (context) => Categories(),
        "Specialty": (context) => Specialty(),
        "Quickconsultation": (context) => Quickconsultation(),
        "BookedAppointments": (context) => BookedAppointments(),
        "Messages": (context) => Messages(),
        "UserProfile": (context) => UserProfile(),
        "DoctorHomePage": (context) => DoctorHomePage(),
        "MessagesUserList": (context) => MessagesUserList(),
        "Posts": (context) => Posts(),
        "SendEmail": (context) => SendEmail(),
        "Review": (context) => Review(),
        // "Posts":(context) => Posts()
      },
    );
  }
}
