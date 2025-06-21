// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get flashcardTitle => 'Flashcards';

  @override
  String get loadingFlashcards => 'Loading flashcards...';

  @override
  String get noFlashcardsAvailable => 'No flashcards available for this topic';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get flipCard => 'Tap to flip';

  @override
  String get nextCard => 'Next';

  @override
  String get previousCard => 'Previous';

  @override
  String cardCountOf(int current, int total) {
    return 'Card $current of $total';
  }
}
