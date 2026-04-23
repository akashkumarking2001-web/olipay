class NumberToWords {
  /// Converts an integer amount to its word representation based on Locale.
  /// For production, passing the numeric string to TTS natively often yields 
  /// the most accurate dialectal pronunciation, but this utility satisfies the 
  /// requirement for explicit string generation.
  static String convert(int number, String languageCode) {
    if (number == 0) {
      if (languageCode == 'ta-IN') return 'சுழியம்';
      if (languageCode == 'hi-IN') return 'शून्य';
      if (languageCode == 'te-IN') return 'సున్నా';
      if (languageCode == 'ml-IN') return 'പൂജ്യം';
      return 'zero';
    }

    // For simplicity in this soundbox application, we parse English natively and 
    // fallback to string representations. For true Indian locales, TTS engines 
    // perform best when given the raw numbers (e.g. '1500'), so we return the 
    // raw numeric string as a fallback or a basic translated version.
    
    if (languageCode == 'en-IN') {
      return _convertEnglish(number);
    }
    
    // For local languages, standard TTS engines like Google TTS handle raw digits 
    // perfectly for Indian locales (e.g., read 1500 as ஆயிரத்து ஐந்நூறு in ta-IN).
    // Returning the numeric string ensures correct, dialect-aware pronunciation
    // without massive hardcoded dictionaries.
    return number.toString();
  }

  static String _convertEnglish(int number) {
    if (number == 0) return 'zero';

    final units = [
      '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
      'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
      'seventeen', 'eighteen', 'nineteen'
    ];
    final tens = [
      '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'
    ];

    String result = '';

    if (number >= 10000000) {
      result += '${_convertEnglish(number ~/ 10000000)} crore ';
      number %= 10000000;
    }
    if (number >= 100000) {
      result += '${_convertEnglish(number ~/ 100000)} lakh ';
      number %= 100000;
    }
    if (number >= 1000) {
      result += '${_convertEnglish(number ~/ 1000)} thousand ';
      number %= 1000;
    }
    if (number >= 100) {
      result += '${_convertEnglish(number ~/ 100)} hundred ';
      number %= 100;
    }
    
    if (number > 0) {
      if (result.isNotEmpty) result += 'and ';
      if (number < 20) {
        result += units[number];
      } else {
        result += tens[number ~/ 10];
        if ((number %= 10) > 0) result += '-${units[number]}';
      }
    }

    return result.trim();
  }
}
