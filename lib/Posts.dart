import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:untitled/servicies/api.dart';

class Post {
  final String doctorName;
  final String doctorProfileImg;
  final String postContent;

  Post({
    required this.doctorName,
    required this.doctorProfileImg,
    required this.postContent,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      doctorName: json['doctorName'],
      doctorProfileImg: json['doctorProfileImg'],
      postContent: json['postContent'],
    );
  }
}

class Posts extends StatefulWidget {
  const Posts({Key? key}) : super(key: key);

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  late List<Post> posts = [];
  TextEditingController postContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final http.Response response = await Api.getposts();
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          posts = data.map((json) => Post.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (error) {
      print('Error fetching posts: $error');
    }
  }

  Future<void> addPost() async {
    try {
      // Make a POST request to add a new post
      final http.Response response = await Api.addPost({
        "doctorId": "123", // Replace with the actual doctorId
        "doctorName": "Dr. John Doe", // Replace with the actual doctorName
        "doctorProfileImg":
            "pic165add0ba6c78193fcc424801.png", // Replace with the actual profileImg
        "postContent": postContentController.text,
      });

      if (response.statusCode == 201) {
        // Post added successfully, refresh the list
        fetchPosts();
        // Clear the text field
        postContentController.clear();
      } else {
        throw Exception('Failed to add post');
      }
    } catch (error) {
      print('Error adding post: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Latest Posts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: posts.isNotEmpty
                ? ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(posts[index].doctorName),
                        subtitle: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(posts[index].postContent),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(posts[index]
                                  .doctorProfileImg ??
                              'https://upload.wikimedia.org/wikipedia/commons/6/67/User_Avatar.png'),
                        ),
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a New Post',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: postContentController,
                  decoration: InputDecoration(
                    hintText: 'Enter your post content',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: addPost,
                  child: Text('Add Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
