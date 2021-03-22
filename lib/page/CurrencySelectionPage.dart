import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/CurrencyList.dart';
import 'package:qwallet/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Currency.dart';
import '../Money.dart';

class CurrencySelectionPage extends StatefulWidget {
  final Currency selectedCurrency;

  const CurrencySelectionPage({Key? key, this.selectedCurrency})
      : super(key: key);

  @override
  _CurrencySelectionPageState createState() => _CurrencySelectionPageState();
}

class _CurrencySelectionPageState extends State<CurrencySelectionPage> {
  final currencies = CurrencyList.all;

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
        child: ListView(
          children: [
            if (hasSelectedCurrency)
              buildCurrency(context, widget.selectedCurrency, selected: true),
            if (hasSelectedCurrency) Divider(),
            ...currencies.map((currency) => buildCurrency(
                  context,
                  currency,
                  selected: widget.selectedCurrency == currency,
                )),
          ],
        ),
      ),
    );
  }

  Widget buildCurrency(BuildContext context, Currency currency,
      {bool selected = false}) {
    return ListTile(
      leading: selected ? Icon(Icons.check) : SizedBox(),
      title: Text(currency.code),
      subtitle: Text(currency.getName(context)),
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

  const _CurrencyInfoPage({Key? key, this.currency}) : super(key: key);

  onSelectedOpenUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currency.getCommonName(context)),
      ),
      body: ListView(children: [
        if (currency.iso4217 != null)
          ListTile(
            title: Text(AppLocalizations.of(context).selectCurrencyISO4217),
            subtitle: Text(currency.iso4217),
          ),
        ListTile(
          title: Text(AppLocalizations.of(context).selectCurrencyCode),
          subtitle: Text(currency.code),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).selectCurrencyName),
          subtitle: Text(currency.getName(context)),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).selectCurrencySymbols),
          subtitle: Text(currency.symbols.join("\n")),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).selectCurrencyExamples),
          subtitle: Text(currencyExamples()),
          isThreeLine: true,
        ),
        if (currency.wikiUrl != null)
          ListTile(
            title: Text(AppLocalizations.of(context).selectCurrencyWiki),
            subtitle: Text(
              currency.wikiUrl,
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () => onSelectedOpenUrl(currency.wikiUrl),
          ),
        if (currency.websiteUrl != null)
          ListTile(
            title: Text(AppLocalizations.of(context).selectCurrencyWebsite),
            subtitle: Text(
              currency.websiteUrl,
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () => onSelectedOpenUrl(currency.websiteUrl),
          ),
      ]),
    );
  }

  String currencyExamples() {
    String text = "";
    text += Money(1234.567, currency).formattedOnlyAmount + "\n";
    text += Money(1234.567, currency).formatted + "\n";
    text += Money(1234.567, currency).formattedWithCode;
    return text;
  }
}
