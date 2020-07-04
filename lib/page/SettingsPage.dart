import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
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
          Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context).language),
            subtitle: Text(AppLocalizations.of(context).currentLanguage),
          ),
          FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, AsyncSnapshot<PackageInfo> info) {
              return ListTile(
                title: Text(AppLocalizations.of(context).version),
                subtitle:
                    Text("${info.data?.version} (${info.data?.buildNumber})"),
              );
            },
          ),
        ],
      ),
    );
  }
}
