// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get flashcardTitle => 'Kad Imbas';

  @override
  String get loadingFlashcards => 'Memuatkan kad imbas...';

  @override
  String get noFlashcardsAvailable =>
      'Tiada kad imbas tersedia untuk topik ini';

  @override
  String get tryAgain => 'Cuba Lagi';

  @override
  String get flipCard => 'Ketuk untuk membalik';

  @override
  String get nextCard => 'Seterusnya';

  @override
  String get previousCard => 'Sebelumnya';

  @override
  String cardCountOf(int current, int total) {
    return 'Kad $current daripada $total';
  }
}
