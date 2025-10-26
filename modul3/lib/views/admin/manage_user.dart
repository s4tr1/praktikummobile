import 'package:flutter/material.dart';
import '../../database/user_dao.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final UserDAO _userDAO = UserDAO();
  List<UserModel> users = [];

  final _usernameController = TextEditingController();
  final _roleController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final data = await _userDAO.getAllUsers();
    setState(() => users = data);
  }

  Future<void> _addUser() async {
    final newUser = UserModel(
      username: _usernameController.text,
      password: _passwordController.text,
      role: _roleController.text,
    );
    await _userDAO.insertUser(newUser);
    _loadUsers();
    _usernameController.clear();
    _passwordController.clear();
    _roleController.clear();
  }

  Future<void> _deleteUser(int id) async {
    await _userDAO.deleteUser(id);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Role (admin/user)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addUser,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Tambah User"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final u = users[index];
                  return Card(
                    child: ListTile(
                      title: Text(u.username),
                      subtitle: Text('Role: ${u.role}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(u.id!),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
