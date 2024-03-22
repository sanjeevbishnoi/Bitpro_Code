
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';

double get bitproLogoFontSize => engSelectedLanguage ? 34 : 34;
double get appToastFontSize => engSelectedLanguage ? 15 : 15;
double get appLodingTextSize => engSelectedLanguage ? 20 : 20;

//for english font - used in app
class EnglishAppFonts {
  String fontFamily = 'englishFont';
  double extraLargeFontSize = 15;
  double largeFontSize = 15;
  double mediumFontSize = 14; //default font size
  double smallFontSize = 10;
  // double extraSmallFontSize = 10;
}

// ------------------------------------
//for Arabic font - used in app
class ArabicAppFonts {
  String fontFamily = 'englishFont';
  double extraLargeFontSize = 20;
  double largeFontSize = 18;
  double mediumFontSize = 13; //default font size
  double smallFontSize = 13;
  // double extraSmallFontSize = 10;
}

// -------------------------------------
//for Print english font
class EnglishPrintFonts {
  String fontfamily = 'printesc';
  double extraLargeFontSize = 20;
  double largeFontSize = 18;
  double mediumFontSize = 10; //default font size
  double smallFontSize = 14;
  double extraSmallFontSize = 14;
}

// ------------------------------------
//for Print Arabic font
class ArabicPrintFonts {
  String fontfamily = 'englishFont';
  double extraLargeFontSize = 12;
  double largeFontSize = 10;
  double mediumFontSize = 10; //default font size
  double smallFontSize = 10;
  double extraSmallFontSize = 14;
}
// -------------------------------------

double get getExtraLargeFontSize => engSelectedLanguage
    ? EnglishAppFonts().extraLargeFontSize
    : ArabicAppFonts().extraLargeFontSize;

double get getLargeFontSize => engSelectedLanguage
    ? EnglishAppFonts().largeFontSize
    : ArabicAppFonts().largeFontSize;

double get getMediumFontSize => engSelectedLanguage
    ? EnglishAppFonts().mediumFontSize
    : ArabicAppFonts().mediumFontSize;

double get getSmallFontSize => engSelectedLanguage
    ? EnglishAppFonts().smallFontSize
    : ArabicAppFonts().smallFontSize;

// -------------------------------------

// double get getPrintExtraLargeFontSize => engSelectedLanguage
//     ? EnglishPrintFonts().extraLargeFontSize
//     : ArabicPrintFonts().extraLargeFontSize; //20

// double get getPrintLargeFontSize => engSelectedLanguage
//     ? EnglishPrintFonts().largeFontSize
//     : ArabicPrintFonts().largeFontSize; //18

// double get getPrintMediumFontSize => engSelectedLanguage
//     ? EnglishPrintFonts().mediumFontSize
//     : ArabicPrintFonts().mediumFontSize; //14

// double get getPrintSmallFontSize => engSelectedLanguage
//     ? EnglishPrintFonts().smallFontSize
//     : ArabicPrintFonts().smallFontSize; //12

// double get getPrintExtraSmallFontSize => engSelectedLanguage
//     ? EnglishPrintFonts().extraSmallFontSize
//     : ArabicPrintFonts().extraSmallFontSize; //10
