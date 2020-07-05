import 'package:flutter/material.dart';
import 'package:qwallet/model/user.dart';

class UserSelectionPage extends StatefulWidget {
  final String title;
  final List<User> selectedUsers;
  final List<User> allUsers;

  const UserSelectionPage(
      {Key key,
      @required this.title,
      @required this.selectedUsers,
      @required this.allUsers})
      : super(key: key);

  @override
  _UserSelectionPageState createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {

  List<User> selectedUsers;

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
            onPressed: () => Navigator.of(context).pop(selectedUsers),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: widget.allUsers.length,
        itemBuilder: (BuildContext context, index) =>
            buildUser(context, widget.allUsers[index]),
      ),
    );
  }

  Widget buildUser(BuildContext context, User user) {
    return ListTile(
      leading: buildAvatar(context, user),
      title: Text(user.commonName),
      subtitle: user.displayName != null ? Text(user.email) : null,
      onTap: () => toggleSelectUser(user),
    );
  }

  Widget buildAvatar(BuildContext context, User user) {
    final isSelected = selectedUsers.contains(user);
    if (isSelected)
      return CircleAvatar(
        child: Icon(Icons.check),
      );
    else if (user.avatarUrl != null)
      return CircleAvatar(
        backgroundImage: NetworkImage(user.avatarUrl),
        backgroundColor: Colors.black12,
      );
    else
      return CircleAvatar(
        child: Icon(
          user.displayName != null ? Icons.person : Icons.alternate_email,
          color: Colors.black54,
        ),
        backgroundColor: Colors.black12,
      );
  }
}
