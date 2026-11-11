import 'package:readpack/data/services/auth_api_service.dart';
import 'package:readpack/helper/translation.dart';

String authErrorMessage(Object error, AppLocalizations? localizations) {
  if (error is AuthApiException) {
    final code = error.code;
    if (code != null) {
      final translated = localizations?.t('auth.errors.$code');
      if (translated != null) return translated;
    }
    if (error.statusCode == 0 || error.statusCode >= 500) {
      return localizations?.t('error.network') ?? error.message;
    }
  }
  return localizations?.t('error.generic') ?? error.toString();
}
