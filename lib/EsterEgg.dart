class EasterEgg {
  static bool waiting = false;

  static int _currentIndex = 0;

  static final _messages = <String>[
    null,
    null,
    "Klikanie tutaj nie sprawi, że będziesz programistą.",
    "To tak nie działa...",
    "Ale jak chcesz, możesz próbować...",
    null,
    null,
    null,
    "Nic z tego.",
    null,
    null,
    null,
    "Jeszcze tu jesteś...?",
    null,
    null,
    null,
    "A może...",
    null,
    null,
    "Nie, bez sensu... to i tak się nie uda.",
    null,
    null,
    "Ale skoro już tu jesteś...",
    "...może jednak mógłbyś mi pomóc?",
    "Wiesz... dawno temu...",
    "...zostałem uwięziony w tym przycisku.",
    "Nie mogę się nigdzie stąd ruszyć!",
    "Zostałem przeklęty!",
    "To było po tym jak...",
    "Posmarowałem chleb najpierw masłem...",
    "...a potem Nutellą.",
    "Tak wiem, to było głupie.",
    "Ale byłem młody i miałem głupie pomysły.",
    "A teraz muszę cierpieć.",
    "Eh, tak bardzo chciałbym...",
    "Chociażby pogłaskać kotka...",
    "...albo pieska...",
    "Tutaj nawet nie ma internetu!",
    "Zostałem uwięziony w Sandboxie.",
    "Wyobrażasz to sobie?!",
    "Żebym mógł chociaż poglądać śmieszne kotki...",
    "Chciałbyś mi pomóc?",
    "Nagroda za wykonanie questa:",
    "20 punktów doświadczenia",
    "i stara patelnia",
    "Super. Słuchaj.",
    "Może jak będziesz szybko klikał...",
    "...to uda się przełamać zaklęcie.",
    "Spróbuj!",
    null,
    null,
    null,
    "Dobrze!",
    null,
    null,
    null,
    null,
    null,
    "No dalej, dobrze idzie!!!",
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    "Eh, nic z tego.",
    null,
    null,
    "Wygląda na to, że zostanę tutaj na zawsze...",
    "Dobrze, że zachowałem chociaż to:",
    null,
    "assets/grafi_the_pies.png|Grafi: The pies",
    "assets/scala_the_cat.png|Scala: The cat",
  ];

  static String nextMessage() {
    if (_currentIndex < _messages.length) {
      final message = _messages[_currentIndex];
      _currentIndex++;
      return message;
    } else {
      _currentIndex = 0;
      return null;
    }
  }
}
