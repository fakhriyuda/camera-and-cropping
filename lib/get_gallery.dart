import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoPage extends StatefulWidget {
  const ProfilePhotoPage({super.key});
  @override
  State<ProfilePhotoPage> createState() => _ProfilePhotoPageState();
}

class _ProfilePhotoPageState extends State<ProfilePhotoPage> {
  final _picker = ImagePicker();
  final _cropController = CropController();

  Uint8List? _sourceBytes; // picked image bytes
  Uint8List? _croppedBytes; // result after crop

  Future<void> _pick() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _sourceBytes = bytes;
      _croppedBytes = null;
    });
  }

  void _startCrop() {
    _cropController.crop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Set Profile Picture')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Current avatar (preview)
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  _croppedBytes != null ? MemoryImage(_croppedBytes!) : null,
              child:
                  _croppedBytes == null
                      ? const Icon(Icons.person, size: 48)
                      : null,
            ),
            const SizedBox(height: 16),

            // Pick button
            FilledButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose Photo'),
            ),
            const SizedBox(height: 16),

            // Cropper (shows after picking)
            if (_sourceBytes != null)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Crop(
                          controller: _cropController,
                          image: _sourceBytes!,
                          // Circle overlay + 1:1 area; user can pinch/drag to reposition
                          withCircleUi: true,
                          aspectRatio: 1,
                          // nice UX defaults
                          baseColor:
                              Colors.black, // dim background around image
                          maskColor: Colors.black54, // outside overlay
                          radius: 999, // fully round (since aspectRatio=1)
                          onCropped:
                              (cropped) => setState(
                                () =>
                                    _croppedBytes =
                                        Uint8List.fromList(
                                              cropped as List<int>,
                                            ).toList()
                                            as Uint8List?,
                              ),
                          // Optional: limit zoom range
                          // You can also set 'fixArea' to true if you want the circle fixed size.
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        
                        
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _startCrop,
                            icon: const Icon(Icons.check),
                            label: const Text('Use Photo'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
