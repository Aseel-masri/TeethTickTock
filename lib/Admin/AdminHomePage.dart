import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled/Profile/doctorprofile.dart';
import 'package:untitled/Profile/userprofile.dart';
import 'package:untitled/servicies/api.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);
  // Function to load user data from local storage
  String nameUser = 'user';
  String emailUser = 'user@gmail.com';
  String userID = '1';
  final LocalStorage storage = new LocalStorage('my_data');

  Map<String, dynamic>? getUserData() {
    // Get the existing data from LocalStorage
    Map<String, dynamic>? existingData = storage.getItem('user_data_new');

    return existingData;
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
      });
      print('User data loaded: name=$nameUser, email=$emailUser, id=$userID');
      print('Name: ${userData['name']}');
      print('Email: ${userData['email']}');
      print('ID: ${userData['id']}');
    } else {
      print('User data not found.');
    }
  }

  List<Map<String, String>> requests = [
    {"name": "Doctor 1", "date": "Category 1"},
    {"name": "Doctor 2", "date": "Category 2"},
    {"name": "Doctor 4", "date": "Category 3"},
    {"name": "Doctor 5", "date": "Category 1"},
    {"name": "Doctor 6", "date": "Category 2"},
    {"name": "Doctor 7", "date": "Category 3"},
    {"name": "Doctor 4", "date": "Category 4"},
    {"name": "Doctor 5", "date": "Category 5"},
    {"name": "Doctor 6", "date": "Category 6"},
    {"name": "Doctor 7", "date": "Category 7"},
    {"name": "Doctor 1", "date": "Category 1"},
    {"name": "Doctor 2", "date": "Category 2"},
    {"name": "Doctor 4", "date": "Category 3"},
    {"name": "Doctor 5", "date": "Category 1"},
    {"name": "Doctor 6", "date": "Category 2"},
    {"name": "Doctor 7", "date": "Category 3"},
    {"name": "Doctor 4", "date": "Category 4"},
    {"name": "Doctor 5", "date": "Category 5"},
    {"name": "Doctor 6", "date": "Category 6"},
    {"name": "Doctor 7", "date": "Category 7"},
    // Add more reservations as needed
  ];
  List<Map<String, String>> filteredReservations = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      filteredReservations = requests;
    });
  }
void filterDoctors(String query) {
  /*   setState(() {
      if (query.isEmpty) {
        // If the query is empty, display all doctors
        filteredReservations = List.from(requests);
      } else {
        // Filter doctors based on the query
        filteredReservations = requests.where((doctor) {
         final name = doctor['name']?.toLowerCase();
          return name?.contains(query.toLowerCase());
        }).toList();
      }
    }); */
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 40,
              ),
            ),
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
              currentAccountPicture: CircleAvatar(
                backgroundColor: customColor,
                child: Text(
                  nameUser.isNotEmpty ? nameUser[0] : 'U',
                  style: TextStyle(fontSize: 30, color: mainColor),
                ),
              ),
              decoration: BoxDecoration(
                color: mainColor,
              ),
            ),
            ListTile(
              iconColor: mainColor,
              textColor: mainColor,
              title: Text(
                "Doctor's Requests",
                style: TextStyle(fontSize: 18),
              ),
              leading: Icon(
                Icons.home,
                size: 35,
              ),
              onTap: () async {},
            ),
            Divider(),
            ListTile(
              iconColor: mainColor,
              textColor: mainColor,
              title: Text(
                "Categories",
                style: TextStyle(fontSize: 18),
              ),
              leading: Icon(
                Icons.message,
                size: 35,
              ),
              onTap: () {
                Navigator.pushNamed(context, "Messages");
              },
            ),
            Divider(),
            ListTile(
              iconColor: mainColor,
              textColor: mainColor,
              title: Text(
                "Doctors",
                style: TextStyle(fontSize: 18),
              ),
              leading: Icon(
                Icons.message,
                size: 35,
              ),
              onTap: () {
                Navigator.pushNamed(context, "Messages");
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
              onTap: () {
                Navigator.pushReplacementNamed(context, "LogIn");
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 30),
              child: Center(
                child: Text(
                  "Doctor's Requests",
                  style: GoogleFonts.lora(
                    textStyle: TextStyle(
                      fontSize: 30,
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: mainColor,
                  ),
                ),
                onChanged: (query) {
                   filterDoctors(query);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ListView.builder(
                  itemCount: filteredReservations.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        onTap: () async {
                          print(
                              "${filteredReservations[index]['name']} Navigate to patient page when name is tapped");
                          // Add your navigation logic here
                        },
                        title: Text(
                          filteredReservations[index]['name']!,
                          style: GoogleFonts.lora(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                        subtitle: Text(
                          filteredReservations[index]['date']!,
                          style: GoogleFonts.lora(
                            fontSize: 13,
                            // fontWeight: FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.done_outlined,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.question,
                                  animType: AnimType.scale,
                                  title: 'Add Doctor',
                                  desc:
                                      'Are you sure you want to add this doctor?',
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () async {},
                                  btnCancelColor:
                                      Color.fromARGB(255, 32, 87, 97),
                                  btnOkColor: Color.fromARGB(255, 56, 154, 171),
                                  descTextStyle: TextStyle(
                                    color: Color.fromARGB(255, 32, 87, 97),
                                  ),
                                )..show();
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.question,
                                  animType: AnimType.scale,
                                  title: 'Delete Doctor',
                                  desc:
                                      'Are you sure you want to delete this doctor?',
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () async {},
                                  btnCancelColor:
                                      Color.fromARGB(255, 32, 87, 97),
                                  btnOkColor: Color.fromARGB(255, 56, 154, 171),
                                  descTextStyle: TextStyle(
                                    color: Color.fromARGB(255, 32, 87, 97),
                                  ),
                                )..show();
                              },
                            ),
                          ],
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
}
