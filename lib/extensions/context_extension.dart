import 'package:ampheria/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this)!;
}