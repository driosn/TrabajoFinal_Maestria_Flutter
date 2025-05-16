import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto_flutter_ucb_david_rios/core/database/database_helper.dart';
import 'package:proyecto_flutter_ucb_david_rios/features/auth/data/repositories/user_repository_impl.dart';
import 'package:proyecto_flutter_ucb_david_rios/features/auth/domain/entities/user.dart';
import 'package:proyecto_flutter_ucb_david_rios/features/auth/presentation/providers/auth_provider.dart';
import 'package:proyecto_flutter_ucb_david_rios/features/documents/domain/entities/document.dart';
import 'package:proyecto_flutter_ucb_david_rios/features/documents/presentation/providers/document_provider.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final Document document;

  const DocumentDetailScreen({
    super.key,
    required this.document,
  });

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  final UserRepositoryImpl _userRepository =
      UserRepositoryImpl(DatabaseHelper());
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userRepository.getUserById(widget.document.userId);
    setState(() {
      _user = user;
    });
  }

  String _getStatusText(int statusId) {
    switch (statusId) {
      case 1:
        return 'Pendiente';
      case 2:
        return 'Aprobado';
      case 3:
        return 'Rechazado';
      case 4:
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.red.shade300;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showStatusChangeDialog(int newStatusId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Deseas cambiar el estado de este documento?'),
        content: Text(
          'Esta acción cambiará el estado del documento a "${_getStatusText(newStatusId)}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(documentProvider.notifier).updateDocument(
            widget.document.copyWith(statusId: newStatusId),
          );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).currentUser;
    final isAdmin = currentUser?.roleId == 2;
    final documentState = ref.watch(documentProvider);

    // Encontrar el documento actualizado en la lista
    final updatedDocument = documentState.documents.firstWhere(
      (doc) => doc.id == widget.document.id,
      orElse: () => widget.document,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Documento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del documento
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre del documento',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      updatedDocument.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Estado',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getStatusText(updatedDocument.statusId),
                            style: TextStyle(
                              color: _getStatusColor(updatedDocument.statusId),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isAdmin) // Solo mostrar opciones si es admin
                          PopupMenuButton<int>(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Cambiar estado',
                            onSelected: (statusId) =>
                                _showStatusChangeDialog(statusId),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 1,
                                child: Text('Pendiente'),
                              ),
                              const PopupMenuItem(
                                value: 2,
                                child: Text('Aprobar'),
                              ),
                              const PopupMenuItem(
                                value: 3,
                                child: Text('Rechazar'),
                              ),
                              const PopupMenuItem(
                                value: 4,
                                child: Text('Cancelar'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fecha y hora de creación',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${updatedDocument.createdAt.day}/${updatedDocument.createdAt.month}/${updatedDocument.createdAt.year} a las ${updatedDocument.createdAt.hour}:${updatedDocument.createdAt.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Imagen del documento
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(updatedDocument.imgLocalPath),
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            // Texto escaneado del documento
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.text_fields, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Texto Escaneado',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      updatedDocument.scannedText.isEmpty
                          ? 'No hay texto escaneado'
                          : updatedDocument.scannedText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Información del creador
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del creador',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    if (_user != null) ...[
                      _buildInfoRow(
                          'Nombre', '${_user!.name} ${_user!.lastName}'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Correo', _user!.email),
                    ] else
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
