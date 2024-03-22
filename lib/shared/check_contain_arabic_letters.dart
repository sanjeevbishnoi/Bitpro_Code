  bool containsExtendedArabic(String input) {
    // Define a regular expression pattern for the extended range of Arabic characters
    RegExp extendedArabicPattern = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\uFB50-\uFC3F\uFE70-\uFEFC]',
    );

    // Use the RegExp `any` method to check if the input string contains any extended Arabic characters
    return extendedArabicPattern.hasMatch(input);
  }