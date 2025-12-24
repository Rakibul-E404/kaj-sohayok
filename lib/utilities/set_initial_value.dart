import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/helpers/di.dart';

void setInitialLanguagePreference() {
  appData.writeIfNull(kKeyEnglish, true);
  appData.writeIfNull(kKeyBangla, false);
}
