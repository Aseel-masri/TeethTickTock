import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled/Profile/doctorprofile.dart';
import 'package:untitled/Profile/editappointment.dart';
import 'package:untitled/Profile/userprofile.dart';
import 'package:untitled/servicies/api.dart';
import 'package:untitled/Notifications.dart' as notif;
import 'package:http/http.dart' as http;

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({Key? key}) : super(key: key);

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

bool isDoctor = true;

class _DoctorHomePageState extends State<DoctorHomePage> {
  bool showspinner = false;
  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);
  // Function to load user data from local storage
  String nameUser = 'user';
  String emailUser = 'user@gmail.com';
  String userID = '1';
  String userImage = '';
  List<dynamic> allnotification = [];
  int notificationVount = 0;
  final LocalStorage storage = new LocalStorage('my_data');

  Map<String, dynamic>? getUserData() {
    // Get the existing data from LocalStorage
    Map<String, dynamic>? existingData = storage.getItem('user_data_new');

    return existingData;
  }

  void getnot() {
    StreamSubscription<void> updateOnTimeFieldSubscription =
        Api.streamUpdateOnTimeField().listen((_) {
      print("onTime field updated (real-time)");
    });
  }

  void loadUserData() {
    // Retrieve user data
    Map<String, dynamic>? userData = getUserData();

    if (userData != null) {
      // Do something with the user data
      setState(() {
        nameUser = userData['name'];
        emailUser = userData['email'];
        userID = userData['id'];
        userImage = "http://10.0.2.2:8081/profileimg/" + userData['profileImg'];
      });
      print('User data loaded: name=$nameUser, email=$emailUser, id=$userID');
      print('Name: ${userData['name']}');
      print('Email: ${userData['email']}');
      print('ID: ${userData['id']}');
    } else {
      print('User data not found.');
    }
  }

  List<Map<String, String>> reservations = [
    {
      "name": "PatientPatientPatient 1",
      "date": "2023-11-17",
      "time": "10:00 AM"
    },
  ];
  late StreamSubscription<List<Map<String, dynamic>>> subscription;

  void getnotifications() {
    subscription = Api.streamNotifications(emailUser)
        .listen((List<Map<String, dynamic>> notifications) {
      print("=====================Notifications Firebase================");
      print(notifications);
      setState(() {
        allnotification = notifications;
      });
      print("=====================Notifications Firebase================");
    });
  }

  late StreamSubscription<int> unreadCount = 0 as StreamSubscription<int>;
  void getnotificationcount() {
    unreadCount =
        Api.streamUnreadNotificationCount(emailUser).listen((int count) {
      setState(() {
        notificationVount = count;
      });
      print("Number of unread notifications (real-time): $count");

      // Update your UI or perform actions based on the unread count
    });
  }

  Future<void> getdoctorappointment() async {
    // Load user data to get userID
    // filterReservationsByDate();
    loadUserData();
    print('userid is $userID');
    // Make API request to get doctor appointment
    final response = await Api.getdoctorappointment(userID);
    // filteredReservations = reservations;
    if (response.statusCode == 200) {
      try {
        // Parse the JSON response
        List<dynamic> parsedJsonList = json.decode(response.body);
        for (var parsedJson in parsedJsonList) {
          String temp = parsedJson['user'];
          print('useridpatient is $temp');
          // Make another API request to get the username
          String nameuser = await Api.getusername(temp ?? '');
          String emailuser = await Api.getuseremail(temp ?? '');
          String usertoken = await Api.getusertoken(temp ?? '');
          // Update the state with the appointment information
          print("nameuser ${nameuser}");
          print("emailuser ${emailuser}");
          print("usertoken ${usertoken}");
          setState(() {
            print(
                'nameuser $nameuser Time ${parsedJson['appointmentTime']} Date ${parsedJson['appointmentDate']}');
            filteredReservations.add({
              "id": parsedJson['_id'],
              "name": nameuser,
              "date": parsedJson['appointmentDate'],
              "time": parsedJson['appointmentTime'],
              "userid": parsedJson['user'],
              "emailuser": emailuser,
              "usertoken": usertoken,
              "appointmentPeriod": parsedJson['appointmentPeriod'].toString(),
            });
          });
        }

        setState(() {
          reservations.clear();
          reservations = filteredReservations;
          // Filter reservations based on the current date
          filterReservationsByDate();
        });
      } catch (error) {
        // Handle JSON parsing errors or other exceptions
        print('Error parsing JSON: $error');
      }
    } else {
      // Handle non-200 status codes
      print('Error: ${response.statusCode} - ${response.body}');
    }
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> _showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      Map<String, dynamic> data) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', // Change this to a unique channel ID
      'Your Channel Name', // Change this to a unique channel name
      //  'Your Channel Description', // Change this to a unique channel description
      importance: Importance.max,
      priority: Priority.high,
    );
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android:
            androidPlatformChannelSpecifics /* , iOS: iOSPlatformChannelSpecifics */);

    await flutterLocalNotificationsPlugin.show(
      0, // Change this to a unique notification ID
      data['title'] ?? 'New Notification',
      data['body'] ?? 'You have a new notification',
      platformChannelSpecifics,
      payload: jsonEncode(data),
    );
  }

  List<Map<String, String>> filteredReservations = [];
  List<Map<String, String>> filteredReservationsSearch = [];
  DateTime? selectedDate;
  void firebaseOnMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      print('onMessage occurred. Message is: ');
      if (message != null) {
        _showNotification(flutterLocalNotificationsPlugin, message.data);
      }
    });
  }

  void onFirebaseOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('onMessageOpenedApp occurred. Message is: ');
      print(event.notification?.title);
      // Additional handling for the notification data or payload can be done here
    });
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.notification?.title}");
    // Handle the background message, e.g., show a notification
  }

  @override
  void initState() {
    firebaseOnMessage();
    onFirebaseOpenedApp();
    //FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    super.initState();
    selectedDate = DateTime.now();
    print("date for today :----------->${selectedDate}");
    getdoctorappointment();
    loadUserData();
    getnotifications();
    getnotificationcount();
    getnot();
    getinfo();
  }

  List<String> timeIntervals = [];
  int timeperiod = 0;
  void getinfo() async {
    print("getinfo userid= $userID");
    final response = await Api.getdoctor(userID ?? '');
    String responseBody = response.body;
    if (responseBody.contains("doctor")) {
      responseBody = responseBody.replaceAll("doctor", "user");
    }
    setState(() {
      Map<String, dynamic> parsedJson = json.decode(responseBody);

      final DateFormat timeFormat = DateFormat('hh:mm a');
      final String start = parsedJson['user']['StartTime'] ?? "8:00 AM";
      final String end = parsedJson['user']['EndTime'] ?? "2:00 PM";
      timeperiod = parsedJson['user']['appointmentTime'] as int;
      final DateTime startTime = timeFormat.parse(start);
      final DateTime endTime = timeFormat.parse(end);

      DateTime currentTime = startTime;
      final Duration increment =
          Duration(minutes: parsedJson['user']['appointmentTime']);
     
    });
  }

  Future<void> updateAppointmentPeriod(
      int i, int updatedAppointmentPeriod) async {
    // Update appointmentPeriod at index i
    //get avaliable times

    setState(() {
      filteredReservations[i]['appointmentPeriod'] =
          updatedAppointmentPeriod.toString();
    });
    // Check for overlapping times and update appointmentPeriod accordingly
    for (int j = 0; j < filteredReservations.length; j++) {
      if (j != i &&
          filteredReservations[i]['date'] == filteredReservations[j]['date'] &&
          isTimeOverlapping(
              filteredReservations[i]['time']!,
              updatedAppointmentPeriod,
              filteredReservations[j]['time']!,
              int.parse(filteredReservations[j]['appointmentPeriod']!),
              i)) {
        setState(() {
          // Update the appointmentPeriod for overlapping times
          print(
              "${filteredReservations[j]['name']} has overlapping in time with ${filteredReservations[i]['name']}");
          final DateFormat timeFormat = DateFormat('hh:mm a');
          DateTime dateTime1 = parseTimeString(
              "${filteredReservations[i]['date']} ${filteredReservations[i]['time']}",
              "yyyy-MM-dd hh:mm a");
          DateTime newTime = dateTime1.add(Duration(
              minutes:
                  int.parse(filteredReservations[i]['appointmentPeriod']!)));
          filteredReservations[j]['time'] = timeFormat.format(newTime);

          updateAppointmentPeriod(
              j, int.parse(filteredReservations[j]['appointmentPeriod']!));
        });

        var data = {
          "appointmentTime": filteredReservations[j]['time'],
        };
        final response =
            await Api.editAppointment(data, filteredReservations[j]['id']!);
        // send data as notification to user
        DateTime now = DateTime.now();
        int hour = now.hour;
        String currentTime;
        if (hour < 12) {
          currentTime = "$hour:${now.minute} AM";
        } else {
          currentTime = "${hour - 12}:${now.minute} PM";
        }
        var datasend = {
          "useremail": filteredReservations[j]['emailuser'], // Name of user
          "content":
              "Your appointment with ${nameUser} has been changed to ${filteredReservations[j]['date']} ${filteredReservations[j]['time']}",
          "title": "Appiontment Update",
          "date": currentTime, //
          "read": false,
          "onTime": true,
          "dateTime": now //
        };
        // add data to firebase database
        FirebaseFirestore.instance
            .collection('notifications')
            .add(datasend)
            .then((DocumentReference document) {
          print('Notification added with ID: ${document.id}');
        }).catchError((error) {
          print('Error adding notification: $error');
        });

        print("send notification number");
        var serverToken =
            "AAAAjxD3gc0:APA91bHJ7Wk4v_wxhhTe93vwHi78rfrZf7VOxWNp6BY7Z-bDOb8fA3Z-jfLpNPpHXqnJu8SO7KYGf06zUWpvWMbi6J_4k7-mSQT1QVbH59bOFhw8IVudg6vs-vZZpM485SyJMd7KrGeZ";
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverToken',
          },
          body: jsonEncode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'body':
                    "Your appointment with ${nameUser} has been changed to ${filteredReservations[j]['date']} ${filteredReservations[j]['time']}",
                'title': "Appiontment Update",
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done',
                'body':
                    "Your appointment with ${nameUser} has been changed to ${filteredReservations[j]['date']} ${filteredReservations[j]['time']}",
                'title': 'Appiontment Update'
              },
              'to': filteredReservations[j]['usertoken'],
            },
          ),
        );
        
      }
    }
  }

  bool isTimeOverlapping(String startTime1, int duration1, String startTime2,
      int duration2, int index) {
    String date = filteredReservations[index]['date']!;

    DateTime dateTime1 =
        parseTimeString("$date $startTime1", "yyyy-MM-dd hh:mm a");
    DateTime endTime1 = dateTime1.add(Duration(minutes: duration1));

    DateTime dateTime2 =
        parseTimeString("$date $startTime2", "yyyy-MM-dd hh:mm a");
    DateTime endTime2 = dateTime2.add(Duration(minutes: duration2));

    return dateTime1.isBefore(endTime2) && endTime1.isAfter(dateTime2);
  }

  DateTime parseTimeString(String timeString, String format) {
    return DateFormat(format).parse(timeString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          iconTheme: IconThemeData(color: customColor),
          centerTitle: true,
          backgroundColor: mainColor,
          title: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("HomePage");
                print("Title Image Tapped");
              },
              child: Image.asset(
                'images/logo4.png',
                width: 100.0,
                height: 100.0,
                color: customColor,
              ),
            ),
          ),
          actions: [
            Stack(children: [
              IconButton(
                iconSize: 37,
                color: customColor,
                icon: Icon(Icons.notifications_active),
                onPressed: () async {
                  notif.Notifications().showNotificationList(context);
                  print("=====================Notifications================");
                  setState(() {
                    notif.notifications.clear();
                    print(allnotification);

                    for (var notificationItem in allnotification) {
                      if (notificationItem.containsKey('title') &&
                          notificationItem.containsKey('content') &&
                          notificationItem.containsKey('date') &&
                          notificationItem.containsKey('read')) {
                        notif.NotificationItem notf = notif.NotificationItem(
                            title: notificationItem['title'] ?? '',
                            content: notificationItem['content'] ?? '',
                            date: notificationItem['date'] ?? '',
                            read: notificationItem['read'] ?? false,
                            timetosend: notificationItem['dateTime'].toDate() ??
                                DateTime.now());
                        notif.notifications.add(notf);
                      } else {
                        print(
                            "Notification item is missing required properties.");
                      }
                    }
                    notif.notifications
                        .sort((a, b) => a.timetosend.compareTo(b.timetosend));
                  });
                },
              ),
              notificationVount != 0
                  ? Positioned(
                      right: 30,
                      top: 2,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red, // You can customize the color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            '$notificationVount',
                            style: TextStyle(
                              color: Colors
                                  .white, // You can customize the text color
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ])
            /*  Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 40,
              ),
            ), */
          ],
          elevation: 6,
          shadowColor: mainColor,
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                nameUser,
                style: TextStyle(fontSize: 20),
              ),
              accountEmail: Text(
                emailUser,
                style: TextStyle(fontSize: 15),
              ),
              currentAccountPicture: userImage == ""
                  ? CircleAvatar(
                      backgroundColor: customColor,
                      backgroundImage: AssetImage("images/logo2.png"),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: mainColor, // Specify the border color here
                            width: 2.0, // Specify the border width here
                          ),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: customColor,
                      backgroundImage: NetworkImage(userImage),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: mainColor, // Specify the border color here
                            width: 2.0, // Specify the border width here
                          ),
                        ),
                      ),
                    ),
              // CircleAvatar(
              //   backgroundColor: customColor,
              //   child: Text(
              //     nameUser.isNotEmpty ? nameUser[0] : 'U',
              //     style: TextStyle(fontSize: 30, color: mainColor),
              //   ),
              // ),
              decoration: BoxDecoration(
                color: mainColor,
              ),
            ),
            ListTile(
              iconColor: mainColor,
              textColor: mainColor,
              title: Text(
                "My Profile",
                style: TextStyle(fontSize: 18),
              ),
              leading: Icon(
                Icons.home,
                size: 35,
              ),
              onTap: () async {
                final response = await Api.getdoctor(userID);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  print(response.body);
                  return Profile(username: response.body);
                }));
                // Navigator.pushNamed(context, "UserProfile");
              },
            ),
            Divider(),
            ListTile(
              iconColor: mainColor,
              textColor: mainColor,
              title: Text(
                "Messages",
                style: TextStyle(fontSize: 18),
              ),
              leading: Icon(
                Icons.message,
                size: 35,
              ),
              onTap: () {
                // Navigator.pushNamed(context, "MessagesUserList",arguments: isDoctor);
                Navigator.pushNamed(context, "MessagesUserList",
                    arguments: isDoctor);
              },
            ),
            Divider(),
            ListTile(
              iconColor: mainColor,
              textColor: mainColor,
              title: Text(
                "Log out",
                style: TextStyle(fontSize: 18),
              ),
              leading: Icon(
                Icons.exit_to_app,
                size: 35,
              ),
              onTap: () async {
                var data = {"token": ""};
                await Api.changeFCMdoctor(data, userID);
                Navigator.pushReplacementNamed(context, "LogIn");
              },
            ),
          ],
        ),
      ),
      /************************body******************************** */
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Text(
                        "Reservations ",
                        style: GoogleFonts.lora(
                          textStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: mainColor,
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: mainColor,
                                offset: Offset(
                                    MediaQuery.of(context).size.width * 0.002,
                                    MediaQuery.of(context).size.width * 0.002),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(
                        Icons.timer_rounded,
                        color: mainColor,
                        size: 35,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      alignment: Alignment.center,
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        // color: Color.fromARGB(255, 74, 201, 224),
                        color: mainColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Select Date",
                            style: GoogleFonts.lora(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  selectedDate != null ? '${selectedDate!.toLocal()}' : 'All',
                  style: GoogleFonts.lora(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20, top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: mainColor),
                        hintText: 'Enter patient name',
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.search,
                          color: mainColor,
                        ),
                      ),
                      // onChanged: (value) {
                      //   setState(() {
                      //     // filteredReservationsSearch = reservations;
                      //     filteredReservations = reservations
                      //         .where((reservations) => reservations['name']!
                      //             .toLowerCase()
                      //             .contains(value.toLowerCase()))
                      //         .toList();
                      //   });
                      // },
                      onChanged: (value) {
                        setState(() {
                          filteredReservations = reservations
                              .where((reservation) =>
                                  reservation['name']!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) &&
                                  (selectedDate == null ||
                                      reservation['date'] ==
                                          formattedDate(selectedDate!)))
                              .toList();
                          filteredReservations.sort((a, b) {
                            // Custom parsing function for the date and time format
                            DateTime dateTimeA =
                                parseDateTime(a['date']!, a['time']!);
                            DateTime dateTimeB =
                                parseDateTime(b['date']!, b['time']!);

                            // Compare reservations based on date and time
                            return dateTimeA.compareTo(dateTimeB);
                          });
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            filteredReservations = reservations;
                            filteredReservations.sort((a, b) {
                              // Custom parsing function for the date and time format
                              DateTime dateTimeA =
                                  parseDateTime(a['date']!, a['time']!);
                              DateTime dateTimeB =
                                  parseDateTime(b['date']!, b['time']!);

                              // Compare reservations based on date and time
                              return dateTimeA.compareTo(dateTimeB);
                            });
                            selectedDate = null;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          alignment: Alignment.center,
                          width: 50,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            // color: Color.fromARGB(255, 74, 201, 224),
                            color: mainColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Display all ",
                                style: GoogleFonts.lora(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            if (filteredReservations.isEmpty)
              Center(
                child: Text('No reservations for the selected date'),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ListView.builder(
                    itemCount: filteredReservations.length,
                    itemBuilder: (context, index) {
                      final reservationDate = parseDateTime(
                          filteredReservations[index]['date']!,
                          filteredReservations[index]['time']!);
                      final currentDate = DateTime.now();
                      final isDisabled = reservationDate.isBefore(currentDate);
                      return isDisabled
                          ? Card(
                              elevation: 1,
                              // shadowColor: mainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color: Color.fromARGB(100, 255, 255, 255),
                              child: Container(
                                height: 80,
                                child: ListTile(
                                  title: Text(
                                    filteredReservations[index]['name']!,
                                    style: GoogleFonts.lora(
                                      textStyle: TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(127, 0, 0, 0),
                                        // color: mainColor,
                                        // fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          style: TextStyle(
                                            color: Color.fromARGB(127, 0, 0, 0),
                                          ),
                                          '${filteredReservations[index]['time']!}'),
                                      // Text(""),
                                      Text(
                                          style: TextStyle(
                                            color: Color.fromARGB(127, 0, 0, 0),
                                          ),
                                          '${filteredReservations[index]['date']!}'),
                                    ],
                                  ),
                                  trailing: IgnorePointer(
                                    ignoring: isDisabled,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete_forever_rounded,
                                        // color: mainColor,
                                        color: Color.fromARGB(126, 35, 34, 34),
                                      ),
                                      onPressed: () {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.question,
                                          animType: AnimType.scale,
                                          title: 'Delete Appointment',
                                          desc:
                                              'Are you sure you want to delete this appointment?',
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () async {
                                            final ress =
                                                await Api.deleteppointmentbyid(
                                                    filteredReservations[index]
                                                        ['id']!);

                                            //send notification to user that his appointment is deleted
                                            DateTime now = DateTime.now();
                                            int hour = now.hour;
                                            String currentTime;
                                            if (hour < 12) {
                                              currentTime =
                                                  "$hour:${now.minute} AM";
                                            } else {
                                              currentTime =
                                                  "${hour - 12}:${now.minute} PM";
                                            }
                                            print(
                                                "useremail: ${filteredReservations[index]['emailuser']}");
                                            print(
                                                "Time: ${filteredReservations[index]['date']}");
                                            print(
                                                "Date: ${filteredReservations[index]['tim']}");
                                            // print("usertoken: ${filteredReservations[index]['token']}");
                                            var data = {
                                              "useremail": filteredReservations[
                                                      index]
                                                  ['emailuser'], // Name of user
                                              "content":
                                                  "Your appointment with ${nameUser} is at ${filteredReservations[index]['date']} ${filteredReservations[index]['time']}",
                                              "title": "Delete Appointment",
                                              "date": currentTime, //
                                              "read": false,
                                              "onTime": true,
                                              "dateTime": now //
                                            };
                                            // add data to firebase database
                                            FirebaseFirestore.instance
                                                .collection('notifications')
                                                .add(data)
                                                .then((DocumentReference
                                                    document) {
                                              print(
                                                  'Notification added with ID: ${document.id}');
                                            }).catchError((error) {
                                              print(
                                                  'Error adding notification: $error');
                                            });
                                            // send data as notification to user
                                            print("send notification number");
                                            var serverToken =
                                                "AAAAjxD3gc0:APA91bHJ7Wk4v_wxhhTe93vwHi78rfrZf7VOxWNp6BY7Z-bDOb8fA3Z-jfLpNPpHXqnJu8SO7KYGf06zUWpvWMbi6J_4k7-mSQT1QVbH59bOFhw8IVudg6vs-vZZpM485SyJMd7KrGeZ";
                                            await http.post(
                                              Uri.parse(
                                                  'https://fcm.googleapis.com/fcm/send'),
                                              headers: <String, String>{
                                                'Content-Type':
                                                    'application/json',
                                                'Authorization':
                                                    'key=$serverToken',
                                              },
                                              body: jsonEncode(
                                                <String, dynamic>{
                                                  'notification':
                                                      <String, dynamic>{
                                                    'body':
                                                        "Your appointment with ${nameUser} is at ${filteredReservations[index]['date']} ${filteredReservations[index]['time']}",
                                                    'title':
                                                        "Delete Appointment",
                                                  },
                                                  'priority': 'high',
                                                  'data': <String, dynamic>{
                                                    'click_action':
                                                        'FLUTTER_NOTIFICATION_CLICK',
                                                    'status': 'done',
                                                    'body':
                                                        "Your appointment with ${nameUser} is at ${filteredReservations[index]['date']} ${filteredReservations[index]['time']}",
                                                    'title':
                                                        'Delete Appointment'
                                                  },
                                                  'to': filteredReservations[
                                                      index]['usertoken'],
                                                },
                                              ),
                                            );
                                            setState(() {
                                              print('isDelete? ${ress.body}');
                                              List<Map<String, String>>
                                                  copyFilteredReservations =
                                                  List.from(
                                                      filteredReservations);
                                              reservations.remove(
                                                  filteredReservations[index]);
                                              copyFilteredReservations
                                                  .removeAt(index);
                                              filteredReservations =
                                                  copyFilteredReservations;
                                            });
                                          },
                                          btnCancelColor:
                                              Color.fromARGB(255, 32, 87, 97),
                                          btnOkColor:
                                              Color.fromARGB(255, 56, 154, 171),
                                          descTextStyle: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 32, 87, 97)),
                                        )..show();
                                      },
                                    ),
                                  ),
                                  onTap: () async {
                                    print(
                                        "${filteredReservations[index]['name']} Navigate to patient page when name is tapped");

                                    final res = await Api.getuserbyid(
                                        filteredReservations[index]['userid']!);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProfileUser(
                                                  userinfo: res.body,
                                                  visit: true,
                                                )));
                                  },
                                ),
                              ),
                            )
                          : Card(
                              elevation: 5,
                              shadowColor: mainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Container(
                                height: 120,
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: mainColor, size: 22),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                actions: [
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Color(
                                                                  0xFF389AAB)),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      'Close',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                        Icons.timer_rounded,
                                                        color: mainColor,
                                                        size: 35,
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        final response =
                                                            await Api.getdoctor(
                                                                userID ?? '');
                                                        String responseBody =
                                                            response.body;
                                                        if (responseBody
                                                            .contains(
                                                                "doctor")) {
                                                          responseBody =
                                                              responseBody
                                                                  .replaceAll(
                                                                      "doctor",
                                                                      "user");
                                                        }
                                                        String dateString =
                                                            filteredReservations[
                                                                index]['date']!;
                                                        DateTime date =
                                                            DateTime.parse(
                                                                dateString);
                                                        List<String>
                                                            daysOfWeek = [
                                                          "Monday",
                                                          "Tuesday",
                                                          "Wednesday",
                                                          "Thursday",
                                                          "Friday",
                                                          "Saturday",
                                                          "Sunday"
                                                        ];
                                                        // Get the day of the week
                                                        String selectday =
                                                            daysOfWeek[
                                                                date.weekday -
                                                                    1];
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  EditAppointment(
                                                                    doctorinfo:
                                                                        responseBody,
                                                                    userid: filteredReservations[
                                                                            index]
                                                                        [
                                                                        'userid']!,
                                                                    appoinmentid:
                                                                        filteredReservations[index]
                                                                            [
                                                                            'id']!,
                                                                    previousTime:
                                                                        filteredReservations[index]
                                                                            [
                                                                            'time']!,
                                                                    previousDate:
                                                                        filteredReservations[index]
                                                                            [
                                                                            'date']!,
                                                                    previousDay:
                                                                        selectday,
                                                                    patientname:
                                                                        filteredReservations[index]
                                                                            [
                                                                            'name']!,
                                                                    patientemail:
                                                                        filteredReservations[index]
                                                                            [
                                                                            'emailuser']!,
                                                                    usertoken: filteredReservations[
                                                                            index]
                                                                        [
                                                                        'usertoken']!,
                                                                  )),
                                                        );
                                                      },
                                                      child: Text(
                                                        'Edit Appointment Time',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF389AAB)),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        TextEditingController
                                                            _textFieldController =
                                                            TextEditingController();

                                                        showDialog<void>(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Time Period'),
                                                              content:
                                                                  TextField(
                                                                controller:
                                                                    _textFieldController,
                                                                decoration:
                                                                    InputDecoration(
                                                                        hintText:
                                                                            'Enter time in minutes here...'),
                                                              ),
                                                              actions: <Widget>[
                                                                ElevatedButton(
                                                                  child: Text(
                                                                      'Cancel'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  child: Text(
                                                                      'OK'),
                                                                  onPressed:
                                                                      () async {
                                                                    // Access the entered text using _textFieldController.text
                                                                    print(
                                                                        'Entered text: ${_textFieldController.text}');
                                                                    var data = {
                                                                      "appointmentPeriod":
                                                                          _textFieldController
                                                                              .text,
                                                                    };
                                                                    final response = await Api.editAppointment(
                                                                        data,
                                                                        filteredReservations[index]
                                                                            [
                                                                            'id']!);
                                                                    updateAppointmentPeriod(
                                                                        index,
                                                                        int.parse(
                                                                            _textFieldController.text));
                                                                    // send data as notification to user
                                                                    DateTime
                                                                        now =
                                                                        DateTime
                                                                            .now();
                                                                    int hour =
                                                                        now.hour;
                                                                    String
                                                                        currentTime;
                                                                    if (hour <
                                                                        12) {
                                                                      currentTime =
                                                                          "$hour:${now.minute} AM";
                                                                    } else {
                                                                      currentTime =
                                                                          "${hour - 12}:${now.minute} PM";
                                                                    }
                                                                    var datasend =
                                                                        {
                                                                      "useremail":
                                                                          filteredReservations[index]
                                                                              [
                                                                              'emailuser'], // Name of user
                                                                      "content":
                                                                          "Your time period appointment ${filteredReservations[index]['date']} ${filteredReservations[index]['time']} has been changed to ${filteredReservations[index]['appointmentPeriod']} minutes",
                                                                      "title":
                                                                          "${nameUser}s  Appiontment Time Period Update",
                                                                      "date":
                                                                          currentTime, //
                                                                      "read":
                                                                          false,
                                                                      "onTime":
                                                                          true,
                                                                      "dateTime":
                                                                          now //
                                                                    };
                                                                    // add data to firebase database
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'notifications')
                                                                        .add(
                                                                            datasend)
                                                                        .then((DocumentReference
                                                                            document) {
                                                                      print(
                                                                          'Notification added with ID: ${document.id}');
                                                                    }).catchError(
                                                                            (error) {
                                                                      print(
                                                                          'Error adding notification: $error');
                                                                    });

                                                                    print(
                                                                        "send notification number");
                                                                    var serverToken =
                                                                        "AAAAjxD3gc0:APA91bHJ7Wk4v_wxhhTe93vwHi78rfrZf7VOxWNp6BY7Z-bDOb8fA3Z-jfLpNPpHXqnJu8SO7KYGf06zUWpvWMbi6J_4k7-mSQT1QVbH59bOFhw8IVudg6vs-vZZpM485SyJMd7KrGeZ";
                                                                    await http
                                                                        .post(
                                                                      Uri.parse(
                                                                          'https://fcm.googleapis.com/fcm/send'),
                                                                      headers: <String,
                                                                          String>{
                                                                        'Content-Type':
                                                                            'application/json',
                                                                        'Authorization':
                                                                            'key=$serverToken',
                                                                      },
                                                                      body:
                                                                          jsonEncode(
                                                                        <String,
                                                                            dynamic>{
                                                                          'notification':
                                                                              <String, dynamic>{
                                                                            'body':
                                                                                "Your time period appointment ${filteredReservations[index]['date']} ${filteredReservations[index]['time']} has been changed to ${filteredReservations[index]['appointmentPeriod']} minutes",
                                                                            'title':
                                                                                "${nameUser}'s  Appiontment Time Period Update",
                                                                          },
                                                                          'priority':
                                                                              'high',
                                                                          'data':
                                                                              <String, dynamic>{
                                                                            'click_action':
                                                                                'FLUTTER_NOTIFICATION_CLICK',
                                                                            'status':
                                                                                'done',
                                                                            'body':
                                                                                "Your time period appointment ${filteredReservations[index]['date']} ${filteredReservations[index]['time']} has been changed to ${filteredReservations[index]['appointmentPeriod']} minutes",
                                                                            'title':
                                                                                "${nameUser}'s  Appiontment Time Period Update"
                                                                          },
                                                                          'to': filteredReservations[index]
                                                                              [
                                                                              'usertoken'],
                                                                        },
                                                                      ),
                                                                    );
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Text(
                                                        "Edit Appointment's Time Period",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF389AAB)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      Text(
                                        filteredReservations[index]['name']!,
                                        style: GoogleFonts.lora(
                                          textStyle: TextStyle(
                                              fontSize: 15,
                                              color: mainColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          '${filteredReservations[index]['time']!}'),
                                      // Text(""),
                                      Text(
                                          '${filteredReservations[index]['date']!}'),
                                      Text(
                                          '${filteredReservations[index]['appointmentPeriod']!} minutes'),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    //  crossAxisAlignment: CrossAxisAlignment.baseline,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: mainColor,
                                        ),
                                        onPressed: () {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.question,
                                            animType: AnimType.scale,
                                            title: 'Delete Appointment',
                                            desc:
                                                'Are you sure you want to delete this appointment?',
                                            btnCancelOnPress: () {},
                                            btnOkOnPress: () async {
                                              final ress = await Api
                                                  .deleteppointmentbyid(
                                                      filteredReservations[
                                                          index]['id']!);

                                              //send notification to user that his appointment is deleted
                                              DateTime now = DateTime.now();
                                              int hour = now.hour;
                                              String currentTime;
                                              if (hour < 12) {
                                                currentTime =
                                                    "$hour:${now.minute} AM";
                                              } else {
                                                currentTime =
                                                    "${hour - 12}:${now.minute} PM";
                                              }
                                              print(
                                                  "useremail: ${filteredReservations[index]['emailuser']}");
                                              // print("usertoken: ${filteredReservations[index]['token']}");
                                              var data = {
                                                "useremail": filteredReservations[
                                                        index][
                                                    'emailuser'], // Name of user
                                                "content":
                                                    "Your appointment with ${nameUser} is at ${filteredReservations[index]['date']} ${filteredReservations[index]['time']}",
                                                "title": "Delete Appointment",
                                                "date": currentTime, //
                                                "read": false,
                                                "onTime": true,
                                                "dateTime": now //
                                              };
                                              // add data to firebase database
                                              FirebaseFirestore.instance
                                                  .collection('notifications')
                                                  .add(data)
                                                  .then((DocumentReference
                                                      document) {
                                                print(
                                                    'Notification added with ID: ${document.id}');
                                              }).catchError((error) {
                                                print(
                                                    'Error adding notification: $error');
                                              });
                                              // delete notification for this user
                                              String dateString =
                                                  filteredReservations[index]
                                                      ['date']!;
                                              DateTime date =
                                                  DateTime.parse(dateString);
                                              List<String> daysOfWeek = [
                                                "Monday",
                                                "Tuesday",
                                                "Wednesday",
                                                "Thursday",
                                                "Friday",
                                                "Saturday",
                                                "Sunday"
                                              ];
                                              // Get the day of the week
                                              String selectday =
                                                  daysOfWeek[date.weekday - 1];

                                              print(
                                                  "The day of the week for $dateString is $selectday");
                                              print(
                                                  "Your appointment with ${nameUser} is on ${selectday} at ${filteredReservations[index]['date']} ${filteredReservations[index]['time']}");
                                              print(
                                                  "Reminder you have an appointment after a few minutes");
                                              FirebaseFirestore.instance
                                                  .collection('notifications')
                                                  .where('content',
                                                      isEqualTo:
                                                          "Your appointment with ${nameUser} is on ${selectday} at ${filteredReservations[index]['date']} ${filteredReservations[index]['time']}")
                                                  .where('title',
                                                      isEqualTo:
                                                          "Reminder you have an appointment after a few minutes")
                                                  .where('useremail',
                                                      isEqualTo:
                                                          filteredReservations[
                                                                  index]
                                                              ['emailuser'])
                                                  .where('onTime',
                                                      isEqualTo: false)
                                                  .get()
                                                  .then((QuerySnapshot
                                                      querySnapshot) {
                                                querySnapshot.docs
                                                    .forEach((doc) {
                                                  doc.reference
                                                      .delete()
                                                      .then((_) {
                                                    print(
                                                        'Document successfully deleted');
                                                  }).catchError((error) {
                                                    print(
                                                        'Error deleting document: $error');
                                                  });
                                                });
                                              }).catchError((error) {
                                                print(
                                                    'Error getting documents: $error');
                                              });

                                              // send data as notification to user
                                              print("send notification number");
                                              var serverToken =
                                                  "AAAAjxD3gc0:APA91bHJ7Wk4v_wxhhTe93vwHi78rfrZf7VOxWNp6BY7Z-bDOb8fA3Z-jfLpNPpHXqnJu8SO7KYGf06zUWpvWMbi6J_4k7-mSQT1QVbH59bOFhw8IVudg6vs-vZZpM485SyJMd7KrGeZ";
                                              await http.post(
                                                Uri.parse(
                                                    'https://fcm.googleapis.com/fcm/send'),
                                                headers: <String, String>{
                                                  'Content-Type':
                                                      'application/json',
                                                  'Authorization':
                                                      'key=$serverToken',
                                                },
                                                body: jsonEncode(
                                                  <String, dynamic>{
                                                    'notification':
                                                        <String, dynamic>{
                                                      'body':
                                                          "Your appointment with ${nameUser} is at ${filteredReservations[index]['date']} ${filteredReservations[index]['time']}",
                                                      'title':
                                                          "Delete Appointment",
                                                    },
                                                    'priority': 'high',
                                                    'data': <String, dynamic>{
                                                      'click_action':
                                                          'FLUTTER_NOTIFICATION_CLICK',
                                                      'status': 'done',
                                                      'body':
                                                          "Your appointment with ${nameUser} is at ${filteredReservations[index]['date']} ${filteredReservations[index]['time']}",
                                                      'title':
                                                          'Delete Appointment'
                                                    },
                                                    'to': filteredReservations[
                                                        index]['usertoken'],
                                                  },
                                                ),
                                              );
                                              //delete from list
                                              setState(() {
                                                print('isDelete? ${ress.body}');
                                                List<Map<String, String>>
                                                    copyFilteredReservations =
                                                    List.from(
                                                        filteredReservations);
                                                reservations.remove(
                                                    filteredReservations[
                                                        index]);
                                                copyFilteredReservations
                                                    .removeAt(index);
                                                filteredReservations =
                                                    copyFilteredReservations;
                                              });
                                            },
                                            btnCancelColor:
                                                Color.fromARGB(255, 32, 87, 97),
                                            btnOkColor: Color.fromARGB(
                                                255, 56, 154, 171),
                                            descTextStyle: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 32, 87, 97)),
                                          )..show();
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    print(
                                        "${filteredReservations[index]['name']} Navigate to patient page when name is tapped");

                                    final res = await Api.getuserbyid(
                                        filteredReservations[index]['userid']!);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProfileUser(
                                                  userinfo: res.body,
                                                  visit: true,
                                                )));
                                  },
                                ),
                              ),
                            );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // If selectedDate is null, set it to the current date
    if (selectedDate == null) {
      selectedDate = DateTime.now();
    }
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
      firstDate: DateTime(2022),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

      setState(() {
        selectedDate = pickedDate;
        filteredReservations = reservations
            .where((reservation) =>
                reservation['date'] == formattedDate ||
                reservation['date']!.isEmpty)
            .toList();
        // Sort the filtered reservations based on date and time
        filteredReservations.sort((a, b) {
          // Custom parsing function for the date and time format
          DateTime dateTimeA = parseDateTime(a['date']!, a['time']!);
          DateTime dateTimeB = parseDateTime(b['date']!, b['time']!);

          // Compare reservations based on date and time
          return dateTimeA.compareTo(dateTimeB);
        });
      });
    }
  }

  void filterReservationsByDate() {
    setState(() {
      filteredReservations = reservations
          .where((reservation) =>
              reservation['date'] == formattedDate(selectedDate!) ||
              reservation['date']!.isEmpty)
          .toList();

      // Sort the filtered reservations based on date and time
      filteredReservations.sort((a, b) {
        // Custom parsing function for the date and time format
        DateTime dateTimeA = parseDateTime(a['date']!, a['time']!);
        DateTime dateTimeB = parseDateTime(b['date']!, b['time']!);

        // Compare reservations based on date and time
        return dateTimeA.compareTo(dateTimeB);
      });

      // Print the sorted list for debugging
      print('Sorted Reservations: $filteredReservations');
    });
  }

// Custom function to parse date and time
  DateTime parseDateTime(String date, String time) {
    // Assuming date is in the format 'YYYY-MM-DD' and time is in the format 'hh:mm a'
    String dateTimeString = '$date $time';

    // Using intl package for parsing
    final dateTimeFormat = DateFormat('yyyy-MM-dd hh:mm a');
    return dateTimeFormat.parse(dateTimeString);
  }

  String formattedDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
