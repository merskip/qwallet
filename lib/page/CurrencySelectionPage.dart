import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Currency.dart';

class CurrencySelectionPage extends StatefulWidget {
  @override
  _CurrencySelectionPageState createState() => _CurrencySelectionPageState();
}

class _CurrencySelectionPageState extends State<CurrencySelectionPage> {
  final currencies = Currency.all;

  onSelectedCurrency(BuildContext context, Currency currency) {
    Navigator.of(context).pop(currency);
  }

  onSelectedCurrencyInfo(BuildContext context, Currency currency) {
    pushPage(
      context,
      builder: (context) => _CurrencyInfoPage(currency: currency),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).currencySelection),
      ),
      body: Scrollbar(
        child: ListView.builder(
          itemCount: currencies.length,
          itemBuilder: (BuildContext context, index) =>
              buildCurrency(context, currencies[index]),
        ),
      ),
    );
  }

  Widget buildCurrency(BuildContext context, Currency currency) {
    return ListTile(
      title: Text(currency.symbol),
      subtitle: Text(currency.name),
      trailing: IconButton(
        icon: Icon(Icons.info_outline),
        onPressed: () => onSelectedCurrencyInfo(context, currency),
      ),
      onTap: () => onSelectedCurrency(context, currency),
    );
  }
}

class _CurrencyInfoPage extends StatelessWidget {
  final Currency currency;

  const _CurrencyInfoPage({Key key, this.currency}) : super(key: key);

  onSelectedOpenWiki() async {
    if (await canLaunch(currency.wikiUrl))
      await launch(currency.wikiUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${currency.symbol} - ${currency.name}"),
      ),
      body: ListView(children: [
        ListTile(
          title: Text(AppLocalizations.of(context).currencySymbol),
          subtitle: Text(currency.symbol),
        ),
        Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context).currencyName),
          subtitle: Text(currency.name),
        ),
        Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context).currencyDecimalPlaces),
          subtitle: Text(currency.decimalPlaces.toString()),
        ),
        Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context).currencyISO4217Number),
          subtitle: Text(currency.isoNumber),
        ),
        Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context).currencyExamples),
          subtitle: Text(currencyExamples()),
          isThreeLine: true,
        ),
        Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context).currencyWiki),
          subtitle: Text(
            currency.wikiUrl,
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          onTap: () => onSelectedOpenWiki(),
        ),
      ]),
    );
  }

  String currencyExamples() {
    String locale = currency.locales.first;
    String text = NumberFormat.simpleCurrency(locale: locale).format(1234.456);
    text += "\n";
    text += NumberFormat.compactSimpleCurrency(locale: locale).format(1234.456);
    text += "\n";
    text += NumberFormat.compactCurrency(locale: locale).format(1234.456);
    return text;
  }
}
