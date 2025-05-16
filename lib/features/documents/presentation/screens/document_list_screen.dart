import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/document_provider.dart';
import 'document_registration_screen.dart';

class DocumentListScreen extends ConsumerStatefulWidget {
  const DocumentListScreen({super.key});

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(authProvider).currentUser;
      if (currentUser != null) {
        ref
            .read(documentProvider.notifier)
            .loadDocumentsByUser(currentUser.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final documentState = ref.watch(documentProvider);
    final authState = ref.watch(authProvider);
    final currentUser = authState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Documentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: documentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : documentState.error != null
              ? Center(child: Text(documentState.error!))
              : documentState.documents.isEmpty
                  ? const Center(child: Text('No hay documentos'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16),
                      itemCount: documentState.documents.length,
                      itemBuilder: (context, index) {
                        final document = documentState.documents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(document.imgLocalPath),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(document.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getStatusText(document.statusId),
                                  style: TextStyle(
                                    color: _getStatusColor(document.statusId),
                                  ),
                                ),
                                Text(
                                  'Creado el ${document.createdAt.day}/${document.createdAt.month}/${document.createdAt.year} a las ${document.createdAt.hour}:${document.createdAt.minute}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey.shade500,
                                      ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.image),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: Image.file(
                                          File(document.imgLocalPath),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (document.statusId ==
                                    1) // Solo mostrar el botón de cancelar si está pendiente
                                  IconButton(
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                              const Text('Cancelar solicitud'),
                                          content: const Text(
                                              '¿Estás seguro de que deseas cancelar esta solicitud?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                ref
                                                    .read(documentProvider
                                                        .notifier)
                                                    .updateDocument(
                                                      document.copyWith(
                                                          statusId:
                                                              4), // 4 es el ID del estado "Cancelado"
                                                    );
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Sí'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DocumentRegistrationScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
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
}
