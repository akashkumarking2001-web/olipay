class Translations {
  static final Map<String, Map<String, String>> _data = {
    'en-IN': {
      'title': 'Customize Your Experience',
      'subtitle': 'Choose your preferred language for the app and voice alerts.',
      'app_lang': 'App Interface Language',
      'voice_lang': 'Voice Notification Language',
      'save_continue': 'Save & Continue',
      'shop_name': 'Shop / Business Name',
      'mobile_number': 'Mobile Number',
      'enter_pin': 'Enter 4-Digit PIN',
      'create_account': 'Create Account',
      'welcome_back': 'Welcome Back!',
      'login': 'Login',
      'register': 'Register',
    },
    'ta-IN': {
      'title': 'உங்கள் அனுபவத்தைத் தனிப்பயனாக்குங்கள்',
      'subtitle': 'பயன்பாடு மற்றும் குரல் விழிப்பூட்டல்களுக்கு உங்களுக்கு விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்.',
      'app_lang': 'பயன்பாட்டு இடைமுக மொழி',
      'voice_lang': 'குரல் அறிவிப்பு மொழி',
      'save_continue': 'சேமித்து தொடரவும்',
      'shop_name': 'கடை / வணிக பெயர்',
      'mobile_number': 'கைபேசி எண்',
      'enter_pin': '4-இலக்க பின்னை உள்ளிடவும்',
      'create_account': 'கணக்கை உருவாக்கு',
      'welcome_back': 'மீண்டும் வருக!',
      'login': 'உள்நுழைய',
      'register': 'பதிவு செய்',
    },
    // Add other languages as needed
  };

  static String get(String key, String langCode) {
    return _data[langCode]?[key] ?? _data['en-IN']![key]!;
  }
}
