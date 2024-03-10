import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class U_position extends StatelessWidget {
  final String doctorinf;
  U_position({required this.doctorinf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.red,
              size: 30,
            ),
            Text(
              '  Dental Clinic Location',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Color(0xFF389AAB),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: MapSample(id: doctorinf),
    );
  }
}

class MapSample extends StatefulWidget {
  final String id;

  MapSample({required this.id});
  @override
  State<MapSample> createState() => MapSampleState(id: id);
}

class MapSampleState extends State<MapSample> {
  final String id;

  MapSampleState({required this.id});
  late GoogleMapController mapController;
  LatLng myMarkerPosition = LatLng(0, 0);

  //get responseMap => null; // Initial marker position
  String name = 'Aseel';
  @override
  void initState() {
    super.initState();
    print(
        "LOCATION****************************************************************");
    setState(() {
      print(jsonDecode(id));
      Map<String, dynamic> responseMap = json.decode(id);
      print(responseMap);
      List<double> locationMap =
          List<double>.from(responseMap['doctor']["locationMap"]);
      name = responseMap['doctor']["name"];
      print(responseMap['doctor']["locationMap"]);
      print(responseMap['doctor']["name"]);

      //parsedJson2['doctor']['name'];
      //Map<String, dynamic> parsedJson2 = json.decode(id);

      double latitude = locationMap[0]; // 32.22219
      double longitude = locationMap[1]; // 35.262191
      myMarkerPosition = LatLng(latitude, longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target:
            myMarkerPosition, // Use the myMarkerPosition as the initial position
        zoom: 12,
      ),
      markers: {
        Marker(
          markerId: MarkerId('myMarker'),
          position: myMarkerPosition,
          infoWindow: InfoWindow(title: name, snippet: 'Dental Clinic'),
          onTap: () {
            // Handle marker tap here if needed
          },
        ),
      },
      onTap: (LatLng position) async {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          String? city = placemarks[0].locality; // Get the city name
          print('Clicked on: $city in position $position');
        } else {
          print('City name not found');
        }
        setState(() {
          myMarkerPosition = position;
        });
      },
    );
  }
}
