import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;

class SendEmail extends StatefulWidget {
  const SendEmail({super.key});

  @override
  State<SendEmail> createState() => _SendEmailState();
}

class _SendEmailState extends State<SendEmail> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController();
  // String emailUser = "";

  Future<void> _signUpButtonTapped() async {
    String name = _nameController.text;
    // String email = _emailController.text;
    String content = _contentController.text;
    String subject = _subjectController.text;
    final serviceId = 'service_ahyte6r'; //service_fcoxknn
    final templateId = 'template_1iedrlf'; //template_l1jj4l4
    final userId = 'udAhUNkYzaE3Lfr0t'; ////jNnzsQ_l_16bKhioh
    print("name :$name");
    // print("email :$email");
    print("subject :$subject");
    print("content :$content");
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    final response = await http.post(url,
        headers: {
          'origin': 'http://localhost', // to work on mobile app
          'Content-Type': 'application/json' // to work on website
        },
        body: json.encode({
          "service_id": serviceId,
          "template_id": templateId,
          "user_id": userId,
          "template_params": {
            'user_name': name,
            'user_email': emailUser,
            'user_subject': subject,
            'user_message': content,
          }
        }));
    if (response.statusCode == 200) {
      print('Email sent successfully!');
      print(response.body);

      AwesomeDialog(
        // width: 600,
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Sucsses',
        desc: 'The email was sent successfully',
        btnOkOnPress: () {
          _nameController.clear();
          _subjectController.clear();
          _contentController.clear();
        },
        btnCancelColor: Color.fromARGB(255, 32, 87, 97),
        btnOkColor: Color.fromARGB(255, 56, 154, 171),
        descTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97)),

        // titleTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97))
      )..show();
    } else {
      AwesomeDialog(
        // width: 600,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Error',
        desc: 'There was an error. Try again later',
        btnOkOnPress: () {},
        btnCancelColor: Color.fromARGB(255, 32, 87, 97),
        btnOkColor: Color.fromARGB(255, 56, 154, 171),
        descTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97)),

        // titleTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97))
      )..show();
      print('Failed to send email. Status code: ${response.statusCode}');
      print(response.body);
    }
  }

  String emailUser = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _emailController.text = emailUser;
  }

  // String emailUser = "teethTickTock@gmail.com";

  @override
  Widget build(BuildContext context) {
    // Extract arguments
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Get the emailUser from arguments
    setState(() {
      emailUser = args['emailUser'];
    });
    final TextEditingController _emailController =
        TextEditingController(text: emailUser);
    // TextEditingController _emailController =
    //     TextEditingController(text: emailUser);
    // Create a new instance of TextEditingController
    // TextEditingController _emailController =
    //     TextEditingController(text: emailUser);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // height: MediaQuery.of(context).size.height,
          height: MediaQuery.of(context).size.height + 150,
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
                height: 25,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("HomePage");
                  // Add your onTap action for the title image here
                  print("Title Image Tapped");
                },
                child: Image.asset(
                  'images/logo2.png',
                  width: 140.0,
                  color: Color.fromARGB(255, 32, 87, 97),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 630,
                width: 400,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Send Email",
                        style: TextStyle(
                            color: Color.fromARGB(255, 32, 87, 97),
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        // width: 270,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 40),
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
                              labelText: "Name : ",
                              suffixIcon: Icon(
                                Icons.account_circle_rounded,
                                size: 17,
                              )),
                        ),
                      ),
                      Container(
                        // width: 270,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextFormField(
                          readOnly: true,
                          controller: _emailController,
                          cursorColor: Color.fromARGB(255, 74, 201, 224),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              // filled: true,
                              // fillColor: Color.fromARGB(255, 187, 239, 250),
                              focusColor: Color.fromARGB(255, 74, 201, 224),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Color.fromARGB(255, 74, 201, 224),
                              )),
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 74, 201, 224)),
                              iconColor: Color.fromARGB(255, 74, 201, 224),
                              labelText: "Email Address :",
                              suffixIcon: Icon(
                                FontAwesomeIcons.solidEnvelope,
                                size: 17,
                              )),
                        ),
                      ),
                      Container(
                        // width: 270,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextFormField(
                          controller: _subjectController,
                          cursorColor: Color.fromARGB(255, 74, 201, 224),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              focusColor: Color.fromARGB(255, 74, 201, 224),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Color.fromARGB(255, 74, 201, 224),
                              )),
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 74, 201, 224)),
                              iconColor: Color.fromARGB(255, 74, 201, 224),
                              labelText: "Subject : ",
                              suffixIcon: Icon(
                                Icons.edit,
                                size: 17,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Email content :  ",
                        style: TextStyle(
                          color: Color.fromARGB(255, 74, 201, 224),
                          fontSize: 20,
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        // width: 270,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextFormField(
                          controller: _contentController,
                          cursorColor: Color.fromARGB(255, 74, 201, 224),
                          maxLines: 6, // Allows multiline input
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 74, 201,
                                      224)), // Change the border color when focused
                            ),
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 74, 201, 224)),
                            iconColor: Color.fromARGB(255, 74, 201, 224),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
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
                              "Send Email ",
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
                        height: 10,
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
