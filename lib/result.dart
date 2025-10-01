import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResultCrop extends StatefulWidget {
  const ResultCrop({super.key, this.x});
  final XFile? x;

  @override
  State<ResultCrop> createState() => _ResultCropState();
}

class _ResultCropState extends State<ResultCrop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<Uint8List>(
          future: widget.x?.readAsBytes(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            return SizedBox(
              width: 200,
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.memory(
                  snap.data!,
                  fit: BoxFit.cover,
                  // optional downscale to save RAM:
                  // cacheWidth: 1024,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
