import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the package
import 'package:untitled/Profile/DoctorHomePage.dart';
import 'package:untitled/maps/map.dart';
import 'package:untitled/servicies/api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled/main.dart';
import './editprofile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'usertodoctor.dart';
import 'package:untitled/model/doctor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'userprofile.dart';

class Profile extends StatefulWidget {
  final String username;

  Profile({required this.username});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Uint8List? _image;
  Uint8List? _image2;

  Doctor doctor = Doctor();
  late String today = '';
  late bool isOpenNow = false;
  @override
  void initState() {
    super.initState();
    today = DateFormat('EEEE').format(DateTime.now());
    print('Today is $today');
    getinfo();
    //conv();
  }

  String doctorID = "";
  void getinfo() async {
    Map<String, dynamic> parsedJson = json.decode(widget.username);
    String temp = parsedJson['doctor']['category'];
    String category = await Api.getcategory(temp ?? '');
    doctorID = parsedJson['doctor']['_id'];
    doctor.workingDays = List<String>.from(parsedJson['doctor']['WorkingDays']);
    setState(() {
      doctor.id = parsedJson['doctor']['_id'];
      doctor.name = parsedJson['doctor']['name'];
      doctor.email = parsedJson['doctor']['email'];
      doctor.password = parsedJson['doctor']['password'];
      doctor.phoneNumber = parsedJson['doctor']['phoneNumber'];
      doctor.city = parsedJson['doctor']['city'];
      doctor.locationMap = parsedJson['locationMap'];
      doctor.rating = parsedJson['doctor']['Rating'] as int? ?? 0;
      doctor.startTime = parsedJson['doctor']['StartTime'];
      doctor.endTime = parsedJson['doctor']['EndTime'];
      doctor.profileImg ="http://10.0.2.2:8081/profileimg/" + parsedJson['doctor']['ProfileImg'];
      doctor.category = category;
      print('cat..');
      print(doctor.workingDays);
      print(doctor.category);
      checkopen(doctor.workingDays ?? []);
      updateStatusBasedOnWorkingDays(doctor.workingDays ?? []);
    });
  }

  final picker = ImagePicker();
  String? uploadedImageUrl; // Store the URL of the uploaded picture
  String imgurl =
     "http://10.0.2.2:8081/profileimg/default.jpg" ;
  static int x = 0;

  Future uploadImage(File image) async {
    x++;
    String? ss = doctor.id;
    var uri = Uri.parse(
        "http://10.0.2.2:8081/doctors/changeimage/" + ss! + "/$x");
    print("URL--------> $uri");
    var request = http.MultipartRequest("PUT", uri);
    var multipartFile = await http.MultipartFile.fromPath('photo', image.path);
    request.files.add(multipartFile);

    var response = await request.send();
    if (response.statusCode == 200) {
      print("Image uploaded successfully");
      setState(() {
        // Set the URL of the uploaded picture
        String? s = doctor.id;
        String defaultId = "default_id"; // Set your default value here

        String idPart = s?.isEmpty == true ? defaultId : s ?? defaultId;

        uploadedImageUrl =
            "http://10.0.2.2:8081/profileimg/pic$x$idPart.png";

        doctor.profileImg = uploadedImageUrl;
        print('uploadedImageUrl $uploadedImageUrl');
        imgurl = uploadedImageUrl!; // Replace with the actual URL
        doctor.profileImg = imgurl;
      });
    } else {
      print("Image upload failed");
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadImage(File(pickedFile.path));
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
  void checkopen(List<String> workingDays) {
    for (int i = 0; i < workingDays.length; i++) {
      if (workingDays[i] == today) {
        isOpenNow = true;
        break;
      }
    }
  }

  void updateStatusBasedOnWorkingDays(List<String> workingDays) {
    setState(() {
      for (int i = 0; i < workingDays.length; i++) {
        String day = workingDays[i];
        switch (day) {
          case 'Sunday':
            statuses[1] = 'Open';
            print('open');
            break;
          case 'Monday':
            statuses[2] = 'Open';
            print('open');
            break;
          case 'Tuesday':
            statuses[3] = 'Open';
            print('open');
            break;
          case 'Wednesday':
            statuses[4] = 'Open';
            print('open');
            break;
          case 'Thursday':
            statuses[5] = 'Open';
            print('open');
            break;
          case 'Friday':
            statuses[6] = 'Open';
            print('open');
            break;
          case 'Saturday':
            statuses[0] = 'Open';
            print('open');
            break;
        }
      }
    });
  }

  void workingDays() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
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
                          ),
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

  Future<void> onTaplocation() async {
    final response = await Api.getlocation(doctor.id ?? '');

    if (response.statusCode == 200) {
      // Successful login
      print(response.body);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle Clinic Location button tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PositionMap(id: widget.username, flag: "show")),
                    );
                  },
                  child: Text(
                    'Show Clinic Location',
                    style: TextStyle(color: Color(0xFF389AAB)),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PositionMap(id: widget.username, flag: "edit")),
                    );
                  },
                  child: Text(
                    'Edit to Current Location',
                    style: TextStyle(color: Color(0xFF389AAB)),
                  ),
                ),
              ],
            ),
          );
        },
      );
      //myMarkerPosition=jsonEncode(response.body) as LatLng;
    } else {
      print('location failed');
      print(response.body);
    }
    /* Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Position(id: widget.username)),
    ); */
  }

  void onTapFacebook() {
    launch('https://www.facebook.com/salehdentalclinic');
  }

  void onTapInstgram() {
    launch('https://www.instagram.com/saleharandi/');
  }

  int _selectedIndex = 0;

  static const List<IconData> _icons = [
    Icons.message_outlined,
    Icons.notifications,
    Icons.logout,
  ];

  Future<void> _onItemTapped(int index) async {
    /* setState(()  */
    _selectedIndex = index;

    if (index == 0) {
      final response = await Api.getdoctor(doctor.id ?? '');

      if (response.statusCode == 200) {
        // Successful login
        print('Login successful');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfiledoc(
                      doctorinfo: response.body,
                      userid: '',
                    )));

        print(response.body);
      } else {
        print('Login failed');
        print(response.body);
      }

      print("Messages");
    }
    if (index == 1) {
      //ProfileUser
      /*  Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileUser(
                    userinfo: '',
                  ))); */
      print("Notifications");
    }
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
    }
  }
  //);

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

  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);
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
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return DoctorHomePage();
                  //Profile(username: response.body);
                }));

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
      body: Container(
          padding: const EdgeInsets.only(left: 4, right: 4),
          color: Colors.white,
          constraints: const BoxConstraints.expand(),
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
                    margin: const EdgeInsets.only(top: 80), //getImage()
                    child: CircleAvatar(
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
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(55))),
                          child: IconButton(
                              onPressed: getImage,
                              icon: Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                              )),
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
                  color: Color.fromARGB(242, 8, 5, 5),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  doctor.category ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15, color: Color.fromARGB(178, 0, 0, 0)),
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
              SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 112),
                child: ElevatedButton(
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
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          height: 10,
                          color: Colors.grey[900],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF212121), // Border color
                              width: 2, // Border width
                            ),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.all(3), // Adjust the margin here
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditProfile(id: doctor.id ?? '')),
                                );
                              },
                              child: Icon(
                                Icons.edit,
                                color: Color(0xFF389AAB),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Other widgets in your column...
                ],
              ),
              Column(children: [
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
                        onTap: onTaplocation,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                        )),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      child: RichText(
                          text: TextSpan(
                              style: const TextStyle(fontSize: 18),
                              children: [
                            TextSpan(
                                text: doctor.city ?? '',
                                style: const TextStyle(color: Colors.black)),
                            TextSpan(
                                text: ' click to see or edit location',
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
                      //  width: MediaQuery.of(context).size.width - 50.0,
                      padding: const EdgeInsets.all(5),
                      child: RichText(
                          text: TextSpan(
                              style: const TextStyle(fontSize: 18),
                              children: [
                            TextSpan(
                                text: doctor.phoneNumber ?? '',
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
                        ))
                  ],
                ),
              ]),
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
            ],
          )),
      /*  bottomNavigationBar: BottomAppBar(
           elevation: 6,
          shadowColor: mainColor,
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
