// camera_page.dart
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class AppCamera extends StatefulWidget {
  const AppCamera({super.key});

  @override
  State<AppCamera> createState() => _AppCameraState();
}

class _AppCameraState extends State<AppCamera> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final desc = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);

      final controller = CameraController(desc, ResolutionPreset.high, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);

      await controller.initialize();
      if (!mounted) return;
      setState(() => _controller = controller);
    } on CameraException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camera error: ${e.code}')));
      Navigator.pop(context);
    }
  }

  Future<void> _capture() async {
    final c = _controller;
    if (_isCapturing || c == null || !c.value.isInitialized) return;

    setState(() => _isCapturing = true);
    try {
      await c.lockCaptureOrientation();

      // await c.pausePreview();

      final xfile = await c.takePicture();
      final bytes = await xfile.readAsBytes();
      if (!mounted) return;

      Navigator.pop(context, base64Encode(bytes));
    } catch (e) {
      try {
        await c.resumePreview();
        await c.unlockCaptureOrientation();
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Capture failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(c)),
          SafeArea(child: Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)), const Spacer()])),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: _capture,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                    alignment: Alignment.center,
                    child: Icon(Icons.camera_alt_outlined, color: Colors.black, size: 40),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
