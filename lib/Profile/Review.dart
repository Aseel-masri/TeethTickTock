import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:untitled/MessagesUserList.dart';
import 'package:untitled/servicies/api.dart';

/**********************************local storage*************************** */

final LocalStorage storage = new LocalStorage('my_data');

class Review extends StatefulWidget {
  const Review({Key? key}) : super(key: key);

  @override
  State<Review> createState() => _ReviewState();
}

String doctorID = "";
String localUserID = '1';

class _ReviewState extends State<Review> {
  final Api api = Api();
  final List<Map<String, dynamic>> ratingsList = [];
  bool isLoading = true;
  Map<String, dynamic>? getUserData() {
    return storage.getItem('user_data_new');
  }

  void loadUserData() {
    Map<String, dynamic>? userData = getUserData();

    if (userData != null) {
      setState(() {
        localUserID = userData['id'] ?? '';
      });
      print('ID: ${userData['id']}');
    } else {
      print('User data not found.');
    }
  }

  Future<void> fetchData() async {
    try {
      if (doctorID.isNotEmpty) {
        final res = await api.fetchRatingsForDoctor(doctorID);

        for (var response in res) {
          if (response.statusCode == 200) {
            var ratingJson = json.decode(response.body);
            String userId = ratingJson["user"];

            final userRes = await Api.getuserbyid(userId);
            if (userRes.statusCode == 200) {
              var userJson = json.decode(userRes.body);
              String userName = userJson["name"];
              String userImage = "http://10.0.2.2:8081/profileimg/" +userJson["ProfileImg"];
              print(ratingJson["_id"]);
              print("\n");
              ratingsList.add({
                'ratingID': ratingJson["_id"],
                'value': ratingJson["value"],
                'comment': ratingJson["comment"],
                'userId': userId,
                'userName': userName,
                'userImage': userImage,
              });
            } else {
              print(
                  'Failed to fetch user details. Status Code: ${userRes.statusCode}');
              print('Response Body: ${userRes.body}');
            }
          } else {
            print(
                'Failed to fetch a rating. Status Code: ${response.statusCode}');
            print('Response Body: ${response.body}');
          }
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching ratings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteRating(String ratingId) async {
    try {
      await Api.deleteRating(ratingId);

      setState(() {
        ratingsList.removeWhere((rating) => rating['ratingID'] == ratingId);
      });
    } catch (e) {
      print('Error deleting rating: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    doctorID = arguments?['doctorId'] ?? '';
    fetchData();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: customColor),
        backgroundColor: mainColor,
        title: Text(
          "Reviews",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close_sharp),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ratingsList.isEmpty
                ? Center(
                    child: Text(
                      'No reviews available.',
                      style: TextStyle(
                          fontSize: 20,
                          color: mainColor,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.separated(
                    itemCount: ratingsList.length,
                    itemBuilder: (context, index) {
                      var rating = ratingsList[index];
                      return CommentWidget(
                        value: rating['value'],
                        comment: rating['comment'],
                        userId: rating['userId'],
                        userName: rating["userName"],
                        image: rating["userImage"],
                        onDelete: () => deleteRating(rating['ratingID']),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                      color: mainColor,
                    ),
                  ),
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {
  final int value;
  final String comment;
  final String userId;
  final String userName;
  final String image;
  final Function onDelete;

  CommentWidget({
    required this.value,
    required this.comment,
    required this.userId,
    required this.userName,
    required this.image,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(image),
                radius: 26.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: mainColor,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 7),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(Icons.star,
                            size: 23,
                            color:
                                index < value ? Colors.yellow : Colors.black26),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      comment,
                      style: TextStyle(fontSize: 14),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              if (userId == localUserID)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    onPressed: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.question,
                        animType: AnimType.scale,
                        title: 'Delete Review',
                        desc: 'Are you sure you want to delete this Review?',
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {
                          onDelete();
                        },
                        btnCancelColor: Color.fromARGB(255, 32, 87, 97),
                        btnOkColor: Color.fromARGB(255, 56, 154, 171),
                        descTextStyle:
                            TextStyle(color: Color.fromARGB(255, 32, 87, 97)),
                      )..show();
                    },
                    icon: Icon(
                      Icons.delete,
                      size: 25,
                    ),
                    color: mainColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
