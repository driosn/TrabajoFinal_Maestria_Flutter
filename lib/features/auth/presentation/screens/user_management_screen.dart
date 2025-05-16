import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  int _selectedRoleId = 1; // Default to Editor role

  @override
  void initState() {
    ref.read(authProvider.notifier).loadUsers();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showCreateUserDialog() async {
    final nameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final obscurePasswordNotifier = ValueNotifier<bool>(true);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Usuario'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un apellido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un email';
                    }
                    return null;
                  },
                ),
                ValueListenableBuilder(
                    valueListenable: obscurePasswordNotifier,
                    builder: (context, value, child) {
                      return TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          suffixIcon: IconButton(
                            icon: Icon(
                              value ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              obscurePasswordNotifier.value =
                                  !obscurePasswordNotifier.value;
                            },
                          ),
                        ),
                        obscureText: value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una contraseña';
                          }
                          return null;
                        },
                      );
                    }),
                DropdownButtonFormField<int>(
                  value: _selectedRoleId,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Editor')),
                    DropdownMenuItem(value: 2, child: Text('Administrador')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRoleId = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final user = User(
                  name: nameController.text,
                  lastName: lastNameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                  roleId: _selectedRoleId,
                  createdAt: DateTime.now(),
                );
                ref.read(authProvider.notifier).createUser(user);
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(authProvider).users;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text('${user.name} ${user.lastName}'),
            subtitle: Text(user.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      ref.read(authProvider.notifier).deleteUser(user.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
