import 'dart:math';

class LatLngClass {
  final double latitude;
  final double longitude;

  LatLngClass(this.latitude, this.longitude);
    @override
  String toString() {
    return 'LatLngClass(latitude: $latitude, longitude: $longitude)';
  }
}

double calculateDistance(LatLngClass userLocation, LatLngClass destination) {
  const double earthRadius = 6371; // Radius of the Earth in kilometers

  double lat1 = userLocation.latitude;
  double lon1 = userLocation.longitude;
  double lat2 = destination.latitude;
  double lon2 = destination.longitude;

  double dLat = (lat2 - lat1) * (pi / 180);
  double dLon = (lon2 - lon1) * (pi / 180);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) * sin(dLon / 2) * sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c; // Distance in kilometers
}

List<LatLngClass> findNearestLocations(List<List<double>> locations, LatLngClass userLocation, double maxDistance) {
  List<LatLngClass> nearestLocations = [];

  for (List<double> location in locations) {
    LatLngClass doctorLocation = LatLngClass(location[0], location[1]);
    double distance = calculateDistance(userLocation, doctorLocation);
    print("Distance = $distance");
    if (distance <= maxDistance) {
      nearestLocations.add(doctorLocation);
    }
  }

  return nearestLocations;
}

/* void main() {
  List<List<double>> doctorLocations = [
    [37.7749, -122.4194], // Example doctor location 1
    [34.0522, -118.2437], // Example doctor location 2
    // Add more doctor locations as needed
  ];

  LatLngClass userLocation = LatLngClass(37.7749, -122.4194); // Example user location

  double maxDistance = 10.0; // Set your maximum distance threshold in kilometers

  List<LatLngClass> nearestLocations = findNearestLocations(doctorLocations, userLocation, maxDistance);

  print('Nearest doctor locations within $maxDistance km: $nearestLocations');
} */
