import 'package:get/get.dart';
import '../database/user_dao.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final UserDAO _userDAO = UserDAO();
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  Future<bool> login(String username, String password) async {
    final user = await _userDAO.getUser(username, password);
    if (user != null) {
      currentUser.value = user;
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password, String role) async {
    final existingUser = await _userDAO.getUserByName(username);
    if (existingUser != null) return false;

    final newUser = UserModel(username: username, password: password, role: role);
    await _userDAO.insertUser(newUser);
    return true;
  }
}
