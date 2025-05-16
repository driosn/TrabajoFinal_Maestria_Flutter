import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/database_helper.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/user_management_screen.dart';
import 'features/documents/data/repositories/document_repository_impl.dart';
import 'features/documents/presentation/providers/document_provider.dart';
import 'features/documents/presentation/screens/document_list_screen.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithValue(
          UserRepositoryImpl(DatabaseHelper()),
        ),
        documentRepositoryProvider.overrideWithValue(
          DocumentRepositoryImpl(DatabaseHelper()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Gestión de Documentos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: authState.isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : authState.currentUser != null
              ? authState.currentUser!.roleId == 2
                  ? const UserManagementScreen()
                  : const DocumentListScreen()
              : const LoginScreen(),
    );
  }
}
