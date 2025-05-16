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
  final _scannedTextController = TextEditingController();
  String? _imagePath;
  bool _isLoading = false;
  final int _selectedStatusId = 1; // Default to Pending status

  @override
  void dispose() {
    _nameController.dispose();
    _scannedTextController.dispose();
    super.dispose();
  }

  Future<void> _scanDocument() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );

    if (result != null) {
      setState(() {
        _imagePath = result['imagePath'];
        _scannedTextController.text = result['scannedText'] ?? '';
      });
    }
  }

  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escanee el documento')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authProvider).currentUser;
      if (currentUser != null) {
        await ref.read(documentProvider.notifier).createDocument(
              name: _nameController.text,
              imgLocalPath: _imagePath!,
              scannedText: _scannedTextController.text,
              statusId: _selectedStatusId,
              userId: currentUser.id!,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documento guardado exitosamente')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el documento: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Documento'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _scannedTextController,
                    decoration: const InputDecoration(
                      labelText: 'Texto Escaneado',
                      border: OutlineInputBorder(),
                      hintText: 'El texto escaneado aparecerá aquí',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor escanee el documento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _scannedTextController,
                    builder: (context, value, child) {
                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.text_fields, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Vista Previa del Texto',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                value.text.isEmpty
                                    ? 'No hay texto escaneado'
                                    : value.text,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                ElevatedButton.icon(
                  onPressed: _scanDocument,
                  icon: const Icon(Icons.camera_alt),
                  label:
                      Text(_imagePath == null ? 'Tomar Foto' : 'Cambiar Foto'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveDocument,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Registrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
