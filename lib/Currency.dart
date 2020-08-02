

class Currency {

  /// Symbol eg. "USD"
  final String symbol;

  /// Number in ISO 4217 eg. "840"
  final String isoNumber;

  /// Number of decimal places eg. 2
  final int decimalPlaces;

  /// Name of currency eg. "United States dollar"
  final String name;

  /// List of locales that uses this currency, eg. "en_US"
  final List<String> locales;

  /// The url to wikipedia about this currency, eg. "https://en.wikipedia.org/wiki/United_States_dollar"
  String wikiUrl;

  Currency(
      this.symbol, this.isoNumber, this.decimalPlaces, this.name, this.locales,
      {String wikiUrl})
      : this.wikiUrl = wikiUrl ??
            "https://wikipedia.org/wiki/${name.replaceAll(" ", "_")}";

  factory Currency.fromSymbol(String symbol) {
    // TODO: Optimize by map
    return all.firstWhere((currency) => currency.symbol == symbol);
  }

  static final AFN = Currency("AFN", "971", 2, "Afghan afghani", ["ps"]);
  static final ALL = Currency("ALL", "8", 2, "Albanian lek", ["sq"]);
  static final AMD = Currency("AMD", "51", 2, "Armenian dram", ["hy"]);
  static final AUD = Currency("AUD", "36", 2, "Australian dollar", ["en_AU"]);
  static final AZN = Currency("AZN", "944", 2, "Azerbaijani manat", ["az"]);
  static final BAM = Currency("BAM", "977", 2, "Bosnia and Herzegovina convertible mark", ["bs"]);
  static final BDT = Currency("BDT", "50", 2, "Bangladeshi taka", ["bn"]);
  static final BGN = Currency("BGN", "975", 2, "Bulgarian lev", ["bg"]);
  static final BRL = Currency("BRL", "986", 2, "Brazilian real", ["pt", "pt_BR"]);
  static final BYN = Currency("BYN", "933", 2, "Belarusian ruble", ["be"]);
  static final CAD = Currency("CAD", "124", 2, "Canadian dollar", ["en_CA", "fr_CA"]);
  static final CDF = Currency("CDF", "976", 2, "Congolese franc", ["ln"]);
  static final CHF = Currency("CHF", "756", 2, "Swiss franc", ["de_CH", "fr_CH", "gsw", "it_CH"]);
  static final CNY = Currency("CNY", "156", 2, "Chinese yuan", ["zh", "zh_CN"]);
  static final CZK = Currency("CZK", "203", 2, "Czech koruna", ["cs"]);
  static final DKK = Currency("DKK", "208", 2, "Danish krone", ["da"]);
  static final DZD = Currency("DZD", "12", 2, "Algerian dinar", ["ar_DZ"]);
  static final EGP = Currency("EGP", "818", 2, "Egyptian pound", ["ar", "ar_EG"]);
  static final ETB = Currency("ETB", "230", 2, "Ethiopian birr", ["am"]);
  static final EUR = Currency("EUR", "978", 2, "Euro", ["br", "ca", "de", "de_AT", "el", "en_IE", "es", "es_ES", "et", "eu", "fi", "fr", "ga", "gl", "it", "lt", "lv", "mt", "nl", "pt_PT", "sk", "sl"]);
  static final GBP = Currency("GBP", "826", 2, "Pound sterling", ["cy", "en_GB"]);
  static final GEL = Currency("GEL", "981", 2, "Georgian lari", ["ka"]);
  static final HKD = Currency("HKD", "344", 2, "Hong Kong dollar", ["zh_HK"]);
  static final HRK = Currency("HRK", "191", 2, "Croatian kuna", ["hr"]);
  static final HUF = Currency("HUF", "348", 2, "Hungarian forint", ["hu"]);
  static final IDR = Currency("IDR", "360", 2, "Indonesian rupiah", ["id", "in"]);
  static final ILS = Currency("ILS", "376", 2, "Israeli new shekel", ["he", "iw"]);
  static final INR = Currency("INR", "356", 2, "Indian rupee", ["en_IN", "gu", "hi", "kn", "ml", "mr", "or", "pa", "ta", "te"]);
  static final IRR = Currency("IRR", "364", 2, "Iranian rial", ["fa"]);
  static final ISK = Currency("ISK", "352", 0, "Icelandic króna", ["is"]);
  static final JPY = Currency("JPY", "392", 0, "Japanese yen", ["ja"]);
  static final KGS = Currency("KGS", "417", 2, "Kyrgyzstani som", ["ky"]);
  static final KHR = Currency("KHR", "116", 2, "Cambodian riel", ["km"]);
  static final KRW = Currency("KRW", "410", 0, "South Korean won", ["ko"]);
  static final KZT = Currency("KZT", "398", 2, "Kazakhstani tenge", ["kk"]);
  static final LAK = Currency("LAK", "418", 2, "Lao kip", ["lo"]);
  static final LKR = Currency("LKR", "144", 2, "Sri Lankan rupee", ["si"]);
  static final MKD = Currency("MKD", "807", 2, "Macedonian denar", ["mk"]);
  static final MMK = Currency("MMK", "104", 2, "Myanmar kyat", ["my"]);
  static final MNT = Currency("MNT", "496", 2, "Mongolian tögrög", ["mn"]);
  static final MXN = Currency("MXN", "484", 2, "Mexican peso", ["es_419", "es_MX"]);
  static final MYR = Currency("MYR", "458", 2, "Malaysian ringgit", ["en_MY", "ms"]);
  static final NOK = Currency("NOK", "578", 2, "Norwegian krone", ["nb", "no", "no_NO"]);
  static final NPR = Currency("NPR", "524", 2, "Nepalese rupee", ["ne"]);
  static final PHP = Currency("PHP", "608", 2, "Philippine peso", ["fil", "tl"]);
  static final PKR = Currency("PKR", "586", 2, "Pakistani rupee", ["ur"]);
  static final PLN = Currency("PLN", "985", 2, "Polish złoty", ["pl"]);
  static final CBL = Currency("CBL", null, 2, "Cebuliony", ["pl"], wikiUrl: "https://www.miejski.pl/slowo-Cebuliony");
  static final RON = Currency("RON", "946", 2, "Romanian leu", ["ro"]);
  static final RSD = Currency("RSD", "941", 2, "Serbian dinar", ["sr", "sr_Latn"]);
  static final RUB = Currency("RUB", "643", 2, "Russian ruble", ["ru"]);
  static final SEK = Currency("SEK", "752", 2, "Swedish krona/kronor", ["sv"]);
  static final SGD = Currency("SGD", "702", 2, "Singapore dollar", ["en_SG"]);
  static final THB = Currency("THB", "764", 2, "Thai baht", ["th"]);
  static final TRY = Currency("TRY", "949", 2, "Turkish lira", ["tr"]);
  static final TWD = Currency("TWD", "901", 2, "New Taiwan dollar", ["zh_TW"]);
  static final TZS = Currency("TZS", "834", 2, "Tanzanian shilling", ["sw"]);
  static final UAH = Currency("UAH", "980", 2, "Ukrainian hryvnia", ["uk"]);
  static final USD = Currency("USD", "840", 2, "United States dollar", ["chr", "en", "en_US", "es_US", "haw"]);
  static final UZS = Currency("UZS", "860", 2, "Uzbekistan som", ["uz"]);
  static final VND = Currency("VND", "704", 0, "Vietnamese đồng", ["vi"]);


  static final all = [
    AFN, ALL, AMD, AUD, AZN, BAM, BDT, BGN, BRL, BYN, CAD, CDF, CHF, CNY, CZK,
    DKK, DZD, EGP, ETB, EUR, GBP, GEL, HKD, HRK, HUF, IDR, ILS, INR, IRR, ISK,
    JPY, KGS, KHR, KRW, KZT, LAK, LKR, MKD, MMK, MNT, MXN, MYR, NOK, NPR, PHP,
    PKR, PLN, CBL, RON, RSD, RUB, SEK, SGD, THB, TRY, TWD, TZS, UAH, USD, UZS, VND,
  ];
}