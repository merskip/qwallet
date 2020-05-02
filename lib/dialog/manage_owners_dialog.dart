import 'package:flutter/material.dart';
import 'package:qwallet/firebase_service.dart';

import '../model/wallet.dart';
import '../model/user.dart';

class ManageOwnersDialog extends StatefulWidget {
  final Wallet wallet;

  const ManageOwnersDialog({Key key, this.wallet}) : super(key: key);

  @override
  _ManageOwnersDialogState createState() => _ManageOwnersDialogState();
}

class _ManageOwnersDialogState extends State<ManageOwnersDialog> {
  List<User> users;
  final _usersListKey = new GlobalKey<_UsersListState>();

  @override
  void initState() {
    FirebaseService.instance
        .fetchUsers(includeAnonymous: false)
        .then((users) => setState(() => this.users = users));
    super.initState();
  }

  _onSelectedSaveChanges(BuildContext context) {
    final selectedUsers = _usersListKey.currentState.selectedUsers;
    Navigator.of(context).pop(selectedUsers);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Manage owners"),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: _alertBody(),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        RaisedButton(
          child: Text("Save changes"),
          color: Theme.of(context).primaryColor,
          onPressed:
              users != null ? () => _onSelectedSaveChanges(context) : null,
        ),
      ],
    );
  }

  Widget _alertBody() {
    if (this.users != null) {
      return _UsersList(
        key: _usersListKey,
        users: users,
        initialSelectedUsers: users
            .where((user) => widget.wallet.ownersUid.contains(user.uid))
            .toList(),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator()],
      );
    }
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
