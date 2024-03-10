import 'dart:collection';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:untitled/Profile/usertodoctor.dart';
import 'package:untitled/maps/doctorslocation.dart';
import 'package:untitled/model/doctor.dart';
import 'package:untitled/servicies/api.dart';

class Specialty extends StatefulWidget {
  @override
  _SpecialtyState createState() => _SpecialtyState();
}

class _SpecialtyState extends State<Specialty> {
  String specialtyTitle = '';
  String specialtyImage = 'images/doctors3.jpg';
  String specialtyid = '6543e16a3336dafe8f42c254';
  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);
  TextEditingController _searchController = TextEditingController();

  List doctors = [
    // {
    //   "id": "1",
    //   "name": "Dr Mira",
    //   "specialty": "Dental neurologist", //اعصاب
    //   "City": "Nablus",
    //   "image": "",
    //   "rate": 3
    // },
    // {
    //   "id": "1",
    //   "name": "Dr Mira",
    //   "specialty": "Dental neurologist", //اعصاب
    //   "City": "Nablus",
    //   "image": "",
    //   "rate": 4
    // },
    // {
    //   "id": "1",
    //   "name": "Dr Mira",
    //   "specialty": "Dental neurologist", //اعصاب
    //   "City": "Nablus",
    //   "image": "",
    //   "rate": 5
    // },
    // {
    //   "id": "1",
    //   "name": "Dr Mira",
    //   "specialty": "Dental neurologist", //اعصاب
    //   "City": "Nablus",
    //   "image": "",
    //   "rate": 3
    // },
    // {
    //   "id": "1",
    //   "name": "Dr Mira",
    //   "specialty": "Dental neurologist", //اعصاب
    //   "City": "Nablus",
    //   "image": "",
    //   "rate": 1
    // },
    // {
    //   "id": "1",
    //   "name": "Dr Deema",
    //   "specialty": "Cosmetic dentist", //تجميل
    //   "City": "Nablus",
    //   "image": "",
    //   "rate": 5
    // },
    // {
    //   "id": "1",
    //   "name": "Dr Aseel",
    //   "specialty": "Pediatric dentist", //اطفال
    //   "City": "Nablus",
    //   "image": "",
    //   "rate": 2
    // },
    // {
    //   "id": "1",
    //   "name": "Dr Aseel",
    //   "specialty": "Pediatric dentist", //اطفال
    //   "City": "Nablus",
    //   "image": "",
    //   "rate": 1
    // },
    // {
    //   "id": "1",
    //   "name": "Dr Aseel",
    //   "specialty": "Dental neurologist", //اطفال
    //   "City": "Nablus",
    //   "image": "",
    //   "rate": 2
    // },
    // {
    //   "id": "1",
    //   "name": "Dr Mira",
    //   "specialty": "Dental neurologist", //اطفال
    //   "City": "Ramallah",
    //   "image": "",
    //   "rate": 1
    // },
    // {
    //   "id": "1",
    //   "name": "Dr Mira",
    //   "specialty": "Dental Surgeon", //اطفال
    //   "City": "Nablus",
    //   "image": "",
    //   "rate": 2
    // },
    // {
    //   "id": "1",
    //   "name": "Dr razan",
    //   "specialty": "Orthodontist", //اطفال
    //   "City": "Nablus",
    //   "image": "",
    //   "rate": 2
    // },
  ];
  List filteredDoctors = [];
  String? selectedCity = null; // Initialize with an empty string

  @override
  void initState() {
    super.initState();
    getinfo();
    // Access the arguments here
    // Initialize user data with default values
    print("Initializing specialty");
    setState(() {
      filteredDoctors = List.from(doctors);
    });

    // Initialize filteredDoctors with all doctors when the page is loaded
  }

  String nameUser = 'user';
  String emailUser = 'user@gmail.com';
  String userID = '1';
  String userImage = '';

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
        userImage = userData['profileImg'];
      });
      print('User data loaded: name=$nameUser, email=$emailUser, id=$userID');
      print('Name: ${userData['name']}');
      print('Email: ${userData['email']}');
      print('ID: ${userData['id']}');
    } else {
      print('User data not found.');
    }
    /*    setState(() {
      final localStorage = LocalStorage('user_data_new');
      final userData = localStorage.getItem('user_data_new');
      print("user data : $userData");
      if (userData != null) {
        print("load user data func ------- $userData");
        // setState(() {
        //   nameUser = userData['name'];
        //   emailUser = userData['email'];
        // });
        nameUser = userData['name'];
        emailUser = userData['email'];
        userID = userData['id'];
        print('User data loaded: name=$nameUser, email=$emailUser, id=$userID');
      } else {
        // nameUser = name;
        print("user data null /load user data func  -------");
      }
    }); */
  }

  List<Doctor> doctorinfo = [];
  void getinfo() async {
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
          profileImg:"http://10.0.2.2:8081/profileimg/" + parsedJson2['ProfileImg'],
          category: category,
        );

        doctors2.add(doctor);
      }

      // Now, the 'doctors' list contains all doctor objects
      doctorinfo = doctors2;
      for (Doctor doctor in doctors2) {
        print("Doctor Name: ${doctor.name}");
        Map<String, dynamic> doctorMap = {
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

    // You can perform any further processing or setState as needed
  }

  // void filterDoctors(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       // If the query is empty, display all doctors
  //       filteredDoctors = List.from(doctors);
  //     } else {
  //       // Filter doctors based on the query
  //       filteredDoctors = doctors.where((doctor) {
  //         final name = doctor['name'].toLowerCase();
  //         return name.contains(query.toLowerCase());
  //       }).toList();
  //     }
  //   });
  // }

  void filterDoctorsByCity(String? city) {
    setState(() {
      selectedCity = city;
      if (city == null || city == "All") {
        // If no city is selected, display all doctors
        filteredDoctors = List.from(doctors);
      } else {
        // Filter doctors based on the selected city
        filteredDoctors = doctors.where((doctor) {
          return doctor['City'] == city;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    specialtyTitle = args['specialtyTitle'] ?? '';
    specialtyid = args['id'] ?? '';
    specialtyImage = args['image'] ?? 'images/doctors3.jpg';
    print(
        'INFOOOOOOOOOOOOOOO---> $specialtyImage  $specialtyid  $specialtyTitle');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          iconTheme: IconThemeData(color: customColor),
          centerTitle: true,
          backgroundColor: mainColor,
          title: Center(
              child: Text(
            '$specialtyTitle',
            style: TextStyle(fontSize: 25, color: customColor),
          )),
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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 175.0,
            decoration: BoxDecoration(
              color: mainColor,
              image: DecorationImage(
                  image: AssetImage('images/$specialtyImage'),
                  fit: BoxFit.cover,
                  opacity: 0.7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 20),
            child: Column(
              children: [
                Text(
                  textAlign: TextAlign.left,
                  "Doctors",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: mainColor,
                        offset: Offset(
                            MediaQuery.of(context).size.width * 0.002, //0.1
                            MediaQuery.of(context).size.width * 0.002), //0.1
                      ),
                    ],
                  ),
                ),
                Text(
                  "$specialtyTitle",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF389AAB)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Clinic locations ',
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                      Icon(
                        Icons.location_on,
                        size: 22,
                        color: Colors.white,
                      )
                    ],
                  ),
                  onPressed: () async {
                    Map<String, dynamic> res =
                        await Api.getlocationsbycategory(specialtyid);
                    print("LOCATIONS $res");
                    if (res['message'] == "Doctor not found") {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.noHeader,
                        animType: AnimType.BOTTOMSLIDE,
                        title: 'No Clinics',
                        desc: 'There is no clinics in this category',
                        btnOkOnPress: () {},
                        btnOkText: 'Okay',
                        btnOkColor: Color.fromARGB(193, 56, 154, 171),
                      )..show();
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Doc_locations(
                                    doctor_category: res['doctorDetails'],
                                  )));
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Sorted by City:",
                style: TextStyle(
                    fontSize: 18,
                    color: mainColor,
                    fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                // disabledHint: Text("doctor City"),
                hint: Text("All"),
                // dropdownColor: mainColor,
                iconEnabledColor: mainColor,
                iconSize: 30,
                iconDisabledColor: mainColor,
                value: selectedCity,
                items: [
                  DropdownMenuItem<String>(
                    value: "All",
                    child: Text("All"),
                  ),
                  ...doctors
                      .map((doctor) => doctor['City'])
                      .toSet()
                      .map((city) => DropdownMenuItem<String>(
                            value: city,
                            child: Text(
                              city,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          )),
                ],
                onChanged: (city) {
                  setState(() {
                    filterDoctorsByCity(city!);
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                // hintStyle: TextStyle(color: mainColor),
                labelStyle: TextStyle(color: mainColor),
                labelText: "Search",
                hintText: 'name of doctor ..',
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: mainColor,
                ),
              ),
              onChanged: (query) {
                setState(() {
                  // filterDoctors(query);
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              // color: Colors.grey[200],
              child: ListView.builder(
                // shrinkWrap: true,
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  bool matchesSpecialty =
                      filteredDoctors[index]['specialty'] == specialtyTitle;
                  bool matchesSearch = _searchController.text.isEmpty ||
                      filteredDoctors[index]['name']
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase());

                  if (matchesSpecialty && matchesSearch) {
                    return InkWell(
                        onTap: () async {
                          print('Tapped Doctor Information:');
                          print('Name: ${filteredDoctors[index]['name']}');
                          print(
                              'Specialty: ${filteredDoctors[index]['specialty']}');
                          print('City: ${filteredDoctors[index]['City']}');
                          print('Rate: ${filteredDoctors[index]['rate']}');
                          print("test");
                          try {
                            final response = await Api.getdoctor(
                                filteredDoctors[index]['id'] ?? '');
                            String responseBody = response.body;
                            if (responseBody.contains("doctor")) {
                              responseBody =
                                  responseBody.replaceAll("doctor", "user");
                            }
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return UserProfiledoc(
                                doctorinfo: responseBody,
                                userid: userID,
                              );
                            }));
                          } catch (error) {
                            print("Error in API call: $error");
                            // Handle the error, e.g., show a message to the user
                          }
                        },
                        splashColor: customColor,
                        child: Container(
                          // color: Colors.white,

                          padding:
                              const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                          child: ListTile(
                            tileColor: Colors.grey[200],
                            // tileColor: Colors.white,
                            hoverColor: customColor,
                            contentPadding: EdgeInsets.only(
                                bottom: 10.0, top: 10.0, right: 10.0),
                            leading: Container(
                              width: 80, // Adjust the width as needed
                              height: 80, // Adjust the height as needed
                              child: filteredDoctors[index]['image'] == ""
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
                                          filteredDoctors[index]['image']),
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
                            title: Text(
                              filteredDoctors[index]['name'],
                              style: TextStyle(fontSize: 18.0),
                            ),
                            subtitle: Text(
                              filteredDoctors[index]['City'],
                              style: TextStyle(fontSize: 16.0),
                            ),
                            trailing: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (starIndex) => Icon(
                                  Icons.star,
                                  color:
                                      starIndex < filteredDoctors[index]['rate']
                                          ? Colors.yellow
                                          : null,
                                ),
                              ),
                            ),
                          ),
                        ));
                  }
                  return SizedBox
                      .shrink(); // Return an empty widget if not a match
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
