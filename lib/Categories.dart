import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);
  List specialtyList = [
    {
      "specialtyTitle": "Cosmetic dentist",
      "image": "Cosmetic dentist.jpg",
      "id": "653b617fb20a7b29931645cb"
    },
    {
      "specialtyTitle": "Pediatric dentist",
      "image": "Pediatric dentist.jpg",
      "id": "6543e16a3336dafe8f42c252"
    },
    {
      "specialtyTitle": "Dental neurologist",
      "image": "Dental neurologist.jpg",
      "id": "6543e16a3336dafe8f42c253"
    },
    {
      "specialtyTitle": "Dental Surgeon",
      "image": "doctors3.jpg",
      "id": "653b617fb20a7b29931645cc"
    },
    {
      "specialtyTitle": "Orthodontist",
      "image": "Orthodontist.jpg",
      "id": "6543e16a3336dafe8f42c254"
    },
  ];

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
        // color: Colors.white,
        child: ListView.builder(
          itemCount: specialtyList.length,
          itemBuilder: (context, i) {
            return Container(
              height: 160,
              margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/${specialtyList[i]["image"]}'),
                    fit: BoxFit.cover,
                    opacity: 0.3),
              ),
              child: ListTile(
                splashColor: mainColor,
                tileColor: Color.fromARGB(213, 20, 19, 19),
                title: Center(
                  child: Text(
                    '${specialtyList[i]['specialtyTitle']}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  try {
                    Navigator.pushNamed(
                      context,
                      'Specialty',
                      arguments: {
                        'specialtyTitle': specialtyList[i]['specialtyTitle'],
                        'image': specialtyList[i]['image'],
                        'id': specialtyList[i]['id'],
                        // Add other data you want to pass here
                      },
                    );
                  } catch (e) {
                    print('Error: $e');
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
