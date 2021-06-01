import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/data_source/Account.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

class AccountDialog extends StatelessWidget {
  void onSelectedSignOut(BuildContext context) async {
    await SharedProviders.accountProvider.signOut();
    Navigator.of(context).popUntil((route) => route.settings.name == "/");
  }

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: SharedProviders.accountProvider.getAccount(),
      builder: (context, Account account) => SimpleDialog(
        children: [
          buildAccountTile(context, account),
          Divider(),
          buildSignOut(context),
        ],
      ),
    );
  }

  Widget buildAccountTile(BuildContext context, Account account) {
    final avatarUrl = account.getAvatarUrl();
    final firebaseUser = account.firebaseUser;
    if (firebaseUser == null) return Container();
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        backgroundColor: Colors.black12,
        child: avatarUrl == null
            ? Icon(Icons.person, color: Colors.black54)
            : null,
      ),
      title: Text(
        firebaseUser.displayName ?? "",
        style: Theme.of(context).textTheme.headline6,
      ),
      subtitle: Text(firebaseUser.email ?? ""),
    );
  }

  Widget buildSignOut(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.exit_to_app),
      title: Text(AppLocalizations.of(context).userLogout),
      onTap: () => onSelectedSignOut(context),
    );
  }
}

class _DeleteUserTile extends StatefulWidget {
  final VoidCallback onConfirmed;

  const _DeleteUserTile({Key? key, required this.onConfirmed})
      : super(key: key);

  @override
  _DeleteUserTileState createState() => _DeleteUserTileState();
}

class _DeleteUserTileState extends State<_DeleteUserTile> {
  bool isDuringConfirm = false;

  onSelected() {
    if (!isDuringConfirm) {
      setState(() => isDuringConfirm = true);
    } else {
      widget.onConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(!isDuringConfirm ? Icons.delete_outline : Icons.delete),
      title: Text(
        !isDuringConfirm
            ? AppLocalizations.of(context).userRemoveAccount
            : AppLocalizations.of(context).userRemoveAccountConfirmation,
        style: TextStyle(
            color: Colors.red,
            fontWeight: isDuringConfirm ? FontWeight.bold : null),
      ),
      subtitle: isDuringConfirm
          ? Text(AppLocalizations.of(context).userRemoveAccountConfirmationHint)
          : null,
      onTap: () => onSelected(),
    );
  }
}
