import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/document_provider.dart';
import 'camera_screen.dart';

class DocumentRegistrationScreen extends ConsumerStatefulWidget {
  const DocumentRegistrationScreen({super.key});

  @override
  ConsumerState<DocumentRegistrationScreen> createState() =>
      _DocumentRegistrationScreenState();
}

class _DocumentRegistrationScreenState
    extends ConsumerState<DocumentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _imagePath;
  final int _selectedStatusId = 1; // Default to Pending status

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final imagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );

    if (imagePath != null) {
      setState(() {
        _imagePath = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Documento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Documento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_imagePath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              ElevatedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt),
                label: Text(_imagePath == null ? 'Tomar Foto' : 'Cambiar Foto'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_imagePath == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Por favor tome una foto del documento'),
                        ),
                      );
                      return;
                    }
                    if (currentUser != null) {
                      ref.read(documentProvider.notifier).createDocument(
                            name: _nameController.text,
                            imgLocalPath: _imagePath!,
                            statusId: _selectedStatusId,
                            userId: currentUser.id!,
                          );
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
