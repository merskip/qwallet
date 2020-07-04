import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';

class SettingsPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context).language),
            subtitle: Text(AppLocalizations.of(context).currentLanguage),
          ),
          Divider(),
        ],
      ),
    );
  }
}
