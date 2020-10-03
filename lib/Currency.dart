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

  // ignore: non_constant_identifier_names
  static final AFN = Currency("AFN", "971", 2, "Afghan afghani", ["ps"]);
  // ignore: non_constant_identifier_names
  static final ALL = Currency("ALL", "8", 2, "Albanian lek", ["sq"]);
  // ignore: non_constant_identifier_names
  static final AMD = Currency("AMD", "51", 2, "Armenian dram", ["hy"]);
  // ignore: non_constant_identifier_names
  static final AUD = Currency("AUD", "36", 2, "Australian dollar", ["en_AU"]);
  // ignore: non_constant_identifier_names
  static final AZN = Currency("AZN", "944", 2, "Azerbaijani manat", ["az"]);
  // ignore: non_constant_identifier_names
  static final BAM = Currency(
      "BAM", "977", 2, "Bosnia and Herzegovina convertible mark", ["bs"]);
  // ignore: non_constant_identifier_names
  static final BDT = Currency("BDT", "50", 2, "Bangladeshi taka", ["bn"]);
  // ignore: non_constant_identifier_names
  static final BGN = Currency("BGN", "975", 2, "Bulgarian lev", ["bg"]);
  // ignore: non_constant_identifier_names
  static final BRL =
      Currency("BRL", "986", 2, "Brazilian real", ["pt", "pt_BR"]);
  // ignore: non_constant_identifier_names
  static final BYN = Currency("BYN", "933", 2, "Belarusian ruble", ["be"]);
  // ignore: non_constant_identifier_names
  static final CAD =
      Currency("CAD", "124", 2, "Canadian dollar", ["en_CA", "fr_CA"]);
  // ignore: non_constant_identifier_names
  static final CDF = Currency("CDF", "976", 2, "Congolese franc", ["ln"]);
  // ignore: non_constant_identifier_names
  static final CHF = Currency(
      "CHF", "756", 2, "Swiss franc", ["de_CH", "fr_CH", "gsw", "it_CH"]);
  // ignore: non_constant_identifier_names
  static final CNY = Currency("CNY", "156", 2, "Chinese yuan", ["zh", "zh_CN"]);
  // ignore: non_constant_identifier_names
  static final CZK = Currency("CZK", "203", 2, "Czech koruna", ["cs"]);
  // ignore: non_constant_identifier_names
  static final DKK = Currency("DKK", "208", 2, "Danish krone", ["da"]);
  // ignore: non_constant_identifier_names
  static final DZD = Currency("DZD", "12", 2, "Algerian dinar", ["ar_DZ"]);
  // ignore: non_constant_identifier_names
  static final EGP =
      Currency("EGP", "818", 2, "Egyptian pound", ["ar", "ar_EG"]);
  // ignore: non_constant_identifier_names
  static final ETB = Currency("ETB", "230", 2, "Ethiopian birr", ["am"]);
  // ignore: non_constant_identifier_names
  static final EUR = Currency("EUR", "978", 2, "Euro", [
    "br",
    "ca",
    "de",
    "de_AT",
    "el",
    "en_IE",
    "es",
    "es_ES",
    "et",
    "eu",
    "fi",
    "fr",
    "ga",
    "gl",
    "it",
    "lt",
    "lv",
    "mt",
    "nl",
    "pt_PT",
    "sk",
    "sl"
  ]);
  // ignore: non_constant_identifier_names
  static final GBP =
      Currency("GBP", "826", 2, "Pound sterling", ["cy", "en_GB"]);
  // ignore: non_constant_identifier_names
  static final GEL = Currency("GEL", "981", 2, "Georgian lari", ["ka"]);
  // ignore: non_constant_identifier_names
  static final HKD = Currency("HKD", "344", 2, "Hong Kong dollar", ["zh_HK"]);
  // ignore: non_constant_identifier_names
  static final HRK = Currency("HRK", "191", 2, "Croatian kuna", ["hr"]);
  // ignore: non_constant_identifier_names
  static final HUF = Currency("HUF", "348", 2, "Hungarian forint", ["hu"]);
  // ignore: non_constant_identifier_names
  static final IDR =
      Currency("IDR", "360", 2, "Indonesian rupiah", ["id", "in"]);
  // ignore: non_constant_identifier_names
  static final ILS =
      Currency("ILS", "376", 2, "Israeli new shekel", ["he", "iw"]);
  // ignore: non_constant_identifier_names
  static final INR = Currency("INR", "356", 2, "Indian rupee",
      ["en_IN", "gu", "hi", "kn", "ml", "mr", "or", "pa", "ta", "te"]);
  // ignore: non_constant_identifier_names
  static final IRR = Currency("IRR", "364", 2, "Iranian rial", ["fa"]);
  // ignore: non_constant_identifier_names
  static final ISK = Currency("ISK", "352", 0, "Icelandic króna", ["is"]);
  // ignore: non_constant_identifier_names
  static final JPY = Currency("JPY", "392", 0, "Japanese yen", ["ja"]);
  // ignore: non_constant_identifier_names
  static final KGS = Currency("KGS", "417", 2, "Kyrgyzstani som", ["ky"]);
  // ignore: non_constant_identifier_names
  static final KHR = Currency("KHR", "116", 2, "Cambodian riel", ["km"]);
  // ignore: non_constant_identifier_names
  static final KRW = Currency("KRW", "410", 0, "South Korean won", ["ko"]);
  // ignore: non_constant_identifier_names
  static final KZT = Currency("KZT", "398", 2, "Kazakhstani tenge", ["kk"]);
  // ignore: non_constant_identifier_names
  static final LAK = Currency("LAK", "418", 2, "Lao kip", ["lo"]);
  // ignore: non_constant_identifier_names
  static final LKR = Currency("LKR", "144", 2, "Sri Lankan rupee", ["si"]);
  // ignore: non_constant_identifier_names
  static final MKD = Currency("MKD", "807", 2, "Macedonian denar", ["mk"]);
  // ignore: non_constant_identifier_names
  static final MMK = Currency("MMK", "104", 2, "Myanmar kyat", ["my"]);
  // ignore: non_constant_identifier_names
  static final MNT = Currency("MNT", "496", 2, "Mongolian tögrög", ["mn"]);
  // ignore: non_constant_identifier_names
  static final MXN =
      Currency("MXN", "484", 2, "Mexican peso", ["es_419", "es_MX"]);
  // ignore: non_constant_identifier_names
  static final MYR =
      Currency("MYR", "458", 2, "Malaysian ringgit", ["en_MY", "ms"]);
  // ignore: non_constant_identifier_names
  static final NOK =
      Currency("NOK", "578", 2, "Norwegian krone", ["nb", "no", "no_NO"]);
  // ignore: non_constant_identifier_names
  static final NPR = Currency("NPR", "524", 2, "Nepalese rupee", ["ne"]);
  // ignore: non_constant_identifier_names
  static final PHP =
      Currency("PHP", "608", 2, "Philippine peso", ["fil", "tl"]);
  // ignore: non_constant_identifier_names
  static final PKR = Currency("PKR", "586", 2, "Pakistani rupee", ["ur"]);
  // ignore: non_constant_identifier_names
  static final PLN = Currency("PLN", "985", 2, "Polish złoty", ["pl"]);
  // ignore: non_constant_identifier_names
  static final CBL = Currency("CBL", null, 2, "Cebuliony", ["pl"],
      wikiUrl: "https://www.miejski.pl/slowo-Cebuliony");
  // ignore: non_constant_identifier_names
  static final RON = Currency("RON", "946", 2, "Romanian leu", ["ro"]);
  // ignore: non_constant_identifier_names
  static final RSD =
      Currency("RSD", "941", 2, "Serbian dinar", ["sr", "sr_Latn"]);
  // ignore: non_constant_identifier_names
  static final RUB = Currency("RUB", "643", 2, "Russian ruble", ["ru"]);
  // ignore: non_constant_identifier_names
  static final SEK = Currency("SEK", "752", 2, "Swedish krona/kronor", ["sv"]);
  // ignore: non_constant_identifier_names
  static final SGD = Currency("SGD", "702", 2, "Singapore dollar", ["en_SG"]);
  // ignore: non_constant_identifier_names
  static final THB = Currency("THB", "764", 2, "Thai baht", ["th"]);
  // ignore: non_constant_identifier_names
  static final TRY = Currency("TRY", "949", 2, "Turkish lira", ["tr"]);
  // ignore: non_constant_identifier_names
  static final TWD = Currency("TWD", "901", 2, "New Taiwan dollar", ["zh_TW"]);
  // ignore: non_constant_identifier_names
  static final TZS = Currency("TZS", "834", 2, "Tanzanian shilling", ["sw"]);
  // ignore: non_constant_identifier_names
  static final UAH = Currency("UAH", "980", 2, "Ukrainian hryvnia", ["uk"]);
  // ignore: non_constant_identifier_names
  static final USD = Currency("USD", "840", 2, "United States dollar",
      ["chr", "en", "en_US", "es_US", "haw"]);
  // ignore: non_constant_identifier_names
  static final UZS = Currency("UZS", "860", 2, "Uzbekistan som", ["uz"]);
  // ignore: non_constant_identifier_names
  static final VND = Currency("VND", "704", 0, "Vietnamese đồng", ["vi"]);

  static final all = [
    AFN,
    ALL,
    AMD,
    AUD,
    AZN,
    BAM,
    BDT,
    BGN,
    BRL,
    BYN,
    CAD,
    CDF,
    CHF,
    CNY,
    CZK,
    DKK,
    DZD,
    EGP,
    ETB,
    EUR,
    GBP,
    GEL,
    HKD,
    HRK,
    HUF,
    IDR,
    ILS,
    INR,
    IRR,
    ISK,
    JPY,
    KGS,
    KHR,
    KRW,
    KZT,
    LAK,
    LKR,
    MKD,
    MMK,
    MNT,
    MXN,
    MYR,
    NOK,
    NPR,
    PHP,
    PKR,
    PLN,
    CBL,
    RON,
    RSD,
    RUB,
    SEK,
    SGD,
    THB,
    TRY,
    TWD,
    TZS,
    UAH,
    USD,
    UZS,
    VND,
  ];
}
