import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class Globals {}

double globallatitude = 10.0;
double globallongitude = 10.0;

class Current_position extends StatelessWidget {
  Current_position();

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
      body: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  MapSample();
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;
  LatLng myMarkerPosition = LatLng(32.222177, 35.262202);
  //LatLng myMarkerPosition = LatLng(37.42342342342342, 122.08395287867832);

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
        globallatitude = currentLocation.latitude;
        globallongitude = currentLocation.longitude;
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
    initializeData(); // Call the asynchronous function outside setState
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
        zoom: 13,
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
          globallatitude = position.latitude;
          globallongitude = position.longitude;
          myMarkerPosition = position;
        });
      },
    );
  }
}
