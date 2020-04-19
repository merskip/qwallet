class User {
  final String uid;
  final bool isAnonymous;
  final String displayName;
  final String email;

  User({this.uid, this.isAnonymous, this.displayName, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      isAnonymous: json['isAnonymous'] as bool,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
    );
  }
}
