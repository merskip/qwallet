import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/features/sign_in/AuthSuite.dart';
import 'package:qwallet/utils/IterableFinding.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

class AccountDialog extends StatelessWidget {
  void onSelectedSignOut(BuildContext context) async {
    await SharedProviders.authSuite.signOut();
    Navigator.of(context).popUntil((route) => route.settings.name == "/");
  }

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: SharedProviders.authSuite.getLastAccount(),
      builder: (context, Account account) => SimpleDialog(
        children: [
          buildAccountTile(context, account),
          ...buildDetails(context, account),
          Divider(),
          buildSignOut(context),
        ],
      ),
    );
  }

  Widget buildAccountTile(BuildContext context, Account account) {
    final avatarUrl = account.avatarUrl;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            account.avatarUrl != null ? NetworkImage(account.avatarUrl!) : null,
        backgroundColor: Colors.black12,
        child: avatarUrl == null
            ? Icon(Icons.person, color: Colors.black54)
            : null,
      ),
      title: Text(
        account.displayName,
        style: Theme.of(context).textTheme.headline6,
      ),
      subtitle: Text(account.email),
    );
  }

  List<Widget> buildDetails(BuildContext context, Account account) {
    final details = getAccountDetails(context, account);
    return [
      ...details.map((entry) => ListTile(
            title: Text(entry.key),
            subtitle: Text(entry.value),
          ))
    ];
  }

  List<MapEntry<String, String>> getAccountDetails(
      BuildContext context, Account account) {
    return [
      MapEntry("Firebase UID", account.firebaseUser.uid),
      MapEntry("Account created",
          "${account.firebaseUser.metadata.creationTime?.toLocal()}"),
      MapEntry("Last sign in",
          "${account.firebaseUser.metadata.lastSignInTime?.toLocal()}"),
      ...account.firebaseUser.providerData
          .map((userInfo) => <MapEntry<String, String>>[
                MapEntry(
                    "Provider",
                    "ID: ${userInfo.providerId}\n"
                        "UID: ${userInfo.uid}"),
              ])
          .flatten(),
      MapEntry("Token expiration time", "${account.expirationDate?.toLocal()}"),
    ];
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
