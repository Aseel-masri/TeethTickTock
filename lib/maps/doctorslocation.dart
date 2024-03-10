import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:untitled/model/doctor.dart';
import 'package:untitled/maps/nearest.dart';

class Doc_locations extends StatelessWidget {
  final List doctor_category;
  Doc_locations({required this.doctor_category});

  @override
  Widget build(BuildContext context) {
    Color customColor = const Color(0xFFBBF1FA);
    Color mainColor = const Color(0xFF389AAB);
    Color footerColor = Color(0xFF2D3E50);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: customColor),
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
      body: MapSample(id: doctor_category),
    );
  }
}

class MapSample extends StatefulWidget {
  final List id;

  MapSample({required this.id});
  @override
  State<MapSample> createState() => MapSampleState(doctors_loc: id);
}

class MapSampleState extends State<MapSample> {
  final List doctors_loc;

  MapSampleState({required this.doctors_loc});
  late GoogleMapController mapController;
  List<LatLng> myMarkerPosition = [LatLng(0, 0)];

  //get responseMap => null; // Initial marker position
  List<String> name = ['Aseel'];
  List<List<double>> doctorLocations = [];
  @override
  void initState() {
    super.initState();
    print(
        "LOCATION****************************************************************");
    setState(() {
      var temp_loc;
      myMarkerPosition.clear();
      name.clear();
      for (int i = 0; i < doctors_loc.length; i++) {
        double latitude = doctors_loc[i]['locationMap']?[0]; // 32.22219
        double longitude = doctors_loc[i]['locationMap']?[1];
        doctorLocations.add([latitude, longitude]);
        temp_loc = LatLng(latitude, longitude);
        myMarkerPosition.add(temp_loc);
        name.add(doctors_loc[i]['name']!);
      }
      /*      List<List<double>> doctorLocations = [
        [37.7749, -122.4194], // Example doctor location 1
        [34.0522, -118.2437], // Example doctor location 2
        // Add more doctor locations as needed
      ]; */

      LatLngClass userLocation =
          LatLngClass(31.948595, 35.170874); // Example user location
// LatLngClass(37.4219983, -122.084);
      double maxDistance =
          32.0; // Set your maximum distance threshold in kilometers

      List<LatLngClass> nearestLocations =
          findNearestLocations(doctorLocations, userLocation, maxDistance);

      print(
          'Nearest doctor locations within $maxDistance km: $nearestLocations');
    });
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = Set();

    for (int i = 0; i < myMarkerPosition.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('myMarker$i'),
          position: myMarkerPosition[i],
          infoWindow: InfoWindow(
            title: name[i],
            snippet: 'Dental Clinic',
          ),
          /* icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ), */ 
          onTap: () {},
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: myMarkerPosition[
            0], // Use the myMarkerPosition as the initial position
        zoom: 12,
      ),
      markers: _createMarkers()
      /*  {
        Marker(
          markerId: MarkerId('myMarker'),
          position: myMarkerPosition,
          infoWindow: InfoWindow(title: name, snippet: 'Dental Clinic'),
          onTap: () {
            // Handle marker tap here if needed
          },
        ),
      } */
      ,
      onTap: (LatLng position) async {},
    );
  }
}
