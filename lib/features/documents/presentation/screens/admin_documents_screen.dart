import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_helper.dart';
import '../../../auth/data/repositories/user_repository_impl.dart';
import '../../../auth/domain/entities/user.dart';
import '../providers/document_provider.dart';

class AdminDocumentsScreen extends ConsumerStatefulWidget {
  const AdminDocumentsScreen({super.key});

  @override
  ConsumerState<AdminDocumentsScreen> createState() =>
      _AdminDocumentsScreenState();
}

class _AdminDocumentsScreenState extends ConsumerState<AdminDocumentsScreen> {
  final UserRepositoryImpl _userRepository =
      UserRepositoryImpl(DatabaseHelper());
  Map<int, User> _users = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _userRepository.getUsers();
    setState(() {
      _users = {for (var user in users) user.id!: user};
    });
  }

  String _getUserName(int userId) {
    final user = _users[userId];
    return user != null
        ? '${user.name} ${user.lastName}'
        : 'Usuario desconocido';
  }

  @override
  Widget build(BuildContext context) {
    final documentState = ref.watch(documentProvider);

    return documentState.isLoading
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
                                'Creado por: ${_getUserName(document.userId)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey.shade500,
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
                                  1) // Solo mostrar opciones si está pendiente
                                PopupMenuButton<int>(
                                  onSelected: (statusId) {
                                    ref
                                        .read(documentProvider.notifier)
                                        .updateDocument(
                                          document.copyWith(statusId: statusId),
                                        );
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 2,
                                      child: Text('Aprobar'),
                                    ),
                                    const PopupMenuItem(
                                      value: 3,
                                      child: Text('Rechazar'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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
