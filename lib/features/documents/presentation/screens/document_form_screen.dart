import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/document.dart';
import '../providers/document_provider.dart';

class DocumentFormScreen extends ConsumerStatefulWidget {
  final Document? document;

  const DocumentFormScreen({super.key, this.document});

  @override
  ConsumerState<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends ConsumerState<DocumentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  int _selectedStatusId = 1; // Default to Pending status

  @override
  void initState() {
    super.initState();
    if (widget.document != null) {
      _nameController.text = widget.document!.name;
      _selectedStatusId = widget.document!.statusId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.document == null ? 'Nuevo Documento' : 'Editar Documento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
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
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedStatusId,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Pendiente')),
                  DropdownMenuItem(value: 2, child: Text('Aprobado')),
                  DropdownMenuItem(value: 3, child: Text('Rechazado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatusId = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final document = Document(
                      id: widget.document?.id,
                      userId: currentUser!.id!,
                      name: _nameController.text,
                      statusId: _selectedStatusId,
                      imgLocalPath: '',
                      createdAt: widget.document?.createdAt ?? DateTime.now(),
                    );

                    if (widget.document == null) {
                      ref.read(documentProvider.notifier).createDocument(
                            userId: currentUser.id!,
                            name: _nameController.text,
                            imgLocalPath: '',
                            statusId: _selectedStatusId,
                          );
                    } else {
                      ref
                          .read(documentProvider.notifier)
                          .updateDocument(document);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(widget.document == null ? 'Crear' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
