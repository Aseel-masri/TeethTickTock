import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:untitled/servicies/api.dart';

class NotificationItem {
  final String title;
  final String content;
  final String date;
  final bool read;
  final DateTime timetosend;

  NotificationItem(
      {required this.title,
      required this.content,
      required this.date,
      required this.read,
      required this.timetosend});
}

List<NotificationItem> notifications = [
/*   NotificationItem(
    title: 'You have an appointment',
    content:
        'Reminder: Your appointment with Dr. Musab is on Wednesday at 3:00 PM',
    date: "DateTime.now()",
    read: false,
  ),
  NotificationItem(
    title: 'You have an appointment',
    content: 'Reminder: Meeting at 2 PM.',
    date: "DateTime.now()",
    read: false,
  ), */
];

class Notifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  late String emailUser;
  Future<void> reading() async {
    Map<String, dynamic>? userData = getUserData();

    if (userData != null) {
      emailUser = userData['email'];
      print('Email: ${userData['email']}');
    } else {
      print('User data not found.');
    }
    await Api.markAllNotificationsAsRead(emailUser);
    //  markAsReadSubscription.cancel();
  }

  void showNotificationList(BuildContext context) {
    // Color customColor = const Color(0xFFBBF1FA);
    Color mainColor = const Color(0xFF389AAB);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 27),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.notifications,
                  color: mainColor,
                  size: 30,
                )
              ],
            ),
          ),
          content: notifications.isEmpty
              ? Center(
                  child: Text(
                    'There are no notifications.',
                    style: TextStyle(color: mainColor),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: notifications.reversed.map((notification) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Container(
                          color: !notification.read
                              ? Color.fromARGB(53, 158, 158, 158)
                              : Colors.white,
                          child: ListTile(
                            title: Text(
                              notification.title,
                              style: TextStyle(color: mainColor),
                            ),
                            subtitle: Text(
                              notification.content,
                            ),
                            trailing: Text(
                              '${notification.date}',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () {
                reading();
                Navigator.of(context).pop();
              },
              child: Text(
                'Close ',
                style: TextStyle(color: mainColor),
              ),
            ),
          ],
        );
      },
    );
  }

  final LocalStorage storage = new LocalStorage('my_data');

  Map<String, dynamic>? getUserData() {
    // Get the existing data from LocalStorage
    Map<String, dynamic>? existingData = storage.getItem('user_data_new');

    return existingData;
  }
}
