import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mygov/cropping.dart';

class PreviewAndUpload extends StatefulWidget {
  const PreviewAndUpload({required this.xfile});
  final XFile xfile;

  @override
  State<PreviewAndUpload> createState() => PreviewAndUploadState();
}

class PreviewAndUploadState extends State<PreviewAndUpload> {
  final Dio _dio = Dio();
  double _progress = 0.0;
  bool _uploading = false;
  String? _result;

  Future<void> _upload() async {
    setState(() {
      _uploading = true;
      _progress = 0;
      _result = null;
    });

    try {
      final path = widget.xfile.path; // XFile -> file path
      final fileName = path.split('/').last;

      final form = FormData.fromMap({
        // ‘file’ is the field name; adjust to your API
        'file': await MultipartFile.fromFile(
          path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'), // import from http_parser
        ),
        // Add any extra fields:
      });

      final resp = await _dio.post(
        'https://httpbin.org/post', // simulate upload endpoint
        data: form,
        onSendProgress: (sent, total) {
          if (total > 0) {
            setState(() => _progress = sent / total);
          }
        },
        options: Options(headers: {'Authorization': 'Bearer <token-if-any>'}),
      );

      setState(() => _result = 'Uploaded: status ${resp.statusCode}');
    } catch (e) {
      setState(() => _result = 'Upload failed: $e');
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.xfile.path);
    return Scaffold(
      appBar: AppBar(title: const Text('Preview & Upload')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: MediaQuery.of(context).size.aspectRatio,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.height,
                    height: MediaQuery.of(context).size.width,
                    child: Image.file(file),
                  ),
                ),
              ),
            ),
          ),
          if (_uploading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
              ),
            ),
          if (_result != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_result!, style: const TextStyle(fontSize: 14)),
            ),
          ElevatedButton.icon(
            icon: const Icon(Icons.crop),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropImage(image: widget.xfile),
                ),
              );
            },
            label: Text('Crop Image'),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                onPressed: _uploading ? null : _upload,
                label: Text(_uploading ? 'Uploading...' : 'Upload'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
