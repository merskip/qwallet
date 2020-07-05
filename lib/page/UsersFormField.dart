import 'package:flutter/material.dart';
import 'package:qwallet/model/user.dart';

class UsersFormField extends FormField<List<User>> {
  final List<User> users;
  final InputDecoration decoration;

  UsersFormField({this.users, @required this.decoration})
      : super(builder: (FormFieldState<List<User>> state) {
          return Builder(
            builder: (context) =>
                buildUsersInput(context, decoration, users),
          );
        });

  static Widget buildUsersInput(
      BuildContext context, InputDecoration decoration, List<User> users) {
    return InputDecorator(
      decoration: decoration.copyWith(
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      ),
      child: Wrap(
        children: users.map((user) => buildUserChip(context, user)).toList(),
      ),
    );
  }

  static Widget buildUserChip(BuildContext context, User user) {
    return Chip(
      avatar: buildAvatar(context, user),
      label: Text(user.commonName),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static Widget buildAvatar(BuildContext context, User user) {
    if (user.avatarUrl != null)
      return CircleAvatar(
        backgroundImage: NetworkImage(user.avatarUrl),
        backgroundColor: Colors.transparent,
      );
    else if (user.displayName != null)
      return Icon(Icons.person, color: Colors.black54);
    else
      return Icon(Icons.alternate_email, color: Colors.black54);
  }
}
