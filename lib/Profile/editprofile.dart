import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:untitled/MessagesUserList.dart';
import 'package:untitled/model/doctor.dart';
import 'doctorprofile.dart';
import 'package:untitled/servicies/api.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:untitled/main.dart';

class EditProfile extends StatefulWidget {
  final String id;

  EditProfile({required this.id});
  @override
  _EditProfileState createState() => _EditProfileState(id: id);
}

class _EditProfileState extends State<EditProfile> {
  int _currentIndex = 0;
  int _selectedIndex = 0;
  final String id;
  _EditProfileState({required this.id});
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: customColor),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF389AAB),
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back), // Use the back icon or any other icon you want
          onPressed: () async {
            try {
              final response = await Api.getdoctor(id ?? '');
              String responseBody = response.body;
              /*  if (responseBody.contains("doctor")) {
                responseBody = responseBody.replaceAll("doctor", "user");
              } */
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return Profile(username: responseBody);
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
  TextEditingController locationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController appointmentTimeController = TextEditingController();
  List<String> workingDays = [];
  //selectedWorkingDays
  Doctor doctor = Doctor();
  void getinfo() async {
    final Response = await Api.getdoctor(id);
    Map<String, dynamic> parsedJson = json.decode(Response.body);
    String temp = parsedJson['doctor']['category'];
    String category = await Api.getcategory(temp ?? '');
    doctor.workingDays = List<String>.from(parsedJson['doctor']['WorkingDays']);
    setState(() {
      doctor.id = parsedJson['doctor']['_id'];
      nameController.text = parsedJson['doctor']['name'];
      //doctor.email = parsedJson['doctor']['email'];
      // doctor.password = parsedJson['doctor']['password'];
      phoneNumberController.text = parsedJson['doctor']['phoneNumber'];
      emailController.text = parsedJson['doctor']['city'];
      // doctor.locationMap = parsedJson['locationMap'];
      //  doctor.rating = parsedJson['doctor']['Rating'] as int? ?? 0;
      startTimeController.text = parsedJson['doctor']['StartTime'];
      endTimeController.text = parsedJson['doctor']['EndTime'];
      appointmentTimeController.text =
          parsedJson['doctor']['appointmentTime'].toString();
      //doctor.profileImg = parsedJson['doctor']['ProfileImg'];
      //doctor.category = category;
      /*    print('cat..');
      print(doctor.workingDays);
      print(doctor.category); */
    });
  }

  @override
  void initState() {
    super.initState();
    getinfo();
  }

  void editinfo() async {
    workingDays.clear();
    try {
      for (int i = 0; i < selectedWorkingDays.length; i++) {
        switch (i) {
          case 1:
            if (selectedWorkingDays[i] == true) workingDays.add('Sunday');
            break;
          case 2:
            if (selectedWorkingDays[i] == true) workingDays.add('Monday');
            break;
          case 3:
            if (selectedWorkingDays[i] == true) workingDays.add('Tuesday');
            break;
          case 4:
            if (selectedWorkingDays[i] == true) workingDays.add('Wednesday');
            break;
          case 5:
            if (selectedWorkingDays[i] == true) workingDays.add('Thursday');
            break;
          case 6:
            if (selectedWorkingDays[i] == true) workingDays.add('Friday');
            break;
          case 0:
            if (selectedWorkingDays[i] == true) workingDays.add('Saturday');
            break;
        }
      }

      var data = {
        "name": nameController.text,
        "password": passwordController.text,
        "phoneNumber": phoneNumberController.text,
        "city": emailController.text,
        "StartTime": startTimeController.text,
        "EndTime": endTimeController.text,
        "WorkingDays": workingDays,
        "appointmentTime": appointmentTimeController.text
      };
      final response = await Api.editinfo(data, id);

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

  TimeOfDay _timeOfDay = TimeOfDay(hour: 0, minute: 0);
  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      setState(() {
        _timeOfDay = value!;
        startTimeController.text = _timeOfDay.format(context);
      });
    });
  }

  void _showTimePicker2() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      setState(() {
        _timeOfDay = value!;
        endTimeController.text = _timeOfDay.format(context);
      });
    });
  }

  List<bool> selectedWorkingDays = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

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
                controller: appointmentTimeController,
                decoration: InputDecoration(
                  labelText: 'appointment Time',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 2, 88, 101)),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 2, 88, 101),
                  ),
                  helperText:
                      'Enter appointment time in minutes', // Add the hit text here
                  helperStyle: TextStyle(color: Colors.grey),
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
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          readOnly: true,
                          onTap: _showTimePicker,
                          controller: startTimeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Start Time',
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 2, 88, 101)),
                            prefixIcon: Icon(Icons.access_time,
                                color: Color.fromARGB(255, 2, 88, 101)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          readOnly: true,
                          onTap: _showTimePicker2,
                          controller: endTimeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'End Time',
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 2, 88, 101)),
                            prefixIcon: Icon(Icons.access_time,
                                color: Color.fromARGB(255, 2, 88, 101)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0), // Set the margin here
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey, // Specify your desired border color
                    width: 1.0, // Specify your desired border width
                  ),
                  borderRadius: BorderRadius.circular(
                      6.0), // Add border radius to the Container
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(Icons.work_history_outlined,
                              color: Color.fromARGB(255, 2, 88, 101)
                              // color: Colors.grey[600],
                              ),
                          Text('  Working Days:   ',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 2, 88, 101))),
                          for (int i = 0; i < 7; i++)
                            Row(
                              children: <Widget>[
                                Text([
                                  'Sat',
                                  'Sun',
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                ][i]),
                                Checkbox(
                                  activeColor: Color.fromARGB(255, 2, 88, 101),
                                  value: selectedWorkingDays[i],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedWorkingDays[i] = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
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
                child: const Text(
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
