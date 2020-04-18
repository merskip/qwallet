class User {
  final String uid;
  final String displayName;
  final String email;

  User({this.uid, this.displayName, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
    );
  }
}
