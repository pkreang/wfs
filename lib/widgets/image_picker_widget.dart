import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/providers/auth_provider.dart';

class ImagePickerWidget extends ConsumerStatefulWidget {
  final String userID;
  final double width;
  final double height;

  final bool allowCamera;
  final bool allowGallery;
  final bool isDisableUpload;

  const ImagePickerWidget({required this.userID, this.width = 60, this.height = 60, this.allowCamera = true, this.allowGallery = true, this.isDisableUpload = false, super.key});

  @override
  ConsumerState<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends ConsumerState<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      if (widget.userID.isNotEmpty) {
        final profileImage = await ref.read(userServiceProvider).getProfileImage(ref, widget.userID);
        if (mounted && profileImage != null) {
          print('new profile image loaded');
          setState(() {
            _profileImage = profileImage;
          });
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> _pickImage(WidgetRef ref, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, maxWidth: 1920, maxHeight: 1080, imageQuality: 85);

      if (image != null) {
        final imageFile = File(image.path);

        // Show the selected image immediately
        setState(() {
          _profileImage = imageFile;
          _isUploading = true;
        });

        final success = await ref.read(userServiceProvider).uploadProfileImage(ref, imageFile);

        if (success) {
          setState(() {
            _isUploading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image uploaded successfully'), backgroundColor: Colors.green));
          }
        } else {
          // Revert to old image on failure
          setState(() => _isUploading = false);
          _loadProfileImage();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload profile image'), backgroundColor: Colors.red));
          }
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      _loadProfileImage();

      if (mounted) {
        String errorMessage = 'Error: $e';

        // Check for file size error
        if (e.toString().contains('FILE_TOO_LARGE')) {
          errorMessage = 'ขนาดไฟล์เกิน 10MB กรุณาเลือกรูปภาพที่มีขนาดเล็กกว่า';
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red, duration: Duration(seconds: 3)));
      }
    }
  }

  void _showImageSourceOptions(WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              // if (widget.allowCamera)
              //   ListTile(
              //     leading: const Icon(Icons.camera_alt),
              //     title: const Text('Camera'),
              //     onTap: () {
              //       Navigator.pop(context);
              //       _pickImage(ref, ImageSource.camera);
              //     },
              //   ),
              if (widget.allowGallery)
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ref, ImageSource.gallery);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Rebuilding ImagePickerWidget');
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.isDisableUpload || _isUploading ? null : () => _pickImage(ref, ImageSource.gallery),
          child: _profileImage != null
              // ? Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 8.0),
              //     child: ClipRRect(
              //       borderRadius: BorderRadius.circular(8),
              //       child: Image.file(
              //         _profileImage ?? File(widget.imagePath!),
              //         fit: BoxFit.cover,
              //         errorBuilder: (context, error, stackTrace) {
              //           return Container(
              //             color: Colors.grey[300],
              //             child: const Icon(Icons.error_outline, size: 40, color: Colors.red),
              //           );
              //         },
              //       ),
              //     ),
              //   )
              ? Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: const BoxDecoration(color: Color(0xFFE27980), shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(
                    _profileImage!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: widget.width,
                        height: widget.height,
                        decoration: const BoxDecoration(color: Color(0xFFE27980), shape: BoxShape.circle),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset('assets/images/avatar_profile.png'),
                      );
                    },
                  ),
                )
              : Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: const BoxDecoration(color: Color(0xFFE27980), shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/images/avatar_profile.png'),
                ),
        ),
        if (_isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          ),
      ],
    );
  }
}
