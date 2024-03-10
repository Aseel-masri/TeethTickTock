import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:untitled/MessagesUserList.dart';
import 'package:untitled/Profile/doctorprofile.dart';
import 'package:untitled/HomePage.dart';
import 'package:untitled/Profile/DoctorHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:untitled/servicies/api.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool showspinner = false;
  final _auth = FirebaseAuth.instance;
  var fbm_token = FirebaseMessaging.instance.getToken();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // String name = '';

  // // Function to save user data in local storage
  final LocalStorage storage = new LocalStorage('my_data');

  void saveUserData(String name, String email, String id, String profileImg) {
    // Get the existing data from LocalStorage
    Map<String, dynamic>? existingData = storage.getItem('user_data_new');

    // If the data doesn't exist, create a new entry
    if (existingData == null) {
      existingData = {
        'name': name,
        'email': email,
        'id': id,
        "profileImg": profileImg
      };
    } else {
      // Modify the data
      existingData['name'] = name;
      existingData['email'] = email;
      existingData['id'] = id;
      existingData['profileImg'] = profileImg;
    }

    // Save the updated data back to LocalStorage
    storage.setItem('user_data_new', existingData);
  }

/*   void saveUserData(String name, String email, String id) {
    final localStorage = LocalStorage('user_data_new');
    final userData = {'name': name, 'email': email, 'id': id};
    localStorage.setItem('user_data_new', userData);
  } */

  void _loginButtonTapped() async {
    // Retrieve the email and password from the controllers
    String email = _emailController.text;
    String password = _passwordController.text;
    // Print the email and password to the console
    print('Email: $email, Password: $password');

    if (email.isEmpty && password.isEmpty) {
      print("enter your email and password");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'Incomplete input ',
        desc: 'Enter your email and password',
        // btnCancelOnPress: () {
        //   Navigator.of(context).pop();
        // },
        btnOkOnPress: () {},
        btnCancelColor: Color.fromARGB(255, 32, 87, 97),
        btnOkColor: Color.fromARGB(255, 56, 154, 171),
        descTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97)),

        // titleTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97))
      )..show();
    } else if (email.isEmpty && password.isNotEmpty) {
      print("enter your Email ");

      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'Required field',
        desc: 'Enter your email',
        // btnCancelOnPress: () {
        //   Navigator.of(context).pop();
        // },
        btnOkOnPress: () {},
        btnCancelColor: Color.fromARGB(255, 32, 87, 97),
        btnOkColor: Color.fromARGB(255, 56, 154, 171),
        descTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97)),

        // titleTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97))
      )..show();
    } else if (email.isNotEmpty && password.isEmpty) {
      print("enter your Password ");

      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'Required field',
        desc: 'Enter your password',
        // btnCancelOnPress: () {
        //   Navigator.of(context).pop();
        // },
        btnOkOnPress: () {},
        btnCancelColor: Color.fromARGB(255, 32, 87, 97),
        btnOkColor: Color.fromARGB(255, 56, 154, 171),
        descTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97)),

        // titleTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97))
      )..show();
    } else {
      setState(() {
        showspinner = true;
      });
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8081/login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      /*************************fireBase for messages*******/
      try {
        final user = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        if (user != null) {
          print("useeeeeeeeerrrrrrrrrr froooooommmmmmmm ${user}");
        }
      } catch (e) {
        print("error from login firebase--> ${e}");
      }

      if (response.statusCode == 200) {
        // setState(()  {
        final responseData = jsonDecode(response.body);
        // Check if the 'user' key exists in the responseData JSON
        // if (responseData.containsKey('user')) {
        final userData2 = responseData['user'];
        final userdoctor = responseData['userdoctor'];
        //   final newtoken = responseData['token'];
        print('UserDoctor is $userdoctor');
        String name2 =
            userData2['name']; // Extract the user's name from the data
        String email2 =
            userData2['email']; // Extract the user's name from the data
        String id = userData2['_id'];
        String profileImg = userData2["ProfileImg"];
        print(
            "************************user data *************************************************");
        print(userData2);
        print(
            "************************user data *************************************************");
        // String profileImg = userData2["profileImg"];
        /*  name2 = userData2['name'];
          email2 = userData2['email']; */
        saveUserData(name2, email2, id, profileImg);
        // saveUserData(name2, email2);
        print('User data saved: name=$name2, email=$email2, id=$id');
        // saveUserData(name2, email2);
        final newtoken = await FirebaseMessaging.instance.getToken();
        if (userdoctor == 'doctor') {
          var data = {"token": newtoken};
          await Api.changeFCMdoctor(data, id);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            print(response.body);
            return DoctorHomePage();
            //Profile(username: response.body);
          }));
          /*   Navigator.of(context).pushReplacementNamed("Profile/doctorHomePage", arguments: {
              "name": name2, // user's name
              "email": email2, //user's email
            }); */
          setState(() {
            showspinner = false;
          });
        } else if (userdoctor == 'user') {
          //  saveUserid(id);
          var data = {"token": newtoken};
          await Api.changeFCMuser(data, id);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            print(response.body);
            return HomePage();
            //Profile(username: response.body);
          }));
          setState(() {
            showspinner = false;
          });
        }
        //  });
        // Store user data in local storage

        // Navigator.of(context).pushNamed("HomePage");
        // saveUserData(name2, email2);

        // Navigator.of(context).pushReplacementNamed("HomePage");
      } else {
        setState(() {
          showspinner = false;
        });
        // Failed login, display an error message
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'Login Failed ',
          desc: 'Invalid email or password. Please try again.',
          btnOkOnPress: () {},
          btnCancelColor: Color.fromARGB(255, 32, 87, 97),
          btnOkColor: Color.fromARGB(255, 56, 154, 171),
          descTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97)),

          // titleTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97))
        )..show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        color: customColor,
        inAsyncCall: showspinner,
        progressIndicator: CircularProgressIndicator(
          color: mainColor,
        ),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Color.fromARGB(255, 56, 154, 171),
                  Color.fromARGB(255, 74, 201, 224),
                  Color.fromARGB(255, 187, 239, 250)
                ])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80,
                ),
                Image.asset(
                  'images/logo2.png',
                  width: 200.0,
                  color: Color.fromARGB(255, 32, 87, 97),
                ),
                SizedBox(
                  height: 45,
                ),
                Container(
                  height: 430,
                  width: 325,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Login",
                          style: TextStyle(
                              color: Color.fromARGB(255, 32, 87, 97),
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Login to your Account",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 250,
                          child: TextFormField(
                            controller: _emailController,
                            cursorColor: Color.fromARGB(255, 74, 201, 224),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                focusColor: Color.fromARGB(255, 74, 201, 224),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(255, 74, 201, 224),
                                )),
                                labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 74, 201, 224)),
                                iconColor: Color.fromARGB(255, 74, 201, 224),
                                labelText: "Email Address",
                                suffixIcon: Icon(
                                  FontAwesomeIcons.envelope,
                                  size: 17,
                                )),
                          ),
                        ),
                        Container(
                          width: 250,
                          child: TextFormField(
                            controller: _passwordController,
                            cursorColor: Color.fromARGB(255, 74, 201, 224),

                            // keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            decoration: InputDecoration(
                                focusColor: Color.fromARGB(255, 74, 201, 224),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(255, 74, 201, 224),
                                )),
                                labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 74, 201, 224)),
                                iconColor: Color.fromARGB(255, 74, 201, 224),
                                labelText: "Password",
                                suffixIcon: Icon(
                                  FontAwesomeIcons.eyeSlash,
                                  size: 17,
                                )),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 40, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Don't have acount?",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 32, 87, 97)),
                              ),
                              InkWell(
                                onTap: (() {
                                  Navigator.of(context)
                                      .pushNamed("SelectedLogin");
                                }),
                                child: Text(
                                  "Click here",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 74, 201, 224),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: _loginButtonTapped,
                          child: Container(
                            alignment: Alignment.center,
                            width: 250,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromARGB(255, 56, 154, 171),
                                      Color.fromARGB(255, 74, 201, 224),
                                      Color.fromARGB(255, 187, 239, 250)
                                    ])),
                            child: Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
