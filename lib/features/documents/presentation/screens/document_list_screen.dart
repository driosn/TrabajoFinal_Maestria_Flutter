import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/document_provider.dart';
import 'document_registration_screen.dart';

class DocumentListScreen extends ConsumerWidget {
  const DocumentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentState = ref.watch(documentProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos'),
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
                            subtitle: Text(
                              _getStatusText(document.statusId),
                              style: TextStyle(
                                color: _getStatusColor(document.statusId),
                              ),
                            ),
                            trailing: PopupMenuButton<int>(
                              onSelected: (statusId) {
                                ref
                                    .read(documentProvider.notifier)
                                    .updateDocument(
                                      document.copyWith(statusId: statusId),
                                    );
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 1,
                                  child: Text('Pendiente'),
                                ),
                                const PopupMenuItem(
                                  value: 2,
                                  child: Text('Aprobado'),
                                ),
                                const PopupMenuItem(
                                  value: 3,
                                  child: Text('Rechazado'),
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
      default:
        return Colors.grey;
    }
  }
}
