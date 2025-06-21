// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get flashcardTitle => 'بطاقات تعليمية';

  @override
  String get loadingFlashcards => 'جاري تحميل البطاقات التعليمية...';

  @override
  String get noFlashcardsAvailable =>
      'لا توجد بطاقات تعليمية متاحة لهذا الموضوع';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get flipCard => 'انقر للقلب';

  @override
  String get nextCard => 'التالي';

  @override
  String get previousCard => 'السابق';

  @override
  String cardCountOf(int current, int total) {
    return 'البطاقة $current من $total';
  }
}
