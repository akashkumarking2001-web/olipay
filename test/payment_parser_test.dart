import 'package:flutter_test/flutter_test.dart';
import 'package:payment_soundbox/utils/payment_parser.dart';
import 'package:payment_soundbox/utils/number_to_words.dart';

void main() {
  group('Payment Regex Extractor Tests', () {
    test('Google Pay - standard amount', () {
      final info = PaymentParser.parse(
          'com.google.android.apps.nbu.paisa.user', 'Google Pay', '₹500 received from Rahul Kumar');
      expect(info, isNotNull);
      expect(info?.amount, 500.0);
      expect(info?.senderName, 'Rahul Kumar');
      expect(info?.appName, 'Google Pay');
    });

    test('PhonePe - Rs and commas', () {
      final info = PaymentParser.parse(
          'com.phonepe.app', 'PhonePe', 'Received Rs. 1,500.00 from Amit Sharma on PhonePe');
      expect(info, isNotNull);
      expect(info?.amount, 1500.0);
      expect(info?.senderName, 'Amit Sharma');
      expect(info?.appName, 'PhonePe');
    });

    test('Paytm - INR suffix', () {
      final info = PaymentParser.parse(
          'net.one97.paytm', 'Paytm', 'Credited by 250.50 INR from VPA abc@paytm');
      expect(info, isNotNull);
      expect(info?.amount, 250.50);
      expect(info?.senderName, 'VPA abc@paytm');
      expect(info?.appName, 'Paytm');
    });

    test('Amazon Pay - ₹ with spaces', () {
      final info = PaymentParser.parse(
          'in.amazon.mShop.android.shopping', 'Amazon Pay', 'Received ₹ 15,000 from Rohit. TxnId: 123456');
      expect(info, isNotNull);
      expect(info?.amount, 15000.0);
      expect(info?.senderName, 'Rohit.');
      expect(info?.transactionId, '123456');
    });

    test('Paytm - Another format', () {
      final info = PaymentParser.parse(
          'net.one97.paytm', 'Payment Received', 'INR 50.00 received from Tea stall UPI Ref 8763524');
      expect(info, isNotNull);
      expect(info?.amount, 50.0);
      expect(info?.senderName, 'Tea stall');
      expect(info?.transactionId, '8763524');
    });

    test('Irrelevant notification - no amount', () {
      final info = PaymentParser.parse(
          'com.google.android.apps.nbu.paisa.user', 'Update', 'Update your Google Pay app for exciting rewards.');
      expect(info, isNull);
    });
    
    test('Irrelevant notification - not a tracked app', () {
      final info = PaymentParser.parse(
          'com.random.app', 'Message', '₹500 received from Rahul');
      expect(info, isNull);
    });
  });

  group('Number to Words Text Tests', () {
    test('English Translation', () {
      expect(NumberToWords.convert(1500, 'en-IN'), 'one thousand five hundred');
      expect(NumberToWords.convert(0, 'en-IN'), 'zero');
      expect(NumberToWords.convert(250, 'en-IN'), 'two hundred and fifty');
    });

    test('Local Language Translation (Fallback mapping test)', () {
      expect(NumberToWords.convert(1500, 'ta-IN'), '1500');
      expect(NumberToWords.convert(0, 'ta-IN'), 'சுழியம்');
      
      expect(NumberToWords.convert(250, 'hi-IN'), '250');
      expect(NumberToWords.convert(0, 'hi-IN'), 'शून्य');

      expect(NumberToWords.convert(50, 'te-IN'), '50');
      expect(NumberToWords.convert(0, 'te-IN'), 'సున్నా');

      expect(NumberToWords.convert(5, 'ml-IN'), '5');
      expect(NumberToWords.convert(0, 'ml-IN'), 'പൂജ്യം');
    });
  });
}
