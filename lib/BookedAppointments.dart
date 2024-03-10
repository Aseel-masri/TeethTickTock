import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:untitled/Profile/Review.dart';
import 'package:untitled/Profile/usereditappointment.dart';
import 'package:untitled/Profile/usertodoctor.dart';
import 'package:untitled/servicies/api.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class Appointment {
  final String id;
  final String appointmentTime;
  final String appointmentDate;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String appointmentTimePeriod;

  Appointment(
      {required this.id,
      required this.appointmentTime,
      required this.appointmentDate,
      required this.doctorId,
      required this.doctorName,
      required this.doctorSpecialty,
      required this.appointmentTimePeriod});
}

class BookedAppointments extends StatefulWidget {
  @override
  _BookedAppointmentsState createState() => _BookedAppointmentsState();
}

class _BookedAppointmentsState extends State<BookedAppointments> {
  late String userID;
  List<Appointment> appointments = [
    // Appointment(
    //   id: "1",
    //   appointmentTime: "05:00 PM",
    //   appointmentDate: "2023-11-10",
    //   doctorId: "1",
    //   doctorName: "Dr. Smith",
    //   doctorSpecialty: "Cardiology",
    // ),
  ];
  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);

  // get api => null;

  Future<void> deleteAppointmentlist(String appointmentId) async {
    //remove appointment from database
    await Api.deleteAppointment(appointmentId);
    setState(() {
      appointments
          .removeWhere((appointment) => appointment.id == appointmentId);
    });
  }
//work
  // Future<void> fetchUserAppointment(String userId) async {
  //   final response = await Api.fetchUserAppointments(userId);

  //   if (response.statusCode == 200) {
  //     final List<dynamic> userAppointments = json.decode(response.body);
  //     List<Appointment> fetchedAppointments = userAppointments
  //         .map((appointment) => Appointment(
  //               id: appointment['_id'],
  //               appointmentTime: appointment['appointmentTime'],
  //               appointmentDate: appointment['appointmentDate'],
  //               doctorId: appointment['doctor'],
  //               doctorName:
  //                   'test', // You need to fetch doctor details separately
  //               doctorSpecialty:
  //                   'test', // You need to fetch doctor details separately
  //             ))
  //         .toList();

  //     setState(() {
  //       appointments = fetchedAppointments;
  //     });

  //     print('User Appointments: $userAppointments');
  //   } else {
  //     print(
  //         'Failed to fetch user appointments. Status code: ${response.statusCode}');
  //   }
  // }
  // Custom function to parse date and time
  DateTime parseDateTime(String date, String time) {
    // Assuming date is in the format 'YYYY-MM-DD' and time is in the format 'hh:mm a'
    String dateTimeString = '$date $time';

    // Using intl package for parsing
    final dateTimeFormat = DateFormat('yyyy-MM-dd hh:mm a');
    return dateTimeFormat.parse(dateTimeString);
  }

  Future<void> fetchUserAppointment(String userId) async {
    final response = await Api.fetchUserAppointments(userId);
    if (response.statusCode == 200) {
      final List<dynamic> userAppointments = json.decode(response.body);
      List<Appointment> fetchedAppointments = [];
      for (var appointment in userAppointments) {
        final doctorId = appointment['doctor'];
        final doctorDetailsResponse = await Api.fetchDoctorDetails(doctorId);
        if (doctorDetailsResponse.statusCode == 200) {
          final Map<String, dynamic> doctorDetails =
              json.decode(doctorDetailsResponse.body);
          print('Doctor Details Response: $doctorDetailsResponse');
          print('Doctor Details: $doctorDetails');
          // Check if the 'doctor' property is present and is a map
          if (doctorDetails.containsKey('doctor') &&
              doctorDetails['doctor'] is Map<String, dynamic>) {
            final Map<String, dynamic> doctor = doctorDetails['doctor'];
            final doctorName = doctor['name'];
            final doctorCategory = doctor['category'];
            final doctorSpecialty = doctorCategory;

            if (doctorName != null && doctorSpecialty != null) {
              DateTime currentDate = DateTime.now();
              var targetDate = parseDateTime(appointment['appointmentDate'],
                  appointment['appointmentTime']);
              // Compare the current date with the target date
              if (currentDate.isBefore(targetDate)) {
                print('Today is before ');
                fetchedAppointments.add(Appointment(
                  id: appointment['_id'],
                  appointmentTime: appointment['appointmentTime'],
                  appointmentDate: appointment['appointmentDate'],
                  appointmentTimePeriod:
                      appointment['appointmentPeriod'].toString(),
                  doctorId: doctorId,
                  doctorName: doctorName,
                  doctorSpecialty: doctorSpecialty,
                ));
              } else if (currentDate.isAfter(targetDate)) {
                print('Today is on or after');
              }
            } else {
              fetchedAppointments.add(Appointment(
                id: appointment['_id'],
                appointmentTime: appointment['appointmentTime'],
                appointmentDate: appointment['appointmentDate'],
                appointmentTimePeriod:
                    appointment['appointmentPeriod'].toString(),
                doctorId: doctorId,
                doctorName: doctorName,
                doctorSpecialty: doctorSpecialty,
              ));
              print('equal');
            }
          } else {
            print('Error: Missing or invalid "doctor" property in response.');
          }
        } else {
          print(
              'Failed to fetch doctor details. Status code: ${doctorDetailsResponse.statusCode}');
        }
      }
      setState(() {
        appointments = fetchedAppointments;
      });

      print('User Appointments: $userAppointments');
    } else {
      print(
          'Failed to fetch user appointments. Status code: ${response.statusCode}');
    }
  }

  //   @override
  // void initState() {
  //   super.initState();
  //   //read user id from arguments
  //   Map<String, dynamic>? arguments =
  //       ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  //   userID = arguments?['userID'] ?? '';
  // }
  String emailUser = 'user@gmail.com';
String id_User='';
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
        emailUser = userData['email'];
        id_User =userData['id'];
      });
    } else {
      print('User data not found.');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Move the context-dependent initialization here
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userID = arguments?['userID'] ?? '';

    // Fetch user appointments
    fetchUserAppointment(userID);
    setState(() {
      loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          iconTheme: IconThemeData(color: customColor),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          backgroundColor: mainColor,
          title: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("HomePage");
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
        child: appointments.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(
                  top: 200,
                ),
                child: Center(
                  child: Text(
                    'No appointments available',
                    style: GoogleFonts.lora(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                        shadows: [
                          Shadow(
                            blurRadius: 8.0,
                            color: mainColor,
                            offset: Offset(
                                MediaQuery.of(context).size.width * 0.002, //0.1
                                MediaQuery.of(context).size.width *
                                    0.002), //0.1
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 20),
                    child: Center(
                      child: Text(
                        'Your all appointments',
                        style: GoogleFonts.lora(
                          textStyle: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: mainColor,
                            shadows: [
                              Shadow(
                                blurRadius: 8.0,
                                color: mainColor,
                                offset: Offset(
                                    MediaQuery.of(context).size.width *
                                        0.002, //0.1
                                    MediaQuery.of(context).size.width *
                                        0.002), //0.1
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          // surfaceTintColor: mainColor,
                          elevation: 5,
                          shadowColor: mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Container(
                            // width: 300, //width of each card
                            height: 180,
                            child: ListTile(
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final response =
                                          await Api.getdoctor(appointment.doctorId ?? '');
                                      String responseBody = response.body;
                                      if (responseBody.contains("doctor")) {
                                        responseBody = responseBody.replaceAll(
                                            "doctor", "user");
                                      }
                                      print("---------------------->>>>>>>> $responseBody");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UserEditAppointment(
                                                  doctorinfo: responseBody,
                                                  userid: id_User,
                                                  appoinmentid: appointment.id,
                                                )),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: mainColor,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                              title: Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 5),
                                child: Row(
                                  children: [
                                    Text(
                                      ' ${appointment.doctorName}',
                                      style: GoogleFonts.lora(
                                        textStyle: TextStyle(
                                            fontSize: 18,
                                            color: mainColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date: ${appointment.appointmentDate}',
                                    style: GoogleFonts.lora(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          // color: mainColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    'Time: ${appointment.appointmentTime}',
                                    style: GoogleFonts.lora(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          // color: mainColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    'Duration: ${appointment.appointmentTimePeriod}',
                                    style: GoogleFonts.lora(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          // color: mainColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .end, // Align items along the vertical (main) axis

                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            print("Dr profile tap");
                                            try {
                                              final response =
                                                  await Api.getdoctor(
                                                      appointment.doctorId ??
                                                          '');
                                              String responseBody =
                                                  response.body;
                                              if (responseBody
                                                  .contains("doctor")) {
                                                responseBody =
                                                    responseBody.replaceAll(
                                                        "doctor", "user");
                                              }
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return UserProfiledoc(
                                                  doctorinfo: responseBody,
                                                  userid: userID,
                                                );
                                              }));
                                            } catch (error) {
                                              print(
                                                  "Error in API call: $error");
                                              // Handle the error, e.g., show a message to the user
                                            }
                                          },
                                          child: Text(
                                            'veiw Dr profile?',
                                            style: GoogleFonts.italiana(
                                              textStyle: TextStyle(
                                                  // fontSize: 10,
                                                  color: mainColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            print("Dr profile tap");
                                            try {
                                              final response =
                                                  await Api.getdoctor(
                                                      appointment.doctorId ??
                                                          '');
                                              String responseBody =
                                                  response.body;
                                              if (responseBody
                                                  .contains("doctor")) {
                                                responseBody =
                                                    responseBody.replaceAll(
                                                        "doctor", "user");
                                              }
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return UserProfiledoc(
                                                  doctorinfo: responseBody,
                                                  userid: userID,
                                                );
                                              }));
                                            } catch (error) {
                                              print(
                                                  "Error in API call: $error");
                                              // Handle the error, e.g., show a message to the user
                                            }
                                          },
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            color: mainColor,
                                            size: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: mainColor,
                                    ),
                                    onPressed: () {
                                      AwesomeDialog(
                                        context: context,
                                        // dialogBorderRadius: BorderRadius.circular(5),
                                        dialogType: DialogType.question,
                                        animType: AnimType.scale,
                                        title: 'Delete Appointment',
                                        desc:
                                            'Are you sure you want to delete this appointment?',
                                        btnCancelOnPress: () {
                                          // Navigator.of(context).pop();
                                        },
                                        btnOkOnPress: () {
                                          String dateString =
                                              appointment.appointmentDate;
                                          DateTime date =
                                              DateTime.parse(dateString);
                                          List<String> daysOfWeek = [
                                            "Monday",
                                            "Tuesday",
                                            "Wednesday",
                                            "Thursday",
                                            "Friday",
                                            "Saturday",
                                            "Sunday"
                                          ];
                                          // Get the day of the week
                                          String selectday =
                                              daysOfWeek[date.weekday - 1];
                                          print(
                                              "Your appointment with ${appointment.doctorName} is on ${selectday} at ${appointment.appointmentDate} ${appointment.appointmentTime}");
                                          print(emailUser);

                                          FirebaseFirestore.instance
                                              .collection('notifications')
                                              .where('content',
                                                  isEqualTo:
                                                      "Your appointment with ${appointment.doctorName} is on ${selectday} at ${appointment.appointmentDate} ${appointment.appointmentTime}")
                                              .where('title',
                                                  isEqualTo:
                                                      "Reminder you have an appointment after a few minutes")
                                              .where('useremail',
                                                  isEqualTo: emailUser)
                                              .where('onTime', isEqualTo: false)
                                              .get()
                                              .then((QuerySnapshot
                                                  querySnapshot) {
                                            querySnapshot.docs.forEach((doc) {
                                              doc.reference.delete().then((_) {
                                                print(
                                                    'Document successfully deleted');
                                              }).catchError((error) {
                                                print(
                                                    'Error deleting document: $error');
                                              });
                                            });
                                          }).catchError((error) {
                                            print(
                                                'Error getting documents: $error');
                                          });
                                          deleteAppointmentlist(appointment.id);
                                          // Navigator.of(context).pop();
                                        },
                                        btnCancelColor:
                                            Color.fromARGB(255, 32, 87, 97),
                                        btnOkColor:
                                            Color.fromARGB(255, 56, 154, 171),
                                        descTextStyle: TextStyle(
                                            color: Color.fromARGB(
                                                255, 32, 87, 97)),

                                        // titleTextStyle: TextStyle(color: Color.fromARGB(255, 32, 87, 97))
                                      )..show();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
