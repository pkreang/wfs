import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

enum LocationPermissionStatus { granted, denied, deniedForever, servicesOff }

class LocationService {
  static String mapApiKey = "";

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

    return pos;
  }

  Future<String?> reverseGeocodeGoogle(double lat, double lng) async {
    final q = {'latlng': '$lat,$lng', 'language': 'th', 'key': mapApiKey};

    final res = await http.get(Uri.https('maps.googleapis.com', '/maps/api/geocode/json', q));
    if (res.statusCode != 200) return null;

    final m = jsonDecode(res.body) as Map<String, dynamic>;
    if (m['status'] != 'OK') return null;

    final results = (m['results'] as List).cast<Map<String, dynamic>>();
    if (results.isEmpty) return null;

    String? pickByTypes(List<Map<String, dynamic>> rs, List<String> types) {
      for (final r in rs) {
        final t = (r['types'] as List).cast<String>();
        if (t.any(types.contains)) {
          final addr = r['formatted_address'] as String?;
          if (addr != null && !RegExp(r'^\S+\+\S+').hasMatch(addr)) return addr;
        }
      }
      return null;
    }

    final street = pickByTypes(results, const ['street_address', 'premise', 'subpremise', 'route', 'intersection']);
    if (street != null) return street;

    final area = pickByTypes(results, const ['sublocality', 'locality', 'administrative_area_level_2', 'administrative_area_level_1']);
    if (area != null) return area;

    final compound = (m['plus_code'] as Map?)?['compound_code'] as String?;
    return compound?.replaceFirst(RegExp(r'^\S+\s+'), '').trim();
  }
}
