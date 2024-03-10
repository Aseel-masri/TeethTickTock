import 'package:flutter/material.dart';

class Quickconsultation extends StatefulWidget {
  @override
  _QuickconsultationState createState() => _QuickconsultationState();
}

class _QuickconsultationState extends State<Quickconsultation> {
  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);

  TextEditingController _numberController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  int numberOfTeeth = 1;

  void incrementTeeth() {
    setState(() {
      if (numberOfTeeth < 30) {
        numberOfTeeth++;
        _numberController.text = numberOfTeeth.toString();
      }
    });
  }

  void decrementTeeth() {
    setState(() {
      if (numberOfTeeth > 1) {
        numberOfTeeth--;
        _numberController.text = numberOfTeeth.toString();
      }
    });
  }

  // @override
  // void dispose() {
  //   _numberController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back), // Use the back arrow icon
              onPressed: () {
                Navigator.of(context).pop(); // This will navigate back
              },
            ),
            centerTitle: true,
            backgroundColor: mainColor,
            title: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("HomePage");
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'images/teethQuestion.png',
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 25, left: 5, right: 5, bottom: 10),
                  child: Text(
                    "Enter the tooth number you want to ask about",
                    style: TextStyle(
                        color: mainColor,
                        fontSize: 23,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        splashColor: mainColor,
                        color: mainColor,
                        icon: Icon(Icons.remove),
                        onPressed: decrementTeeth,
                      ),
                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Tooth number',
                            labelStyle:
                                TextStyle(color: mainColor), // Text color
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color:
                                      mainColor), // Border color when focused
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color:
                                      mainColor), // Border color when not focused
                            ),
                          ),
                          controller: _numberController,
                        ),
                      ),
                      IconButton(
                        splashColor: mainColor,
                        color: mainColor,
                        icon: Icon(Icons.add),
                        onPressed: incrementTeeth,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 25, left: 5, right: 5, bottom: 10),
                  child: Text(
                    "Add a note to help the doctor evaluate the condition",
                    style: TextStyle(
                        color: mainColor,
                        fontSize: 23,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                // Text("Add a note to help the doctor evaluate the condition"),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 20,
                    right: 20,
                    bottom: 10,
                  ),
                  child: TextField(
                    maxLines: 10, // Set the desired number of lines (rows)
                    minLines: 1, // Set the minimum number of lines (rows)
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Add your consultation',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              mainColor, // Set your desired border color here
                          width: 2.0, // Set the border width
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  width: 150, // Set your desired width
                  height: 50, // Set your desired height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: mainColor,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      print("Number of Teeth: ${_numberController.text}");
                      print("User Note: ${_noteController.text}");
                    },
                    style: ElevatedButton.styleFrom(
                      primary: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'send',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )

                // ElevatedButton(
                //   onPressed: () {
                //     print("Number of Teeth: ${_numberController.text}");
                //     print("User Note: ${_noteController.text}");
                //   },
                //   child: Text('Consultation Form'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
