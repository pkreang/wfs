import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus { granted, denied, deniedForever, servicesOff }

class LocationService {
  Future<LocationPermissionStatus> requestPermission({bool requestIfDenied = true}) async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationPermissionStatus.servicesOff;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestIfDenied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) return LocationPermissionStatus.granted;
    if (permission == LocationPermission.deniedForever) return LocationPermissionStatus.deniedForever;

    return LocationPermissionStatus.denied;
  }

  Future<Position> getPosition() {
    final pos = Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));

    print('position: $pos');

    return pos;
  }

  Future reverseGeocodeGoogle(double latitude, double longitude) async {}
}
