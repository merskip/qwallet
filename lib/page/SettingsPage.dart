import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {

  onSelectedWallets(BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("TODO: Manage wallets")
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
      ),
      body: Builder(builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: Text("Wallets"),
              subtitle: Text("Manage your wallets"),
              onTap: () => onSelectedWallets(context),
            ),
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
            ListTile(
              title: Text("Developed by"),
              subtitle: Text("Piotr Merski <merskip@gmail.com>\nmerskip.pl"),
              onTap: () async {
                const url = 'http://merskip.pl';
                if (await canLaunch(url)) await launch(url);
              },
            )
          ],
        );
      }),
    );
  }
}
