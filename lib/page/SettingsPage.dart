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

import '../EsterEgg.dart';
import '../router.dart';

class SettingsPage extends StatelessWidget {
  onSelectedChangeThemeMode(
      BuildContext context, ThemeMode currentThemeMode) async {
    final themeMode = await showDialog(
      context: context,
      builder: (context) {
        final buildOption = (ThemeMode themeMode) {
          return ListTile(
            title: Text(_getThemeModeText(context, themeMode)),
            trailing: currentThemeMode == themeMode ? Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(themeMode),
          );
        };
        return SimpleDialog(
          title: Text(AppLocalizations.of(context).settingsThemeModeSelect),
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

  onSelectedChangeLanguage(BuildContext context, Locale currentLocale) async {
    final locale = await showDialog(
      context: context,
      builder: (context) {
        final buildOption = (Locale locale) {
          return ListTile(
            title:
                Text(AppLocalizations.of(context).settingsLocaleNative(locale)),
            subtitle: Text(AppLocalizations.of(context).settingsLocale(locale)),
            trailing: currentLocale == locale ? Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(locale),
          );
        };
        return SimpleDialog(
          title: Text(AppLocalizations.of(context).settingsLocaleSelect),
          children: [
            buildOption(Locale("en", "US")),
            buildOption(Locale("pl", "PL")),
          ],
        );
      },
    );
    if (locale != null) LocalPreferences.setUserLocale(locale);
  }

  onSelectedApplicationVersion(BuildContext context) {
    if (EasterEgg.waiting) return;
    final message = EasterEgg.nextMessage();
    if (message != null) {
      EasterEgg.waiting = true;

      Widget content;
      var duration = Duration(seconds: 2);
      if (!message.startsWith("assets/")) {
        content = Text(message);
      } else {
        final chunks = message.split("|");
        final assetName = chunks[0];
        final title = chunks[1];
        content = Column(
          mainAxisSize: MainAxisSize.min,
            children: [
          Text(title, style: Theme.of(context).primaryTextTheme.headline6),
          SizedBox(height: 8),
          Image(image: AssetImage(assetName)),
        ]);
        duration = Duration(seconds: 6);
      }

      final snackBar = Scaffold.of(context).showSnackBar(SnackBar(
        content: content,
        duration: duration,
      ));
      snackBar.closed.then((value) => EasterEgg.waiting = false);
    }
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
          Divider(),
          buildPrivacyPolicy(context),
          buildTermsOfService(context),
          buildLicences(context),
          Divider(),
          buildDeveloper(context),
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
        stream: LocalPreferences.userPreferences,
        builder: (context, UserPreferences userPreferences) {
          return ListTile(
            title: Text(AppLocalizations.of(context).settingsThemeMode),
            subtitle:
                Text(_getThemeModeText(context, userPreferences.themeMode)),
            dense: true,
            visualDensity: VisualDensity.compact,
            onTap: () =>
                onSelectedChangeThemeMode(context, userPreferences.themeMode),
          );
        });
  }

  String _getThemeModeText(BuildContext context, ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return AppLocalizations.of(context).settingsThemeModeLight;
      case ThemeMode.dark:
        return AppLocalizations.of(context).settingsThemeModeDark;
      case ThemeMode.system:
      default:
        return AppLocalizations.of(context).settingsThemeModeSystem;
    }
  }

  Widget buildLanguage(BuildContext context) {
    return SimpleStreamWidget(
        stream: LocalPreferences.userPreferences,
        builder: (context, UserPreferences userPreferences) {
          final currentLocale =
              userPreferences.locale ?? AppLocalizations.of(context).locale;
          return ListTile(
            title: Text(AppLocalizations.of(context).settingsLanguage),
            subtitle: Text(
                AppLocalizations.of(context).settingsLocale(currentLocale)),
            dense: true,
            visualDensity: VisualDensity.compact,
            onTap: () => onSelectedChangeLanguage(context, currentLocale),
          );
        });
  }

  Widget buildApplicationVersion() {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, AsyncSnapshot<PackageInfo> info) {
        return GestureDetector(
          child: ListTile(
            title:
                Text(AppLocalizations.of(context).settingsApplicationVersion),
            subtitle: Text("${info.data?.version} (${info.data?.buildNumber})"),
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
          onDoubleTap: () => onSelectedApplicationVersion(context),
        );
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
            TextSpan(text: " | "),
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
}
