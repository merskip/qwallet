import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/model/user.dart';

class UserChoicePage extends StatefulWidget {
  final String title;
  final User selectedUser;

  const UserChoicePage({
    Key key,
    @required this.title,
    @required this.selectedUser,
  }) : super(key: key);

  @override
  _UserChoicePageState createState() => _UserChoicePageState();
}

class _UserChoicePageState extends State<UserChoicePage> {
  void onSelectedUser(BuildContext context, User user) {
    Navigator.of(context).pop(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: DataSource.instance.getUsers(),
        builder: (context, AsyncSnapshot<List<User>> snapshot) {
          return snapshot.hasData
              ? buildUsersList(context, snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildUsersList(BuildContext context, List<User> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (BuildContext context, index) =>
          buildUser(context, users[index]),
    );
  }

  Widget buildUser(BuildContext context, User user) {
    return ListTile(
      leading: buildAvatar(context, user),
      title: Text(user.getCommonName(context)),
      subtitle: Text(user.getSubtitle()),
      onTap: () => onSelectedUser(context, user),
    );
  }

  Widget buildAvatar(BuildContext context, User user) {
    final isSelected = widget.selectedUser == user;
    if (isSelected) {
      return CircleAvatar(
        child: Icon(Icons.check),
        backgroundColor: Theme.of(context).primaryColor,
      );
    } else {
      final avatarImage =
          user.avatarUrl != null ? NetworkImage(user.avatarUrl) : null;
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
