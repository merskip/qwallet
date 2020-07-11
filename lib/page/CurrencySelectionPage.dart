import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Currency.dart';

class CurrencySelectionPage extends StatefulWidget {

  final Currency selectedCurrency;

  const CurrencySelectionPage({Key key, this.selectedCurrency}) : super(key: key);

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
    final bool hasSelectedCurrency = (widget.selectedCurrency != null);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).selectCurrency),
      ),
      body: Scrollbar(
        child: ListView.builder(
          itemCount: currencies.length + (hasSelectedCurrency != null ? 2 : 0),
          itemBuilder: (BuildContext context, index) {
            if (hasSelectedCurrency) {
              if (index == 0)
                return buildCurrency(context, widget.selectedCurrency,
                    selected: true);
              else if (index == 1)
                return Divider();
              else
                index -= 2;
            }
            return buildCurrency(context, currencies[index]);
          },
        ),
      ),
    );
  }

  Widget buildCurrency(BuildContext context, Currency currency,
      {bool selected = false}) {
    return ListTile(
      title: Text(currency.symbol),
      subtitle: Text(currency.name),
      trailing: IconButton(
        icon: Icon(Icons.info_outline),
        onPressed: () => onSelectedCurrencyInfo(context, currency),
      ),
      onTap: () => onSelectedCurrency(context, currency),
      selected: selected,
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
          title: Text(AppLocalizations.of(context).selectCurrencySymbol),
          subtitle: Text(currency.symbol),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).selectCurrencyName),
          subtitle: Text(currency.name),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).selectCurrencyDecimalPlaces),
          subtitle: Text(currency.decimalPlaces.toString()),
        ),
        if (currency.isoNumber != null)
          ListTile(
            title: Text(AppLocalizations.of(context).selectCurrencyISO4217Number),
            subtitle: Text(currency.isoNumber),
          ),
        ListTile(
          title: Text(AppLocalizations.of(context).selectCurrencyExamples),
          subtitle: Text(currencyExamples()),
          isThreeLine: true,
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).selectCurrencyWiki),
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
