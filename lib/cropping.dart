import 'package:camera/camera.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:mygov/result.dart';

class CropImage extends StatelessWidget {
  const CropImage({super.key, required this.image});
  final XFile image;

  @override
  Widget build(BuildContext context) {
    final _controller = CropController();
    return Stack(
      children: [
        FutureBuilder<Uint8List>(
          future: image.readAsBytes(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            return Crop(
              image: snap.data!,
              controller: _controller,
              baseColor: Colors.black,
              withCircleUi: true,
              cornerDotBuilder: (size, edgeAlignment) {
                return const DotControl(color: Colors.transparent);
              },
              // initialRectBuilder: InitialRectBuilder.withBuilder((
              //   imageSize,
              //   widgetSize,
              // ) {
              //   final shortestSide =
              //       imageSize.width < imageSize.height
              //           ? imageSize.width
              //           : imageSize.height;
              //   final left = (imageSize.width - shortestSide) / 2 + 40;
              //   final top = (imageSize.height - shortestSide) / 2;
              //   return Rect.fromLTWH(left, top, shortestSide-80, shortestSide + 100);
              // }),
              // radius: 40,

              overlayBuilder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                  ),
                );
              },
              initialRectBuilder: InitialRectBuilder.withBuilder((
                imageSize,
                widgetSize,
              ) {
                final shortestSide =
                    imageSize.width < imageSize.height
                        ? imageSize.width
                        : imageSize.height;
                final left = (imageSize.width - shortestSide) / 2 + 40 ;
                final top = (imageSize.height - shortestSide) / 2;
                return Rect.fromLTWH(left, top, shortestSide-80, shortestSide + 80 );
              }),
              radius: 40,
              fixCropRect: true,
              aspectRatio: 1,
              interactive: true,
              onCropped: (result) {
                debugPrint('Cropped $result');
                if (result is CropSuccess) {
                  final xfile = uint8ToXFile(
                    result.croppedImage,
                    name: 'avatar.png',
                  );
                  debugPrint('Cropped to XFile: $xfile');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultCrop(x: xfile),
                    ),
                  );
                } else if (result is CropFailure) {
                  debugPrint('Crop failed: ${result.cause}');
                }
              },
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          left: 20,
          child: ElevatedButton(
            onPressed: () {
              _controller.crop();
            },
            child: const Text('Crop Image'),
          ),
        ),
      ],
    );
  }

  XFile uint8ToXFile(Uint8List bytes, {String name = 'image.png'}) {
    return XFile.fromData(
      bytes,
      name: name,
      mimeType: 'image/png', // change to 'image/jpeg' if needed
    );
  }
}
