import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mygov/preview.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: BasePage()),
    ),
  );
}

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                List<CameraDescription> _cameras;
                _cameras = await availableCameras();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraApp(cameras: _cameras),
                  ),
                );
              },
              child: Text('Open Camera'),
            ),
            // TextButton(
            //   onPressed: () async {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => CropImage(image: ,)),
            //     );
            //   },
            //   child: Text('Open Crop Image'),
            // ),
          ],
        ),
      ),
    );
  }
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key, this.cameras = const []});
  final List<CameraDescription> cameras;

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;
  bool isFlashOn = false;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = 0; // or widget.initialIndex if you have it
    _init();
  }

  Future<void> _init() async {
    if (widget.cameras.isEmpty) return;
    final c = CameraController(
      widget.cameras[_index],
      ResolutionPreset.max,
      enableAudio: false,
    );
    await c.initialize();
    if (!mounted) return;
    setState(() => controller = c);
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) return; // nothing to switch
    await controller?.dispose(); // dispose current
    setState(
      () =>
          controller = CameraController(
            widget.cameras[_index],
            ResolutionPreset.max,
            enableAudio: false,
          ),
    ); // free up memory
    _index = _index == 0 ? 1 : 0; // 0 -> 1 -> 0 ...
    await _init();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (controller == null || !c!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: MediaQuery.of(context).size.aspectRatio,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller?.value.previewSize!.height,
              height: controller?.value.previewSize!.width,
              child: CameraPreview(controller!),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                replacement: const SizedBox(width: 0),
                visible:
                    widget.cameras[_index].lensDirection ==
                    CameraLensDirection.back,
                child: FloatingActionButton(
                  heroTag: 'flash',
                  onPressed: () async {
                    try {
                      if (isFlashOn) {
                        await controller?.setFlashMode(FlashMode.off);
                        isFlashOn = !isFlashOn;
                        return;
                      }
                      await controller?.setFlashMode(FlashMode.torch);
                      isFlashOn = !isFlashOn;
                    } on CameraException catch (e) {
                      // _showCameraException(e);
                      return;
                    }
                  },
                  child: Icon(
                    isFlashOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(
                  left:
                      widget.cameras[_index].lensDirection ==
                              CameraLensDirection.back
                          ? 32
                          : 0,
                  right: 32,
                ),
                child: FloatingActionButton(
                  heroTag: 'takePicture',
                  onPressed: () async {
                    try {
                      final XFile file = await c.takePicture(); // <-- XFile
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PreviewAndUpload(xfile: file),
                        ),
                      );
                    } on CameraException catch (e) {
                      // _showCameraException(e);
                      return;
                    }
                  },
                  child: const Icon(Icons.camera),
                ),
              ),
              FloatingActionButton(
                heroTag: 'switchCamera',
                onPressed: () async {
                  try {
                    _switchCamera();
                  } on CameraException catch (e) {
                    // _showCameraException(e);
                    return;
                  }
                },
                child: const Icon(Icons.cameraswitch_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
