import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:untitled/maps/testmap.dart' as globallocation;
import 'package:untitled/servicies/api.dart';

class SignUpDoctor extends StatefulWidget {
  const SignUpDoctor({super.key});

  @override
  State<SignUpDoctor> createState() => _SignUpDoctorState();
}

class _SignUpDoctorState extends State<SignUpDoctor> {
  Color customColor = const Color(0xFFBBF1FA); // Define custom color
  Color buttonColor = const Color(0xFF389AAB);
  String valueChose = "Nablus";
  String specialtyChose = "Cosmetic dentist";
  List specialtyList = [
    "Cosmetic dentist",
    "Pediatric dentist",
    "Dental neurologist",
    "Dental surgeon",
    "Orthodontist",
  ];
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
  String drLocation = "";
  static bool addlocation = true;
  void _addLocation() {
    drLocation = "added location";
    addlocation = false;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => globallocation.Current_position()));
  }

  Future<void> _signUpButtonTapped() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String phone = _phoneController.text;
    String selectedCity = valueChose;
    String specialty = specialtyChose;

    print('name: $name');
    print('Email: $email');
    print('Password: $password');
    print('phone: $phone');
    print("City :$selectedCity");
    print("City :$specialty");
    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        phone.isEmpty ||
        addlocation) {
      print("All fields are required");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'All fields are required',
        desc: 'Please enter all information',
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
      print("Location --> ");
      print(globallocation.globallatitude);
      print(globallocation.globallongitude);
      /*
       {
    "name": "Dr. Saleh Arandi",
    "email": "saleh@hotmail.com",
    "password": "3",
    "phoneNumber": "+972 59-434-1882",
    "city": "'Nablus'",
    "locationMap": [
        32.22219,
        35.262191 
    ],
    "category": "Cosmetic dentist"
}
       */
      setState(() {
        addlocation = true;
      });
      var data = {
        "name": name,
        "email": email,
        "password": password,
        "phoneNumber": phone,
        "city": selectedCity,
        "locationMap": [
          globallocation.globallatitude, 
          globallocation.globallongitude 
        ],
        "category": specialty
      };
      final response = await Api.adddoctorrequest(data);

      if (response.statusCode == 200) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'successfully registered',
          desc: 'Please wait for approval',
          // btnCancelOnPress: () {
          //   Navigator.of(context).pop();
          // },
          btnOkOnPress: () {
            Navigator.pushNamed(context, "LogIn");
          },
          btnCancelColor: Color.fromARGB(255, 32, 87, 97),
          btnOkColor: Color.fromARGB(255, 56, 154, 171),
          descTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97)),

          // titleTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97))
        )..show();
      } else {
        print(response.body);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'Faild registered',
          desc: response.body,
          // btnCancelOnPress: () {
          //   Navigator.of(context).pop();
          // },
          btnOkOnPress: () {
            //Navigator.pushNamed(context, "LogIn");
          },
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
      body: Container(
        // height: MediaQuery.of(context).size.height,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
              ),
              Image.asset(
                'images/logo2.png',
                width: 130.0,
                color: Color.fromARGB(255, 32, 87, 97),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                // height: 700,
                width: 360,
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
                        width: 270,
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
                              labelText: "Dr Name",
                              suffixIcon: Icon(
                                FontAwesomeIcons.user,
                                size: 17,
                              )),
                        ),
                      ),

                      Container(
                        width: 270,
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
                        width: 270,
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
                        width: 270,
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
                        padding:
                            const EdgeInsets.only(left: 30, right: 30, top: 18),
                        child: Container(
                          padding: EdgeInsets.only(left: 13, right: 13),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
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
                            value: valueChose,
                            onChanged: (val) {
                              setState(() {
                                valueChose = "$val";
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
                        padding:
                            const EdgeInsets.only(left: 30, right: 30, top: 18),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text("Enter your specialty :",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 74, 201, 224)))),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 30, right: 30, top: 18),
                        child: Container(
                          padding: EdgeInsets.only(left: 13, right: 13),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(15)),
                          child: DropdownButton(
                            hint: Text("specialty"),
                            // dropdownColor: Color.fromARGB(255, 187, 239, 250),
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 36,
                            isExpanded: true,
                            underline: SizedBox(),
                            style: TextStyle(
                                color: Color.fromARGB(255, 74, 201, 224),
                                fontSize: 16),
                            value: specialtyChose,
                            onChanged: (val) {
                              setState(() {
                                specialtyChose = "$val";
                              });
                            },
                            items: specialtyList.map((cityval) {
                              return DropdownMenuItem(
                                  value: cityval, child: Text(cityval));
                            }).toList(),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 30, right: 30, top: 18),
                        child: Row(
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                child: Text("Add your clinic location:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(
                                            255, 74, 201, 224)))),
                            // GestureDetector(
                            //   onTap: _addLocation,
                            //   child: Container(
                            //     margin: EdgeInsets.only(left: 10),
                            //     alignment:
                            //         Alignment.center, // Set alignment here
                            //     width: 120, // Adjust the width as needed
                            //     height: 40,
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(10),
                            //       color: Color.fromARGB(255, 74, 201, 224),
                            //     ),
                            //     child: Padding(
                            //       padding: EdgeInsets.all(2.0),
                            //       child: Container(
                            //         alignment: Alignment.center,
                            //         child: Text(
                            //           "Add Location",
                            //           style: TextStyle(
                            //             color: Colors.white,
                            //             fontSize: 15,
                            //             fontWeight: FontWeight.bold,
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            GestureDetector(
                              onTap: _addLocation,
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                alignment: Alignment.center,
                                width: 120,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color.fromARGB(255, 74, 201, 224),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: Offset(
                                          0, 2), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Add Location",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                                setState(() {
                                  addlocation = true;
                                });

                                Navigator.of(context)
                                    .pushNamed("LogIn"); // Use "LogIn" here
                              }),
                              child: Text(
                                "Click here",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Color.fromARGB(255, 74, 201, 224),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: _signUpButtonTapped,
                        child: Container(
                          alignment: Alignment.center,
                          width: 260,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(255, 56, 154, 171),
                                Color.fromARGB(255, 74, 201, 224),
                                Color.fromARGB(255, 187, 239, 250),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                              "SignUp",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 22,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
