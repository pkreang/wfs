import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

enum CameraPermission { granted, denied, permanentlyDenied, restricted }

Future<CameraPermission> requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (status.isGranted) return CameraPermission.granted;

  status = await Permission.camera.request();
  if (status.isGranted) return CameraPermission.granted;
  if (status.isPermanentlyDenied) return CameraPermission.permanentlyDenied;
  if (Platform.isIOS && status.isRestricted) return CameraPermission.restricted;
  return CameraPermission.denied;
}

Future<bool> ensureCameraPermission() async {
  final result = await requestCameraPermission();
  if (result == CameraPermission.granted) return true;

  final opened = await openAppSettings();
  if (!opened) return false;

  final after = await Permission.camera.status;
  return after.isGranted;
}
