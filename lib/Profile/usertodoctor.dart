import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the package
import 'package:untitled/maps/mapfromuser.dart';
import 'package:untitled/model/doctor.dart';
import 'package:untitled/servicies/api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled/main.dart';
import './editprofile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'appointment.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

pickImage(ImageSource source) async {
  final ImagePicker imgpic = ImagePicker();
  XFile? _file = await imgpic.pickImage(source: source);
  if (_file != null) {
    print("Pic selected Finalllyyy!");
    return await _file.readAsBytes();
  }
  print("Pic not selected!");
}

class UserProfiledoc extends StatefulWidget {
  final String doctorinfo;
  final String userid;

  UserProfiledoc({required this.doctorinfo, required this.userid});
  @override
  _ProfileState createState() => _ProfileState(doctorinfo: doctorinfo);
}

class _ProfileState extends State<UserProfiledoc> {
  final String doctorinfo;

  _ProfileState({required this.doctorinfo});
  Uint8List? _image;
  static bool? isaalowedd;
  bool showStars = true;
  late String today = '';
  late String userid = '';
  late bool isOpenNow = false;
  Doctor doctor = Doctor();
  int rating = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      doctorsList = [];
    });
    today = DateFormat('EEEE').format(DateTime.now());
    getinfo();
    getDoctorsByCat();
  }

  void checkopen(List<String> workingDays) {
    for (int i = 0; i < workingDays.length; i++) {
      if (workingDays[i] == today) {
        isOpenNow = true;
        break;
      }
    }
  }

  void updateStatusBasedOnWorkingDays(List<String> workingDays) {
    for (int i = 0; i < workingDays.length; i++) {
      String day = workingDays[i];
      switch (day) {
        case 'Sunday':
          statuses[1] = 'Open';
          break;
        case 'Monday':
          statuses[2] = 'Open';
          break;
        case 'Tuesday':
          statuses[3] = 'Open';
          break;
        case 'Wednesday':
          statuses[4] = 'Open';
          break;
        case 'Thursday':
          statuses[5] = 'Open';
          break;
        case 'Friday':
          statuses[6] = 'Open';
          break;
        case 'Saturday':
          statuses[0] = 'Open';
          break;
      }
    }
  }

  String doctorID = "";
  String categoryId = "";
  void getinfo() async {
    Map<String, dynamic> parsedJson = json.decode(doctorinfo);
    String temp = parsedJson['user']['category'];
    doctorID = parsedJson['user']['_id'];
    categoryId = temp;
    String category = await Api.getcategory(temp ?? '');

    print("$temp");
    print("miraaaa :$doctorID");

    setState(() {
      userid = widget.userid;
      doctor.id = parsedJson['user']['_id'];
      doctor.name = parsedJson['user']['name'];
      doctor.email = parsedJson['user']['email'];
      doctor.password = parsedJson['user']['password'];
      doctor.phoneNumber = parsedJson['user']['phoneNumber'];
      doctor.city = parsedJson['user']['city'];
      doctor.locationMap = parsedJson['locationMap'];
      doctor.rating = parsedJson['user']['Rating'] as int? ?? 0;
      doctor.startTime = parsedJson['user']['StartTime'];
      doctor.endTime = parsedJson['user']['EndTime'];
      doctor.workingDays = List<String>.from(parsedJson['user']['WorkingDays']);
      doctor.profileImg =
          "http://10.0.2.2:8081/profileimg/" + parsedJson['user']['ProfileImg'];
      doctor.category = category;

      checkopen(doctor.workingDays ?? []);
      updateStatusBasedOnWorkingDays(doctor.workingDays ?? []);
      print('cat..');
      print(doctor.category);
    });
  }

  List<Map<String, dynamic>> doctorsList = [];
/***************************************************************** */
  void getDoctorsByCat() async {
    try {
      final doctorsByCategoryResponse =
          await Api.getDoctorsByCategory(categoryId);

      if (doctorsByCategoryResponse.statusCode == 200) {
        final dynamic responseData =
            json.decode(doctorsByCategoryResponse.body);
        print(responseData);
        if (responseData is Map && responseData.containsKey('doctors')) {
          // Extracting specific fields for each doctor
          for (var doctorData in responseData['doctors']) {
            String category =
                await Api.getcategory(doctorData['category'] ?? '');
            Map<String, dynamic> doctorDetails = {
              'id': doctorData['_id'],
              'name': doctorData['name'],
              'email': doctorData['email'],
              'phoneNumber': doctorData['phoneNumber'],
              'city': doctorData['city'],
              'locationMap': doctorData['locationMap'],
              'Rating': doctorData['Rating'],
              'StartTime': doctorData['StartTime'],
              'EndTime': doctorData['EndTime'],
              'category': category,
              'WorkingDays': doctorData['WorkingDays'],
              'ProfileImg':
                  "http://10.0.2.2:8081/profileimg/" + doctorData['ProfileImg'],
              'token': doctorData['token'],
              'appointmentTime': doctorData['appointmentTime'],
            };
            if (doctorID != doctorData['_id']) {
              setState(() {
                doctorsList.add(doctorDetails);
                // doctorsList.add(doctorDetails);
                // doctorsList.add(doctorDetails);
                // doctorsList.add(doctorDetails);
                // doctorsList.add(doctorDetails);
              });
            }
          }

          print('Doctors List:');
          for (var doctorDetails in doctorsList) {
            print('doctooooorrrrrrrrsssssssss :----- $doctorDetails');
            print('\n');
            // Add more fields as needed
          }
        } else {
          print('Invalid response format');
        }
      } else {
        print(
            'Failed to retrieve doctors. Status code: ${doctorsByCategoryResponse.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

/****************************************** */

  Future<void> isaalowed() async {
    final response = await Api.isaalowed(widget.userid, doctor.id ?? '');
    print('RESSSPOS-->${response.statusCode}');

    if (response.statusCode == 200) {
      isaalowedd = true;
    } else {
      isaalowedd = false;
    }
  }

  Future<void> rating2() async {
    await isaalowed();
    if (isaalowedd ?? true) {
      print('is aalowedd $isaalowedd');
      showDialog(
        context: context,
        builder: (context) {
          int tempRating = rating;
          String comment = ''; // New variable to store the comment

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Center(
                  child: Text('Star Rating',
                      style: TextStyle(
                        color: Color(0xFF389AAB),
                        fontWeight: FontWeight.bold,
                      )),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < tempRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 35,
                          ),
                          onPressed: () {
                            setState(() {
                              tempRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          comment = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Add a comment (optional)',
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFF389AAB)),
                    ),
                    onPressed: () {
                      setState(() {
                        rating = tempRating;
                        Api.addrate(userid ?? '', doctor.id ?? '', rating,
                            comment); // Pass comment to your API function
                        print('rating= $rating');
                        print('comment= $comment');
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFF389AAB)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      print('is not aalowedd $isaalowedd');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.WARNING,
        animType: AnimType.BOTTOMSLIDE,
        title: 'WARNING!!',
        desc: 'You are not allowed to add a rating.',
        btnOkOnPress: () {},
        btnOkText: 'Okay',
        btnOkColor: Color.fromARGB(193, 56, 154, 171),
      )..show();
    }
  }

  void workingDays() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Center(
                child: Text(
                  'Working Days',
                  style: TextStyle(
                    color: Color(0xFF389AAB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  days.length, // Replace 'days' with your list of working days
                  (index) {
                    return Container(
                      height: 50, // Set an appropriate height
                      child: ListTile(
                        title: Text(
                          '${days[index].toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          statuses[
                              index], // Replace 'statuses' with your list of statuses
                          style: TextStyle(
                              color: statuses[index] == 'Open'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF389AAB)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void selectImage() async {
    final imgPicker = ImagePicker();
    final XFile? file = await imgPicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _image = File(file.path).readAsBytesSync();
      });
    }
  }

  List<String> days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];
  List<String> statuses = [
    'Colse',
    'Colse',
    'Colse',
    'Colse',
    'Colse',
    'Colse',
    'Colse'
  ];
  void onTapWorkinDay() {
    showDialog(
      context: context, // Make sure you have access to the 'context' variable
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Working days')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: days
                    .length, // Replace 'days' with your list of working days
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${days[index].toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          statuses[
                              index], // Replace 'statuses' with your list of statuses
                          style: TextStyle(
                            color: statuses[index] == 'Open'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold, // Fixed here
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> onTaplocation() async {
    final response = await Api.getdoctor(doctor.id ?? '');

    if (response.statusCode == 200) {
      // Successful login
      print(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => U_position(
                  doctorinf: response.body,
                )),
      );

      //myMarkerPosition=jsonEncode(response.body) as LatLng;
    } else {
      print('location failed');
      print(response.body);
    }
  }

  void onTapFacebook() {
    launch('https://www.facebook.com/JaberDent');
  }

  void onTapInstgram() {
    launch(
        'https://www.instagram.com/drmohamdsalman/?fbclid=IwAR2nNP08zZfOnHz6zfknqxn-5Bzgc2C8txbqjX61qbrTxOxMAxjdJa3mHNs');
  }

  int _selectedIndex = 0;

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

  Widget buildRatingStars(int rating) {
    List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      if (i <= rating) {
        stars.add(Icon(
          Icons.star,
          color: Colors.amber,
        ));
      } else {
        stars.add(Icon(
          Icons.star_border,
          color: Colors.amber,
        ));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: stars,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color customColor = const Color(0xFFBBF1FA);
    Color mainColor = const Color(0xFF389AAB);
    double screenWidth = MediaQuery.of(context).size.width;
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

                // Add your onTap action for the title image here
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
      body: SingleChildScrollView(
          // child: Container(
          //     padding: const EdgeInsets.only(left: 4, right: 4),
          //     color: //Color.fromARGB(242, 8, 5, 5),
          //         Colors.white,
          //     constraints: const BoxConstraints.expand(),
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 8,
          ),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 180,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                  image: DecorationImage(
                      image: NetworkImage(
                          'https://t3.ftcdn.net/jpg/04/12/82/16/360_F_412821610_95RpjzPXCE2LiWGVShIUCGJSktkJQh6P.jpg'),
                      fit: BoxFit.cover),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 80),
                child: _image != null
                    ? CircleAvatar(
                        radius: 73.0,
                        backgroundColor: Color.fromARGB(242, 8, 5, 5),
                        backgroundImage: MemoryImage(_image!),
                      )
                    : CircleAvatar(
                        radius: 73.0,
                        backgroundColor: Color.fromARGB(242, 8, 5, 5),
                        backgroundImage: NetworkImage(doctor.profileImg ??
                            'https://upload.wikimedia.org/wikipedia/commons/6/67/User_Avatar.png'),
                      ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 190),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 55,
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            doctor.name ?? '',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(242, 8, 5, 5)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              doctor.category ?? '',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 15, color: Color.fromARGB(178, 0, 0, 0)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(0),
            child: Container(
              child: GestureDetector(
                onTap: () {},
                child: (Center(
                  child: buildRatingStars(doctor.rating ?? 0),
                )),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     try {
                  //       final response = await Api.getdoctor(doctor.id ?? '');
                  //       String responseBody = response.body;
                  //       if (responseBody.contains("doctor")) {
                  //         responseBody =
                  //             responseBody.replaceAll("doctor", "user");
                  //       }
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => Appointment(
                  //                   doctorinfo: responseBody, userid: userid)));
                  //     } catch (error) {
                  //       print("Error in API call: $error");
                  //       // Handle the error, e.g., show a message to the user
                  //     }
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //       primary: const Color(0xFF389AAB)),
                  //   child: Row(
                  //     children: const [
                  //       Icon(
                  //         Icons.date_range_outlined,
                  //         color: Colors.white,
                  //       ),
                  //       SizedBox(
                  //         width: 4,
                  //       ),
                  //       Text(
                  //         'Book Apointment',
                  //         style: TextStyle(color: Colors.white),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(
                  //   width: 10,
                  // ),
                  ElevatedButton(
                    onPressed: () {
                      //  setState(() {
                      rating2();
                      //  });
                    },
                    style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF389AAB)),
                    child: Row(
                      children: const [
                        Icon(Icons.rate_review_outlined, color: Colors.white),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Add Rating',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  // Padding(
                  // padding: EdgeInsets.symmetric(horizontal: 110),
                  // child:
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        "Review",
                        arguments: {
                          'doctorId': doctorID,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF389AAB)),
                    child: Row(
                      children: [
                        Text(
                          'show all review',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(Icons.arrow_outward, color: Colors.white),
                        SizedBox(
                          width: 4,
                        ),
                      ],
                    ),
                  ),
                  // ),
                ],
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 110),
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.pushNamed(
              //         context,
              //         "Review",
              //         arguments: {
              //           'doctorId': doctorID,
              //         },
              //       );
              //     },
              //     style: ElevatedButton.styleFrom(
              //         primary: const Color(0xFF389AAB)),
              //     child: Row(
              //       children: [
              //         Text(
              //           'show all review',
              //           style: TextStyle(color: Colors.white),
              //         ),
              //         SizedBox(
              //           width: 5,
              //         ),
              //         Icon(Icons.arrow_outward, color: Colors.white),
              //         SizedBox(
              //           width: 4,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              Padding(
                // padding: const EdgeInsets.all(8.0),
                padding: EdgeInsets.symmetric(horizontal: 110),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final response = await Api.getdoctor(doctor.id ?? '');
                      String responseBody = response.body;
                      if (responseBody.contains("doctor")) {
                        responseBody =
                            responseBody.replaceAll("doctor", "user");
                      }
                      setState(() {
                        doctorsList = [];
                      });

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Appointment(
                                  doctorinfo: responseBody, userid: userid)));
                    } catch (error) {
                      print("Error in API call: $error");
                      // Handle the error, e.g., show a message to the user
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF389AAB)),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.date_range_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Book Apointment',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(
            thickness: 1,
            height: 10,
            color: Colors.grey[900],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(children: [
              Row(
                children: [
                  Icon(
                    Icons.email,
                    color: Colors.blue,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    //   width: MediaQuery.of(context).size.width - 50.0,
                    padding: const EdgeInsets.all(5),
                    child: RichText(
                        text: TextSpan(
                            style: const TextStyle(fontSize: 18),
                            children: [
                          TextSpan(
                              text: doctor.email,
                              style: const TextStyle(color: Colors.black))
                        ])),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                      onTap:
                          onTaplocation, // Assuming onTapFacebook is a callback function
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                      )),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    //width: MediaQuery.of(context).size.width - 50.0,
                    padding: const EdgeInsets.all(5),
                    child: RichText(
                        text: TextSpan(
                            style: const TextStyle(fontSize: 18),
                            children: [
                          TextSpan(
                              text: doctor.city,
                              style: const TextStyle(color: Colors.black)),
                          TextSpan(
                              //  text: ' click to see location',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13))
                        ])),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: Colors.green,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    // width: MediaQuery.of(context).size.width - 50.0,
                    padding: const EdgeInsets.all(5),
                    child: RichText(
                        text: TextSpan(
                            style: const TextStyle(fontSize: 18),
                            children: [
                          TextSpan(
                              text: doctor.phoneNumber,
                              style: const TextStyle(color: Colors.black))
                        ])),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.yellow,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    // width: MediaQuery.of(context).size.width - 50.0,
                    padding: const EdgeInsets.all(5),
                    child: RichText(
                        text: TextSpan(
                            style: const TextStyle(fontSize: 18),
                            children: [
                          TextSpan(
                            text: doctor.startTime,
                            style: const TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: ' - ',
                            style: const TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: doctor.endTime,
                            style: const TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                              text: isOpenNow ? ' Open now' : ' Closed now',
                              style: TextStyle(
                                color: isOpenNow ? Colors.green : Colors.red,
                              ))
                        ])),
                  ),
                  InkWell(
                      onTap:
                          workingDays, // Assuming onTapFacebook is a callback function
                      child: Icon(
                        Icons.keyboard_arrow_down,
                      )),
                ],
              ),

              ///////////////////////////
            ]),
          ),
          Divider(
            thickness: 1,
            height: 10,
            color: Colors.grey[900],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap:
                        onTapFacebook, // Assuming onTapFacebook is a callback function
                    child: Icon(
                      FontAwesomeIcons.facebook,
                      color: Color(0xFF1877F2),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap:
                        onTapInstgram, // Assuming onTapFacebook is a callback function
                    child: Icon(
                      FontAwesomeIcons.instagram,
                      color: Color(0xFFE4405F),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(FontAwesomeIcons.linkedin, color: Color(0xFF0077B5)),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      Text(
                        textAlign: TextAlign.left,
                        "Suggestions that may suit you",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Icon(
                        Icons.auto_awesome,
                        size: 30,
                        color: mainColor,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 15.0, top: 15),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        doctorsList.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.05),
                          child: GestureDetector(
                            onTap: () async {
                              print("test");
                              try {
                                final response = await Api.getdoctor(
                                    doctorsList[index]['id'] ?? '');
                                String responseBody = response.body;
                                if (responseBody.contains("doctor")) {
                                  responseBody =
                                      responseBody.replaceAll("doctor", "user");
                                }
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return UserProfiledoc(
                                    doctorinfo: responseBody,
                                    userid: userid,
                                  );
                                }));
                              } catch (error) {
                                print("Error in API call: $error");
                                // Handle the error, e.g., show a message to the user
                              }
                            },
                            child: Container(
                              width: screenWidth > 600
                                  ? 200
                                  : 150, // Adjust the width as needed
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4.0,
                                    spreadRadius: 0.05,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      height: 100,
                                      width: 200,
                                      child: doctorsList[index]['ProfileImg'] ==
                                              ""
                                          ? Image.asset(
                                              "images/logo2.png",
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              doctorsList[index]['ProfileImg'],
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "${doctorsList[index]['name']}",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${doctorsList[index]['category']}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: const Color.fromARGB(
                                          255, 144, 141, 141),
                                    ),
                                  ),
                                  Text(
                                    "${doctorsList[index]['city']}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: const Color.fromARGB(
                                          255, 144, 141, 141),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      5,
                                      (starIndex) => Icon(
                                        Icons.star,
                                        color: starIndex <
                                                doctorsList[index]['Rating']
                                            ? Colors.yellow
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
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
          SizedBox(
            height: 50,
          )
        ],
      )),
      /*   bottomNavigationBar: BottomAppBar(
          color:
              Color(0xFF389AAB), // Set the background color of the BottomAppBar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _icons
                .asMap()
                .entries
                .map(
                  (entry) => IconButton(
                    icon: Icon(
                      entry.value,
                      size: 32.0, // Adjust the icon size as needed
                      color: _selectedIndex == entry.key
                          ? Colors.white
                          : Colors.white,
                    ),
                    onPressed: () {
                      _onItemTapped(entry.key);
                    },
                  ),
                )
                .toList(),
          ),
        ) */
    );
  }
}
