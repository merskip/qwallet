import 'package:flutter/material.dart';
import 'package:qwallet/model/User.dart';

class UserAvatar extends StatelessWidget {
  final User user;
  final bool isSelected;

  const UserAvatar({
    Key? key,
    required this.user,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return CircleAvatar(
        child: Icon(Icons.check),
        backgroundColor: Theme.of(context).primaryColor,
      );
    } else {
      final avatarUrl = user.avatarUrl;
      final avatarImage = avatarUrl != null ? NetworkImage(avatarUrl) : null;
      final avatarPlaceholderIcon = user.displayName != null
          ? Icon(Icons.person)
          : Icon(Icons.alternate_email);

      return CircleAvatar(
        child: avatarImage == null ? avatarPlaceholderIcon : null,
        backgroundImage: avatarImage,
        backgroundColor: Colors.black12,
      );
    }
  }
}
