import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _scannedText;
  String? _scannedImagePath;

  Future<void> _scanDocument() async {
    setState(() {
      _isLoading = true;
      _scannedText = null;
      _scannedImagePath = null;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (photo != null) {
        // Save the original photo
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String filePath = '${appDir.path}/$fileName';

        // Copy the photo to the app's documents directory
        await File(photo.path).copy(filePath);

        // Process the image with text recognition
        final textRecognizer = TextRecognizer();
        final RecognizedText recognizedText = await textRecognizer.processImage(
          InputImage.fromFilePath(photo.path),
        );

        setState(() {
          _scannedText = recognizedText.text;
          _scannedImagePath = filePath;
        });

        if (mounted) {
          Navigator.pop(context, {
            'imagePath': filePath,
            'scannedText': recognizedText.text,
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar la imagen: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Documento'),
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Procesando documento...'),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_scannedImagePath != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Documento escaneado:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_scannedImagePath!),
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_scannedText != null) ...[
                              Text(
                                'Texto detectado:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(_scannedText!),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  ElevatedButton.icon(
                    onPressed: _scanDocument,
                    icon: const Icon(Icons.document_scanner),
                    label: Text(_scannedImagePath == null
                        ? 'Escanear Documento'
                        : 'Escanear Nuevo Documento'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
