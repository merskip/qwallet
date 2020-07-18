import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/LocalPreferences.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/dialog/UserDialog.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/LocalWebsitePage.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/vector_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../router.dart';

class SettingsPage extends StatelessWidget {

  onSelectedChangeThemeMode(
      BuildContext context, ThemeMode currentThemeMode) async {
    final themeMode = await showDialog(
      context: context,
      builder: (context) {
        final buildOption = (ThemeMode themeMode) {
          return ListTile(
            title: Text(_getThemeModeText(themeMode)),
            trailing: currentThemeMode == themeMode ? Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(themeMode),
          );
        };
        return SimpleDialog(
          title: Text("#Select theme mode"),
          children: [
            buildOption(ThemeMode.system),
            buildOption(ThemeMode.light),
            buildOption(ThemeMode.dark),
          ],
        );
      },
    );
    if (themeMode != null) LocalPreferences.setUserThemeMode(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
      ),
      body: Builder(
        builder: (context) => ListView(children: [
          buildUserPanel(context),
          Divider(),
          buildWallets(context),
          Divider(),
          buildThemeMode(context),
          buildLanguage(context),
          buildApplicationVersion(),
          buildDeveloper(context),
          Divider(),
          buildPrivacyPolicy(context),
          buildTermsOfService(context),
          buildLicences(context),
        ]),
      ),
    );
  }

  Widget buildUserPanel(BuildContext context) {
    final user = DataSource.instance.currentUser;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            user.avatarUrl != null ? NetworkImage(user.avatarUrl) : null,
        backgroundColor: Colors.black12,
        child: user.avatarUrl == null
            ? Icon(
                user.email != null ? Icons.alternate_email : Icons.person,
                color: Colors.black54,
              )
            : null,
      ),
      title: Text(user.getCommonName(context)),
      subtitle: Text(user.getSubtitle()),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => UserDialog(user: user),
        );
      },
    );
  }

  Widget buildWallets(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).settingsWallets),
      subtitle: Text(AppLocalizations.of(context).settingsWalletsHint),
      onTap: () => router.navigateTo(context, "/settings/wallets"),
    );
  }

  Widget buildThemeMode(BuildContext context) {
    return SimpleStreamWidget(
        stream: LocalPreferences.userPreferences(),
        builder: (context, UserPreferences userPreferences) {
          return ListTile(
            title: Text("#Theme mode"),
            subtitle: Text(_getThemeModeText(userPreferences.themeMode)),
            dense: true,
            visualDensity: VisualDensity.compact,
            onTap: () =>
                onSelectedChangeThemeMode(context, userPreferences.themeMode),
          );
        });
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return "#Light";
      case ThemeMode.dark:
        return "#Dark";
      case ThemeMode.system:
      default:
        return "#System";
    }
  }

  Widget buildLanguage(BuildContext context) {
    return SimpleStreamWidget(
        stream: LocalPreferences.userPreferences(),
        builder: (context, UserPreferences userPreferences) {
          return ListTile(
            title: Text(AppLocalizations.of(context).settingsLanguage),
            subtitle: Text(AppLocalizations.of(context).locale.toString()),
            dense: true,
            visualDensity: VisualDensity.compact,
          );
        });
  }

  Widget buildApplicationVersion() {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, AsyncSnapshot<PackageInfo> info) {
        return ListTile(
          title: Text(AppLocalizations.of(context).settingsApplicationVersion),
          subtitle: Text("${info.data?.version} (${info.data?.buildNumber})"),
          dense: true,
          visualDensity: VisualDensity.compact,
        );
      },
    );
  }

  Widget buildDeveloper(BuildContext context) {
    final subtitleStyle = TextStyle(
      color: Theme.of(context).textTheme.caption.color,
      fontSize: 12,
    );
    final linkStyle = TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    );
    return ListTile(
      title: Text("Developed by"),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: RichText(
          text: TextSpan(style: subtitleStyle, children: [
            TextSpan(text: "Piotr Merski"),
            TextSpan(text: " <"),
            TextSpan(text: "merskip@gmail.com", style: linkStyle),
            TextSpan(text: ">\n"),
            TextSpan(text: 'merskip.pl', style: linkStyle),
          ]),
        ),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: () async {
        const url = 'http://merskip.pl';
        if (await canLaunch(url)) await launch(url);
      },
    );
  }

  Widget buildPrivacyPolicy(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).settingsPrivacyPolicy),
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: () => pushPage(
        context,
        builder: (context) => LocalWebsitePage(
          title: AppLocalizations.of(context).settingsPrivacyPolicy,
          htmlFile: "assets/privacy_policy.html",
        ),
      ),
    );
  }

  Widget buildTermsOfService(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).settingsTermsOfService),
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: () => pushPage(
        context,
        builder: (context) => LocalWebsitePage(
          title: AppLocalizations.of(context).settingsTermsOfService,
          htmlFile: "assets/terms_of_service.html",
        ),
      ),
    );
  }

  Widget buildLicences(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).settingsLicenses),
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: () async {
        final info = await PackageInfo.fromPlatform();
        showLicensePage(
          context: context,
          applicationName: "QWallet",
          applicationVersion: "${info.version} (${info.buildNumber})",
          applicationLegalese: "Copyright © 2020 Piotr Merski",
          applicationIcon: Padding(
            padding: const EdgeInsets.all(16.0),
            child: VectorImage(
              "assets/app-logo.svg",
              size: Size.square(128),
            ),
          ),
        );
      },
    );
  }
}
