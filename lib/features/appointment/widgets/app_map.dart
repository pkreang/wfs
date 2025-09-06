import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppMap extends StatefulWidget {
  final double? lat;
  final double? lng;

  const AppMap({required this.lat, required this.lng, super.key});

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latitude = widget.lat;
    final longitude = widget.lng;

    if (latitude == null || longitude == null) return const SizedBox.shrink();

    final pos = CameraPosition(target: LatLng(latitude, longitude), zoom: 16);

    final markers = <Marker>{Marker(markerId: const MarkerId('target'), position: LatLng(latitude, longitude), infoWindow: const InfoWindow(title: 'ตำแหน่งของคุณ'))};

    return Container(
      width: 352,
      height: 225,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 32)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // คงที่ = ถูกสุด
        child: GoogleMap(
          initialCameraPosition: pos,
          onMapCreated: (c) => _controller = c,
          markers: markers,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: false,
        ),
      ),
    );
  }
}
