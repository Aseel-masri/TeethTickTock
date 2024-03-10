import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:untitled/servicies/api.dart';

class PositionMap extends StatelessWidget {
  final String id;
  final String flag;
  PositionMap({required this.id, required this.flag});

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
            Text('  Dental Clinic Location'),
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
      body: MapSample(
        id: id,
        flag: flag,
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  final String id;
  final String flag;

  MapSample({required this.id, required this.flag});
  @override
  State<MapSample> createState() => MapSampleState(
        id: id,
        flag: flag,
      );
}

class MapSampleState extends State<MapSample> {
  final String id;
  final String flag;

  MapSampleState({required this.id, required this.flag});
  late GoogleMapController mapController;
  LatLng myMarkerPosition = LatLng(0, 0);

  //get responseMap => null; // Initial marker position
  String name = 'Aseel';
  late Position currentLocation;
  Future<Position> _getLongLat() async {
    var pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lastMsg = await Geolocator.getLastKnownPosition();
    print("getLastKnownPosition $lastMsg");

    return pos;
    // return await Geolocator.getCurrentPosition().then((value) => value);
  }

  Future _getLocation() async {
    bool service;
    var per;
    try {
      service = await Geolocator.isLocationServiceEnabled();
      print("Aseel1");
      if (service == false) {
        print("Aseel2.1");
        AwesomeDialog(
            context: context,
            title: 'service',
            body: Text("Service Not Enabled"))
          ..show();
      }
      print("Aseel2.2");
      per = await Geolocator.checkPermission();
      print("Aseel3");
      // LocationPermission permission = await Geolocator.requestPermission();

      if (per == LocationPermission.denied) {
        // throw 'Location permissions are denied.';
        per = await Geolocator.requestPermission();
        print("Aseel4.1");
      }
      if (per == LocationPermission.always) {
        print("Aseel4.2");
      }
      print("Aseel4.3");
      currentLocation = await _getLongLat();
      print("Aseel4.3");
      print("Latitude: ${currentLocation.latitude}");
      print("Longitude: ${currentLocation.longitude}");
      setState(() {
        var data = {
          "locationMap": [currentLocation.latitude, currentLocation.longitude],
        };
        editLocation(data);
        myMarkerPosition =
            LatLng(currentLocation.latitude, currentLocation.longitude);
      });
      //  Position position = await Geolocator.getCurrentPosition().then((value) => value);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

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
      if (flag == "edit") {
        initializeData();
      }
    });
  }

  Future<void> editLocation(var data) async {
    Map<String, dynamic> responseMap = json.decode(id);

    final response = await Api.editlocation(data, responseMap['doctor']['_id']);
    print("Response Current Map--> ${response.statusCode}");
  }

  void initializeData() async {
    await _getLocation();
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
