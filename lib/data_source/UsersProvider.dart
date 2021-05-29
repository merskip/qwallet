import 'package:qwallet/model/User.dart';

abstract class UsersProvider {
  User getCurrentUser();

  Future<List<User>> getUsers();

  Future<User> getUserByUid(String userUid);

  Future<List<User>> getUsersByUids(List<String> usersUids);
}
