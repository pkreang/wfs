import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wfs/utility/app_utility.dart';

class AppMap extends StatefulWidget {
  final double? lat;
  final double? lng;

  const AppMap({required this.lat, required this.lng, super.key});

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  GoogleMapController? _controller;
  bool _mapLoaded = false;

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

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('target'),
        position: LatLng(latitude, longitude),
        infoWindow: const InfoWindow(title: 'ตำแหน่งของคุณ'),
      ),
    };

    return Container(
      width: 352,
      height: 225,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 32)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // คงที่ = ถูกสุด
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: pos,
              onMapCreated: (c) {
                _controller = c;
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted && !_mapLoaded) setState(() => _mapLoaded = true);
                });
              },
              onCameraIdle: () {
                if (!_mapLoaded && mounted) setState(() => _mapLoaded = true);
              },
              markers: markers,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: false,
            ),
            if (!_mapLoaded)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.white,
                  child: Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
