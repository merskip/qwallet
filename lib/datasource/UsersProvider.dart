import 'package:qwallet/model/user.dart';

abstract class UsersProvider {

  Future<User> getCurrentUser();

  Future<List<User>> getUsers();

  Future<User> getUserByUid(String userUid);

  Future<List<User>> getUsersByUids(List<String> usersUids);
}
