import 'package:flutter/material.dart';
import 'package:untitled/model/Admin.dart';
import 'dart:collection';
import 'dart:convert';
import 'package:untitled/model/doctor.dart';
import 'package:untitled/servicies/api.dart';
import 'package:untitled/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// final _firestore = FirebaseFirestore.instance;
late User signedInUser;

class MessagesUserList extends StatefulWidget {
  const MessagesUserList({Key? key}) : super(key: key);

  @override
  State<MessagesUserList> createState() => _MessagesUserListState();
}

Color customColor2 = Color.fromARGB(255, 216, 243, 248);
Color customColor = const Color(0xFFBBF1FA);
Color mainColor = const Color(0xFF389AAB);
bool isDoctor = false;

class _MessagesUserListState extends State<MessagesUserList> {
  List doctors = [];
  List filteredDoctors = [];

  TextEditingController searchController = TextEditingController();
  /***************fireBase *********/
  final _auth = FirebaseAuth.instance;
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        print(signedInUser.email); //email for the current user
      }
    } catch (e) {
      print("from chat :- ${e}");
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   getCurrentUser();
  //   // Retrieve the isDoctor value from the arguments
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   setState(() {
  //     isDoctor = ModalRoute.of(context)!.settings.arguments as bool;
  //   });
  //   getinfo();
  //   filteredDoctors = List.from(doctors);
  // }
  @override
  void initState() {
    super.initState();

    // Use Future.delayed to schedule an asynchronous operation
    Future.delayed(Duration.zero, () {
      // Retrieve the isDoctor value from the arguments
      bool? isDoctorArg = ModalRoute.of(context)!.settings.arguments as bool?;

      if (isDoctorArg != null) {
        setState(() {
          isDoctor = isDoctorArg;
        });
      }

      getCurrentUser();
      getinfo();
      filteredDoctors = List.from(doctors);
    });
  }

  void filterUsers(String query) {
    setState(() {
      filteredDoctors = doctors
          .where((doctors) =>
              doctors['name'].toLowerCase().contains(query.toLowerCase()) ||
              doctors['email']
                  .toLowerCase()
                  .contains(query.toLowerCase())) //email
          .toList();
    });
  }

/////////////////////////////////////////////////////////////////////////////////////////
  List<Doctor> doctorinfo = [];
  List<Userr> userinfo = [];
  List<Admin> admininfo = [];
  void getinfo() async {
    if (isDoctor == false) {
      final response = await Api.getdoctors();
      Map<String, dynamic> parsedJson = json.decode(response.body);
      if (parsedJson.containsKey("doctor") && parsedJson["doctor"] is List) {
        List<dynamic> parsedJsonList = parsedJson["doctor"];
        List<Doctor> doctors2 = [];
        for (var parsedJson2 in parsedJsonList) {
          String temp = parsedJson2['category'];
          String category = await Api.getcategory(temp ?? '');
          Doctor doctor = Doctor(
            id: parsedJson2['_id'],
            name: parsedJson2['name'],
            email: parsedJson2['email'],
            password: parsedJson2['password'],
            phoneNumber: parsedJson2['phoneNumber'],
            city: parsedJson2['city'],
            workingDays: List<String>.from(parsedJson2['WorkingDays']),
            locationMap: List<double>.from(parsedJson2['locationMap']),
            rating: parsedJson2['Rating'] as int? ?? 0,
            startTime: parsedJson2['StartTime'],
            endTime: parsedJson2['EndTime'],
            profileImg:
                "http://10.0.2.2:8081/profileimg/" + parsedJson2['ProfileImg'],
            category: category,
          );

          doctors2.add(doctor);
        }

        // Now, the 'doctors' list contains all doctor objects
        doctorinfo = doctors2;
        for (Doctor doctor in doctors2) {
          print("Doctor Name: ${doctor.name}");
          Map<String, dynamic> doctorMap = {
            "email": doctor.email,
            "id": doctor.id,
            "name": doctor.name,
            "specialty": doctor
                .category, // Assuming 'category' in 'Doctor' corresponds to 'specialty' in your target list
            "City": doctor.city,
            "image": doctor.profileImg,
            "rate": doctor.rating,
          };
          doctors.add(doctorMap);
        }
        for (var doctor in doctors) {
          print("Doctorss Name: ${doctor['name']}");
        }
        setState(() {
          filteredDoctors = List.from(doctors);
          // loadUserData();
        });
      }
    } else {
      final response = await Api.getUsers();
      dynamic parsedJson = json.decode(response.body);
      final responseAdmin = await Api.getAdmins();
      dynamic parsedJsonAdmin = json.decode(responseAdmin.body);

      if (parsedJson is List) {
        List<Userr> usersList = [];

        for (var parsedJson2 in parsedJson) {
          // Process each user in the list
          Userr user = Userr(
            id: parsedJson2['_id'],
            name: parsedJson2['name'],
            email: parsedJson2['email'],
            password: parsedJson2['password'],
            phoneNumber: parsedJson2['phoneNumber'],
            city: parsedJson2['city'],
            profileImg:
                "http://10.0.2.2:8081/profileimg/" + parsedJson2['ProfileImg'],
          );

          usersList.add(user);
        }

        // Now, the 'usersList' contains all user objects
        userinfo = usersList;

        for (Userr user in usersList) {
          print("user Name: ${user.name}");
          Map<String, dynamic> userMap = {
            "email": user.email,
            "id": user.id,
            "name": user.name,
            "City": user.city,
            "image": user.profileImg,
          };
          doctors.add(userMap);
        }

        setState(() {
          // filteredDoctors = List.from(doctors);
        });
      } else {
        // Handle the case where the response is not a list (Map, error, etc.)
        print("Unexpected response format: $parsedJson");
      }

      ///////////////////////////////////////get admins////////////////////////////////

      if (parsedJsonAdmin is List) {
        List<Admin> adminList = [];
        for (var parsedJson2Admin in parsedJsonAdmin) {
          // Process each user in the list
          Admin admin = Admin(
            id: parsedJson2Admin['_id'],
            name: parsedJson2Admin['name'],
            email: parsedJson2Admin['email'],
            password: parsedJson2Admin['password'],
            image: parsedJson2Admin['image'],
          );
          adminList.add(admin);
        }
        // Now, the 'usersList' contains all user objects
        admininfo = adminList;
        for (Admin admin in adminList) {
          print("admin Name: ${admin.email}");
          Map<String, dynamic> adminMap = {
            "email": admin.email,
            "id": admin.id,
            "name": admin.name,
            "image": admin.image,
          };
          doctors.add(adminMap);
        }
        setState(() {
          filteredDoctors.addAll(doctors);
        });
      }
    }
  }

  // You can perform any further processing or setState as needed

//////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: customColor),
        backgroundColor: mainColor,
        title: Row(
          children: [
            Image.asset(
              "images/messages.png",
              width: 35,
              color: customColor,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Messages",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          // Add a TextField for searching users
        ],
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: mainColor,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 10, bottom: 20),
                        height: 60,
                        child: TextField(
                          onChanged: (value) {
                            filterUsers(value);
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            hintText: 'Search by name ...',
                            hintStyle: TextStyle(color: mainColor),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.search,
                        color: mainColor,
                        size: 35,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          color: const Color.fromARGB(255, 241, 240, 240),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "Messages",
                                  arguments: {
                                    "email": filteredDoctors[index]['email'],
                                    "name": filteredDoctors[index]['name'],
                                    "image": filteredDoctors[index]['image']
                                  });
                              print("${filteredDoctors[index]['email']}");
                            },
                            child: ListTile(
                              title: Text("${filteredDoctors[index]['name']}"),
                              subtitle: isDoctor
                                  ? Text("${filteredDoctors[index]['email']}")
                                  : Text(
                                      "${filteredDoctors[index]['specialty']}"),
                              // Add other user details as needed
                              leading: filteredDoctors[index]['image'] == ""
                                  ? CircleAvatar(
                                      backgroundColor: customColor,
                                      backgroundImage:
                                          AssetImage("images/logo2.png"),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                mainColor, // Specify the border color here
                                            width:
                                                2.0, // Specify the border width here
                                          ),
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: customColor,
                                      backgroundImage: NetworkImage(
                                          "${filteredDoctors[index]['image']}"),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                mainColor, // Specify the border color here
                                            width:
                                                2.0, // Specify the border width here
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Divider(
                          // Add a Divider after each ListTile
                          color: mainColor, // You can customize the color
                          thickness: 0.1, // You can customize the thickness
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
