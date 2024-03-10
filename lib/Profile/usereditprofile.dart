import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:untitled/Profile/userprofile.dart';
import 'package:untitled/model/doctor.dart';
import 'doctorprofile.dart';
import 'package:untitled/servicies/api.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:untitled/main.dart';

class EditUserProfile extends StatefulWidget {
  final String id;

  EditUserProfile({required this.id});
  @override
  _EditUserProfileState createState() => _EditUserProfileState(id: id);
}

class _EditUserProfileState extends State<EditUserProfile> {
  int _currentIndex = 0;
  int _selectedIndex = 0;
  final String id;
  _EditUserProfileState({required this.id});
  static const List<IconData> _icons = [
    Icons.message_outlined,
    Icons.notifications,
    Icons.logout,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        print("Messages");
      }
      if (index == 1) {
        print("Notifications");
      }
      if (index == 2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyApp()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color customColor = const Color(0xFFBBF1FA);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: customColor),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF389AAB),
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back), // Use the back icon or any other icon you want
          onPressed: () async {
            try {
              final response = await Api.getuserbyid(id ?? '');
              String responseBody = response.body;

              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ProfileUser(
                  userinfo: responseBody,
                  visit: false,
                );
              }));
            } catch (error) {
              print("Error in API call: $error");
              // Handle the error, e.g., show a message to the user
            }
          },
        ),
      ),
      body: EditProfileForm(id: id),
      // bottomNavigationBar: BottomAppBar(
      //   color: Color(0xFF389AAB),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: _icons
      //         .asMap()
      //         .entries
      //         .map(
      //           (entry) => IconButton(
      //             icon: Icon(
      //               entry.value,
      //               size: 32.0,
      //               color: _selectedIndex == entry.key
      //                   ? Colors.white
      //                   : Colors.white,
      //             ),
      //             onPressed: () {
      //               _onItemTapped(entry.key);
      //             },
      //           ),
      //         )
      //         .toList(),
      //   ),
      // ),
    );
  }
}

class EditProfileForm extends StatefulWidget {
  final String id;

  EditProfileForm({required this.id});
  //const EditProfileForm({Key? key}) : super(key: key);

  @override
  _EditProfileFormState createState() => _EditProfileFormState(id: id);
}

class _EditProfileFormState extends State<EditProfileForm> {
  final String id;
  _EditProfileFormState({required this.id});
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  Doctor user = Doctor();
  void getinfo() async {
    final Response = await Api.getuserbyid(id);
    Map<String, dynamic> parsedJson = json.decode(Response.body);
    setState(() {
      user.id = parsedJson['_id'];
      nameController.text = parsedJson['name'];
      phoneNumberController.text = parsedJson['phoneNumber'];
      cityController.text = parsedJson['city'];
      emailController.text = parsedJson['email'];
    });
  }

  @override
  void initState() {
    super.initState();
    getinfo();
  }

  void editinfo() async {
    try {
      var data = {
        "name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "phoneNumber": phoneNumberController.text,
        "city": cityController.text,
      };
      final response = await Api.edituserinfo(data, id);

      if (response.statusCode == 200) {
        // Successful login
        print('Login successful');
      } else {
        print('Login failed');
        print(response.body);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 20, top: 10),
              child: const Text(
                'Edit Profile Information',
                style: TextStyle(
                  color: Color(0xFF389AAB),
                  fontWeight: FontWeight.w500,
                  fontSize: 25,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'User Name',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 2, 88, 101)),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 2, 88, 101),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey), // Border color when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 2, 88, 101)), // Border color when focused
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color.fromRGBO(2, 88, 101, 1)),
                  prefixIcon:
                      Icon(Icons.email, color: Color.fromARGB(255, 2, 88, 101)),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: cityController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'City',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 2, 88, 101)),
                  prefixIcon: Icon(Icons.location_city,
                      color: Color.fromARGB(255, 2, 88, 101)),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 2, 88, 101)),
                  prefixIcon:
                      Icon(Icons.phone, color: Color.fromARGB(255, 2, 88, 101)),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 2, 88, 101)),
                  prefixIcon:
                      Icon(Icons.lock, color: Color.fromARGB(255, 2, 88, 101)),
                ),
              ),
            ),
            Container(
              height: 50,
              margin: const EdgeInsets.only(
                  top: 35, bottom: 15, left: 20, right: 20),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFF389AAB)),
                ),
                child: Text(
                  'Edit Information',
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
                onPressed: () {
                  editinfo();
                  //    String d = DateFormat('yyyy-MM-dd').format(today);
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.SUCCES,
                    animType: AnimType.BOTTOMSLIDE,
                    title: 'Success',
                    desc: 'The information has been edited successfully',
                    btnOkOnPress: () {},
                    btnOkText: 'Okay',
                    btnOkColor: Color.fromARGB(193, 56, 154, 171),
                  )..show();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
