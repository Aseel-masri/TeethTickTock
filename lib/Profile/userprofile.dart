import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:untitled/Profile/usereditprofile.dart';
import 'package:untitled/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/model/doctor.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/model/user.dart';

class ProfileUser extends StatefulWidget {
  final String userinfo;
  final bool visit;

  ProfileUser({required this.userinfo, required this.visit});

  @override
  _UserStateProfile createState() => _UserStateProfile();
}

class _UserStateProfile extends State<ProfileUser> {
  @override
  Userr user = Userr();
  late String today = '';
  late bool isOpenNow = false;
  @override
  void initState() {
    super.initState();
    getinfo();
  }

  void getinfo() async {
    setState(() {
      Map<String, dynamic> parsedJson = json.decode(widget.userinfo);
      user.id = parsedJson['_id'];
      user.name = parsedJson['name'];
      user.email = parsedJson['email'];
      user.phoneNumber = parsedJson['phoneNumber'];
      user.city = parsedJson['city'];
      user.profileImg = "http://10.0.2.2:8081/profileimg/"+parsedJson['ProfileImg'];
    });
  }

  final picker = ImagePicker();
  String? uploadedImageUrl;
  String imgurl =
      'http://10.0.2.2:8081/profileimg/default.jpg';
  static int x2 = 0;

  Future uploadImage(File image) async {
    x2++;
    String? ss = user.id;
    var uri = Uri.parse(
        "http://10.0.2.2:8081/users/changeimage/" + ss! + "/$x2");
    print("URL--------> $uri");
    var request = http.MultipartRequest("PUT", uri);
    var multipartFile = await http.MultipartFile.fromPath('photo', image.path);
    request.files.add(multipartFile);

    var response = await request.send();
    if (response.statusCode == 200) {
      print("Image uploaded successfully");
      setState(() {
        // Set the URL of the uploaded picture
        String? s = user.id;
        String defaultId = "default_id"; // Set your default value here

        String idPart = s?.isEmpty == true ? defaultId : s ?? defaultId;

        uploadedImageUrl =
            "http://10.0.2.2:8081/profileimg/pic$x2$idPart.png";

        user.profileImg = uploadedImageUrl;
        print('uploadedImageUrl $uploadedImageUrl');
        imgurl = uploadedImageUrl!; // Replace with the actual URL
        user.profileImg = imgurl;
      });
    } else {
      setState(() {
        print("Image upload failed");
      });
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadImage(File(pickedFile.path));
    }
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

    if (index == 0) {}
    if (index == 1) {
      print("Notifications");
    }
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color customColor = const Color(0xFFBBF1FA);
    Color mainColor = const Color(0xFF389AAB);
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
                // Navigator.of(context).pushNamed("HomePage");
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
                    margin: EdgeInsets.only(bottom: 10),
                    //  width: MediaQuery.of(context).size.width,
                    height: 180,
                    decoration: BoxDecoration(
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
                      backgroundImage: NetworkImage(user.profileImg ??
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
                        widget.visit
                            ? Container()
                            : Container(
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
                user.name ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(242, 8, 5, 5),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "${user.name}'s information ",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF389AAB),
                        ),
                      ),
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
                                          EditUserProfile(id: user.id ?? '')),
                                );
                              },
                              child: widget.visit
                                  ? Container()
                                  : Icon(
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
                SizedBox(
                  height: 10,
                ),
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
                                text: user.email,
                                style: const TextStyle(color: Colors.black))
                          ])),
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
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
                                text: user.city ?? '',
                                style: const TextStyle(color: Colors.black)),
                            TextSpan(
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
                      padding: const EdgeInsets.all(5),
                      child: RichText(
                          text: TextSpan(
                              style: const TextStyle(fontSize: 18),
                              children: [
                            TextSpan(
                                text: user.phoneNumber ?? '',
                                style: const TextStyle(color: Colors.black))
                          ])),
                    ),
                  ],
                ),
              ]),
              SizedBox(
                height: 15,
              ),
              Divider(
                thickness: 1,
                height: 10,
                color: Colors.grey[900],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          )),
      // bottomNavigationBar: BottomAppBar(
      //   color:
      //       Color(0xFF389AAB), // Set the background color of the BottomAppBar
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: _icons
      //         .asMap()
      //         .entries
      //         .map(
      //           (entry) => IconButton(
      //             icon: Icon(
      //               entry.value,
      //               size: 32.0, // Adjust the icon size as needed
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
      // )
    );
  }
}
