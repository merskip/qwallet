import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/model/user.dart';

class UserSelectionPage extends StatefulWidget {
  final String title;
  final List<User> selectedUsers;

  const UserSelectionPage({
    Key? key,
    required this.title,
    required this.selectedUsers,
  }) : super(key: key);

  @override
  _UserSelectionPageState createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  late List<User> selectedUsers;

  @override
  void initState() {
    selectedUsers = widget.selectedUsers;
    super.initState();
  }

  toggleSelectUser(User user) {
    setState(() {
      selectedUsers.contains(user)
          ? selectedUsers.remove(user)
          : selectedUsers.add(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () => Navigator.of(context).pop(selectedUsers ?? []),
          )
        ],
      ),
      body: FutureBuilder(
        future: DataSource.instance.getUsers(),
        builder: (context, AsyncSnapshot<List<User>> snapshot) {
          return snapshot.hasData
              ? buildUsersList(context, snapshot.data!)
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
      subtitle: Text(user.getSubtitle() ?? ""),
      onTap: () => toggleSelectUser(user),
    );
  }

  Widget buildAvatar(BuildContext context, User user) {
    final isSelected = selectedUsers.contains(user);
    if (isSelected) {
      return CircleAvatar(
        child: Icon(Icons.check),
        backgroundColor: Theme.of(context).primaryColor,
      );
    } else {
      final avatarImage =
          user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null;
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
