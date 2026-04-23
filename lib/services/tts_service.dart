import 'package:flutter_tts/flutter_tts.dart';
import '../models/payment_info.dart';
import '../utils/number_to_words.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> speakPayment(PaymentInfo payment, String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
    
    // Attempt to convert amount to words, fallback to digit representation safely.
    String amountStr = NumberToWords.convert(payment.amount.toInt(), languageCode);
    
    String announcement = '';
    
    switch (languageCode) {
      case 'ta-IN':
        announcement = "${payment.appName} மூலம் ${payment.senderName} இடமிருந்து $amountStr ரூபாய் பெறப்பட்டது";
        break;
      case 'hi-IN':
        announcement = "${payment.appName} पर ${payment.senderName} से $amountStr रुपये प्राप्त हुए";
        break;
      case 'te-IN':
        announcement = "${payment.appName} ద్వారా ${payment.senderName} నుండి $amountStr రూపాయలు అందుకున్నారు";
        break;
      case 'ml-IN':
        announcement = "${payment.appName} വഴി ${payment.senderName} ൽ നിന്ന് $amountStr രൂപ ലഭിച്ചു";
        break;
      case 'en-IN':
      default:
        announcement = "₹$amountStr received from ${payment.senderName} on ${payment.appName}";
        break;
    }

    await _flutterTts.speak(announcement);
  }

  Future<void> testSpeak(String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
    String testText = "Test announcement ready";
    if (languageCode == 'ta-IN') testText = "சோதனை அறிவிப்பு தயார்";
    if (languageCode == 'hi-IN') testText = "परीक्षण घोषणा तैयार है";
    if (languageCode == 'te-IN') testText = "పరీక్షా ప్రకటన సిద్ధంగా ఉంది";
    if (languageCode == 'ml-IN') testText = "പരിശോധനാ അറിയിപ്പ് തയ്യാറാണ്";
    
    await _flutterTts.speak(testText);
  }

  Future<void> updateSettings({double? rate, double? volume}) async {
    if (rate != null) await _flutterTts.setSpeechRate(rate);
    if (volume != null) await _flutterTts.setVolume(volume);
  }
}
