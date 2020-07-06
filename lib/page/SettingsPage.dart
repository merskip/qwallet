import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../router.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
      ),
      body: Builder(
        builder: (context) => ListView(children: [
          buildWallets(context),
          Divider(),
          buildLanguage(context),
          buildApplicationVersion(),
          buildDeveloper()
        ]),
      ),
    );
  }

  Widget buildWallets(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).wallets),
      subtitle: Text(AppLocalizations.of(context).walletsHint),
      onTap: () => router.navigateTo(context, "/settings/wallets"),
    );
  }

  Widget buildLanguage(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).language),
      subtitle: Text(AppLocalizations.of(context).currentLanguage),
    );
  }

  Widget buildApplicationVersion() {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, AsyncSnapshot<PackageInfo> info) {
        return ListTile(
          title: Text(AppLocalizations.of(context).version),
          subtitle: Text("${info.data?.version} (${info.data?.buildNumber})"),
        );
      },
    );
  }

  Widget buildDeveloper() {
    return ListTile(
      title: Text("Developed by"),
      subtitle: Text("Piotr Merski <merskip@gmail.com>\nmerskip.pl"),
      onTap: () async {
        const url = 'http://merskip.pl';
        if (await canLaunch(url)) await launch(url);
      },
    );
  }
}
