import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:untitled/Profile/editappointment.dart';

class Api {
  static const String baseUrl =
      'http://10.0.2.2:8081'; // Replace with your server URL

  static Future<http.Response> login(Map data) async {
    final String url = '$baseUrl/doctors/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Set the content type
        body: jsonEncode(data), // Encode the body as JSON
      );

      print("username password $data");
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> adddoctorrequest(Map data) async {
    final String url = '$baseUrl/doctorrequests';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Set the content type
        body: jsonEncode(data), // Encode the body as JSON
      );

      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> editinfo(Map data, String id) async {
    final String url = '$baseUrl/doctors/$id';
    print('URL------->' + url);
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Set the content type
        body: jsonEncode(data), // Encode the body as JSON
      );

      print("username password $data");
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> editAppointment(Map data, String id) async {
    final String url = '$baseUrl/editappointment/$id';
    print('URL------->' + url);
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Set the content type
        body: jsonEncode(data), // Encode the body as JSON
      );

      print("username password $data");
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> edituserinfo(Map data, String id) async {
    final String url = '$baseUrl/users/$id';
    print('URL------->' + url);
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Set the content type
        body: jsonEncode(data), // Encode the body as JSON
      );

      print("username password $data");
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> getlocation(String id) async {
    final String url = '$baseUrl/doctors/$id/location';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> editlocation(Map data, String id) async {
    final String url = '$baseUrl/doctors/$id/location';
    print('URL------->' + url);
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Set the content type
        body: jsonEncode(data), // Encode the body as JSON
      );

      print("username password $data");
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  /**admin */
    static Future<http.Response> getAdmins() async {
    final String url = '$baseUrl/admins';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return response;
    } catch (e) {
      // Handle network and other errors
      throw e;
    }
  }

  static Future<http.Response> getdoctor(String id) async {
    final String url = '$baseUrl/doctors/$id';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> getdoctors() async {
    final String url = '$baseUrl/doctors';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<String> getcategory(String id) async {
    final String url = '$baseUrl/categories/$id';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return json.decode(response.body)['categ']['name'];
      ;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  /***********************mira*************category****** */
/***********************category to return doctors in the same category********************************/

static Future<http.Response> getDoctorsByCategory(String categoryId) async {
    final String url = '$baseUrl/doctors/category/$categoryId';

    try {
      final response = await http.get(Uri.parse(url));

      return response;
    } catch (e) {
      throw e;
    }
  }

  /****************************************** */

  // static Future<http.Response> addrate(
  //     String userid, String doctorid, int value) async {
  //   final String url = '$baseUrl/rating/$userid/$doctorid';
  //   print('URL------->' + url);
  //   var body = {"value": value};
  //   print(body);
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {"Content-Type": "application/json"}, // Set the content type
  //       body: jsonEncode(body),
  //     );
  //     return response;
  //   } catch (e) {
  //     // Handle network and other errors
  //     print("ERRORR---->$e");
  //     throw e;
  //   }
  // }
  /**mira edit  */
  static Future<http.Response> addrate(
    String userid,
    String doctorid,
    int value,
    String comment, // Add the comment parameter
  ) async {
    final String url = '$baseUrl/rating/$userid/$doctorid';
    print('URL------->' + url);

    // Include the comment in the request body
    var body = {"value": value, "comment": comment};
    print(body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      // Handle network and other errors
      print("ERRORR---->$e");
      throw e;
    }
  }

  static Future<http.Response> getuserbyid(String id) async {
    final String url = '$baseUrl/users/$id';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  Future<List<http.Response>> fetchRatingsForDoctor(String doctorId) async {
    final String url = '$baseUrl/ratings/$doctorId';
    try {
      final response = await http.get(Uri.parse(url));
      print('Raw API Response: ${response.body}'); // Print the raw response

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((ratingJson) {
          // Sanitize the comment field to remove invalid characters
          var sanitizedComment =
              ratingJson['comment'].replaceAll(RegExp(r'[^\x00-\x7F]'), '');

          // Update the mapping of the doctor field based on the actual structure
          var modifiedRatingJson = {
            ...ratingJson,
            'doctor': ratingJson['doctor'] != null
                ? ratingJson['doctor'].toString()
                : null,
            'comment': sanitizedComment,
          };

          return http.Response(
              json.encode(modifiedRatingJson), response.statusCode);
        }).toList();
      } else {
        throw 'Failed to load ratings';
      }
    } catch (e) {
      throw e;
    }
  }

/*******************************delete rating from reviwe************* */
  static Future<void> deleteRating(String ratingId) async {
    final String url = '$baseUrl/rating/$ratingId';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Rating deleted successfully');
      } else {
        throw 'Failed to delete rating';
      }
    } catch (e) {
      throw e;
    }
  }

/****************************** */
  static Future<http.Response> addapointment(
      Map data, String userid, String doctorid) async {
    final String url = '$baseUrl/appointment/$userid/$doctorid';
    print('URL------->' + url);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Set the content type
        body: jsonEncode(data), // Encode the body as JSON
      );

      print("Time and date ---> $data");
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  // /appointment/getTimes/:doctorid
  static Future<http.Response> timesapointment(
      Map data, String userid, String doctorid) async {
    final String url = '$baseUrl/getTimes/$doctorid';
    print('URL------->' + url);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Set the content type
        body: jsonEncode(data), // Encode the body as JSON
      );

      print("Time and date ---> $data");
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> isaalowed(String userid, String doctorid) async {
    final String url = '$baseUrl/appointment/isallowed/$userid/$doctorid';
    print('URL------->' + url);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> getdoctorappointment(String doctorid) async {
    final String url = '$baseUrl/appointment/$doctorid';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> deleteppointmentbyid(String appid) async {
    final String url = '$baseUrl/appointment/deletebyid/$appid';
    print('URL------->' + url);
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<String> getusername(String id) async {
    final String url = '$baseUrl/getusername/$id';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return json.decode(response.body);
      ;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<String> getuseremail(String id) async {
    final String url = '$baseUrl/getuseremail/$id';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return json.decode(response.body);
      ;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<String> getusertoken(String id) async {
    final String url = '$baseUrl/getusertoken/$id';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return json.decode(response.body);
      ;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<Map<String, dynamic>> getlocationsbycategory(String id) async {
    final String url = '$baseUrl/doctorslocation/$id';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return json.decode(response.body);
      ;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<Map<String, dynamic>> getLocations() async {
    final String url = '$baseUrl/doctorslocation';
    print('URL------->' + url);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {}
      return json.decode(response.body);
    } catch (e) {
      // Handle network and other errors
      throw e;
    }
  }

// miraa
// BookedAppointment to get appointment by user id :
  static Future<http.Response> fetchUserAppointments(String userId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/appointments/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> userAppointments = json.decode(response.body);
        print('User Appointments: $userAppointments');
      } else {
        print(
            'Failed to fetch user appointments. Status code: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  static Future<http.Response> fetchDoctorDetails(String doctorId) async {
    final String url = '$baseUrl/doctors/$doctorId';

    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return response;
    } catch (e) {
      // Handle network and other errors
      throw e;
    }
  }

  static Future<http.Response> deleteAppointment(String appointmentId) async {
    final String url = '$baseUrl/appointments/$appointmentId';
    try {
      final response = await http.delete(
        Uri.parse(url),
      );
      return response;
    } catch (e) {
      // Handle network and other errors
      throw e;
    }
  }

  static Future<http.Response> getNotification(String useremail) async {
    final String url = '$baseUrl/Notification/$useremail';
    print('URL------->' + url);

    try {
      final response = await http.get(Uri.parse(url));

      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> getNotificationUnread(String useremail) async {
    final String url = '$baseUrl/NotificationUnread/$useremail';
    print('URL------->' + url);

    try {
      final response = await http.get(Uri.parse(url));

      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }
//get doctors details by id for BookedAppointments page :

//////////////////////////////////////////get all users
  static Future<http.Response> getUsers() async {
    final String url = '$baseUrl/users';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return response;
    } catch (e) {
      // Handle network and other errors
      throw e;
    }
  }

  /*************************************STREAM***************************************/
  static Stream<List<Map<String, dynamic>>> streamNotifications(
      String userEmail) {
    try {
      return FirebaseFirestore.instance
          .collection('notifications')
          .where('useremail', isEqualTo: userEmail)
          .where('onTime', isEqualTo: true)
          .snapshots()
          .map((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        return querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print("Error streaming notifications: $e");
      return Stream.value([]); // Return an empty stream in case of an error
    }
  }

  static Stream<int> streamUnreadNotificationCount(String userEmail) {
    try {
      return FirebaseFirestore.instance
          .collection('notifications')
          .where('useremail', isEqualTo: userEmail)
          .where('read', isEqualTo: false)
          .where('onTime', isEqualTo: true)
          .snapshots()
          .map((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        return querySnapshot.size;
      });
    } catch (e) {
      print("Error streaming unread on-time notification count: $e");
      return Stream.value(0); // Return 0 in case of an error
    }
  }

  static Future<void> markAllNotificationsAsRead(String userEmail) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('notifications')
              .where('useremail', isEqualTo: userEmail)
              .where('read', isEqualTo: false)
              .where('onTime', isEqualTo: true)
              .get();

      List<DocumentReference> documentsToUpdate = [];

      querySnapshot.docs.forEach((doc) {
        documentsToUpdate.add(doc.reference);
      });

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (DocumentReference document in documentsToUpdate) {
        batch.update(document, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      print("Error marking all notifications as read: $e");
    }
  }

  static Stream<void> streamUpdateOnTimeField() {
    try {
      // Create a stream that emits an event every minute
      Stream<void> periodicStream =
          Stream.periodic(Duration(minutes: 1), (value) => value);

      return periodicStream.asyncMap((_) async {
        try {
          QuerySnapshot<Map<String, dynamic>> querySnapshot =
              await FirebaseFirestore.instance
                  .collection('notifications')
                  .where('onTime', isEqualTo: false)
                  .get();

          List<DocumentReference> documentsToUpdate = [];

          querySnapshot.docs.forEach((doc) {
            Timestamp timestamp = doc[
                'dateTime']; // Assuming 'dateTime' is the field representing the time
            DateTime notificationTime = timestamp.toDate();

            if (notificationTime.isBefore(DateTime.now())) {
              documentsToUpdate.add(doc.reference);
            }
          });

          WriteBatch batch = FirebaseFirestore.instance.batch();

          for (DocumentReference document in documentsToUpdate) {
            batch.update(document, {'onTime': true});
          }

          await batch.commit();
        } catch (e) {
          print("Error in asyncMap: $e");
        }
      });
    } catch (e) {
      print("Error streaming update onTime field: $e");
      return Stream.value(null); // Return null in case of an error
    }
  }

  //*******Token "FCM" *//changeFCMuser/:id
  static Future<http.Response> changeFCMuser(Map data, String id) async {
    final String url = '$baseUrl/changeFCMuser/$id';
    print('URL------->' + url);
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Set the content type
        body: jsonEncode(data), // Encode the body as JSON
      );

      // print("username password $data");
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> changeFCMdoctor(Map data, String id) async {
    final String url = '$baseUrl/changeFCMdoctor/$id';
    print('URL------->' + url);
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Set the content type
        body: jsonEncode(data), // Encode the body as JSON
      );

      //  print("username password $data");
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }
  ///////////////////////////////posts ////////////////////
  
  static Future<http.Response> getposts() async {
    final String url = '$baseUrl/posts';
    print('URL------->' + url);
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      return response;
    } catch (e) {
      // Handle network and other errors

      throw e;
    }
  }

  static Future<http.Response> addPost(Map<String, dynamic> data) async {
    final String url = '$baseUrl/posts';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // Set the content type
        body: jsonEncode(data), // Encode the body as JSON
      );

      return response;
    } catch (e) {
      // Handle network and other errors
      throw e;
    }
  }

  
}
