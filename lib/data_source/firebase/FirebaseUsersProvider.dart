import 'package:cloud_functions/cloud_functions.dart' as CloudFunctions;
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:qwallet/data_source/UsersProvider.dart';
import 'package:qwallet/model/user.dart';

class FirebaseUsersProvider implements UsersProvider {
  List<User>? _cachedUsers;

  final CloudFunctions.FirebaseFunctions firebaseFunctions;

  FirebaseUsersProvider({
    required this.firebaseFunctions,
  });

  @override
  User getCurrentUser() {
    final firebaseUser = FirebaseAuth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null)
      return throw Exception("No current user in FirebaseAuth");
    return User.fromFirebase(firebaseUser, true);
  }

  Future<List<User>> getUsers() async {
    final cachedUsers = _cachedUsers;
    if (cachedUsers != null) return cachedUsers;
    final users = await _fetchUsers();
    _cachedUsers = users;
    return users;
  }

  Future<List<User>> _fetchUsers() async {
    final callable = firebaseFunctions.httpsCallable("getUsers");
    dynamic response = await callable.call();
    final content = response.data as List;
    final currentUser = await getCurrentUser();

    return content
        .map((userJson) =>
            User.fromJson(userJson.cast<String, dynamic>(), currentUser.uid))
        .where((user) => !user.isAnonymous)
        .toList();
  }

  Future<User> getUserByUid(String userUid) async {
    final users = await getUsers();
    return users.firstWhere((user) => user.uid == userUid);
  }

  Future<List<User>> getUsersByUids(List<String> usersUids) async {
    final users = await getUsers();
    return usersUids
        .map((uid) => users.firstWhere(
              (user) => user.uid == uid,
              orElse: () => User.emptyFromUid(uid),
            ))
        .toList();
  }
}
