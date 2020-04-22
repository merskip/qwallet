import 'package:flutter/material.dart';

import '../model/wallet.dart';
import '../model/user.dart';

class ManageOwnersDialog {
  final Wallet wallet;
  final List<User> users;

  final usersListKey = new GlobalKey<_UsersListState>();

  ManageOwnersDialog(this.wallet, this.users);

  Future<List<User>> show(BuildContext context) async {
    return _showDialog(context, users);
  }

  Future<List<User>> _showDialog(BuildContext context, List<User> users) {
    return showDialog(
      context: context,
      builder: _usersDialog,
    );
  }

  _onSelectedSaveChanges(BuildContext context) {
    final selectedUsers = usersListKey.currentState.selectedUsers;
    Navigator.of(context).pop(selectedUsers);
  }

  Widget _usersDialog(BuildContext context) {
    return AlertDialog(
      title: Text("Manage owners"),
      content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: _UsersList(
            key: usersListKey,
            users: users,
            initialSelectedUsers: users
                .where((user) => wallet.ownersUid.contains(user.uid))
                .toList(),
          )),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        RaisedButton(
          child: Text("Save changes"),
          color: Theme.of(context).primaryColor,
          onPressed: () => _onSelectedSaveChanges(context),
        ),
      ],
    );
  }
}

class _UsersList extends StatefulWidget {
  final List<User> users;
  final List<User> initialSelectedUsers;

  const _UsersList({Key key, this.users, this.initialSelectedUsers})
      : super(key: key);

  @override
  _UsersListState createState() => _UsersListState(initialSelectedUsers);
}

class _UsersListState extends State<_UsersList> {
  List<User> selectedUsers;

  _UsersListState(this.selectedUsers);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.users.length,
      itemBuilder: (context, index) => _userListItem(widget.users[index]),
    );
  }

  Widget _userListItem(User user) {
    return CheckboxListTile(
      title: Text(user.displayName ?? user.email),
      subtitle: user.displayName != null ? Text(user.email) : null,
      value: selectedUsers.contains(user),
      onChanged: (bool value) {
        setState(() {
          value ? selectedUsers.add(user) : selectedUsers.remove(user);
        });
      },
    );
  }
}
