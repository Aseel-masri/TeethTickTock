import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool showspinner = false;
  final _auth = FirebaseAuth.instance;
  Color customColor = const Color(0xFFBBF1FA); // Define custom color
  Color buttonColor = const Color(0xFF389AAB);
  String ValueChose = "Nablus";
  List Citys = [
    "Nablus",
    "Hebron",
    "Ramallah",
    "Tulkarm",
    "Jenin",
    "Qalqila",
    "Tubas",
    "Jericho",
    "Salfit"
  ];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  void _signUpButtonTapped() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String phone = _phoneController.text;
    String selectedCity = ValueChose;

    print('name: $name');
    print('Email: $email');
    print('Password: $password');
    print('phone: $phone');
    print("City :$selectedCity");
    if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
      print("All fields are required");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'All fields are required',
        desc: 'Please enter all information',
        btnCancelOnPress: () {
          Navigator.of(context).pop();
        },
        btnOkOnPress: () {},
        btnCancelColor: Color.fromARGB(255, 32, 87, 97),
        btnOkColor: Color.fromARGB(255, 56, 154, 171),
        descTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97)),

        // titleTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97))
      )..show();
    } else {
      /*******************firebase ***********************/
      setState(() {
        showspinner = true;
      });
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
      } catch (e) {
        print("error from fireBase :- ${e}");
      }
      /**************************************************/
      // Navigator.pushNamed(context, "LogIn");
      final userData = {
        "name": name,
        "email": email,
        "password": password,
        "phoneNumber": phone,
        "city": selectedCity,
        "ProfileImg":"default.jpg",
        "token":""
        
      };
      // Send a POST request to your server for user creation
      final response = await http.post(
        Uri.parse(
            "http://10.0.2.2:8081/users"), // Replace with your server URL
        body: json.encode(userData),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'Done',
          desc: 'successfully registered',
          // btnCancelOnPress: () {

          // },
          btnOkOnPress: () {
            Navigator.pushNamed(context, "LogIn");
            // Navigator.pushNamed(context, "Messages");
            setState(() {
              showspinner = false;
            });
          },
          btnCancelColor: Color.fromARGB(255, 32, 87, 97),
          btnOkColor: Color.fromARGB(255, 56, 154, 171),
          descTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97)),

          // titleTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97))
        )..show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'Error',
          desc: 'User creation failed',
          // btnCancelOnPress: () {
          // },
          btnOkOnPress: () {},
          btnCancelColor: Color.fromARGB(255, 32, 87, 97),
          btnOkColor: Color.fromARGB(255, 56, 154, 171),
          descTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97)),
        )..show();
        // print("User creation failed");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showspinner,
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
                  height: 40,
                ),
                Image.asset(
                  'images/logo2.png',
                  width: 150.0,
                  color: Color.fromARGB(255, 32, 87, 97),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 560,
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
                          "SignUp",
                          style: TextStyle(
                              color: Color.fromARGB(255, 32, 87, 97),
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // Text(
                        //   "Login to your Account",
                        //   style: TextStyle(
                        //     fontSize: 15,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        SizedBox(
                          height: 10,
                        ),

                        Container(
                          width: 250,
                          child: TextFormField(
                            controller: _nameController,
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
                                labelText: "User Name",
                                suffixIcon: Icon(
                                  FontAwesomeIcons.user,
                                  size: 17,
                                )),
                          ),
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
                            controller: _phoneController,
                            cursorColor: Color.fromARGB(255, 74, 201, 224),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                focusColor: Color.fromARGB(255, 74, 201, 224),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(255, 74, 201, 224),
                                )),
                                labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 74, 201, 224)),
                                iconColor: Color.fromARGB(255, 74, 201, 224),
                                labelText: "Phone number",
                                suffixIcon: Icon(
                                  FontAwesomeIcons.phone,
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
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, top: 18),
                          child: Container(
                            padding: EdgeInsets.only(left: 13, right: 13),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15)),
                            child: DropdownButton(
                              hint: Text("Select Your City"),

                              // dropdownColor: Color.fromARGB(255, 187, 239, 250),
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 36,
                              isExpanded: true,
                              underline: SizedBox(),
                              style: TextStyle(
                                  color: Color.fromARGB(255, 74, 201, 224),
                                  fontSize: 16),
                              value: ValueChose,
                              onChanged: (val) {
                                setState(() {
                                  ValueChose = "$val";
                                });
                              },
                              items: Citys.map((cityval) {
                                return DropdownMenuItem(
                                    value: cityval, child: Text(cityval));
                              }).toList(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 40, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Alrady have an acount?",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 32, 87, 97)),
                              ),
                              InkWell(
                                onTap: (() {
                                  Navigator.of(context)
                                      .pushNamed("LogIn"); // Use "LogIn" here
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
                          onTap: _signUpButtonTapped,
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
                                "SignUp",
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
