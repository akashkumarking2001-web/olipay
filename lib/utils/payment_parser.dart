import '../models/payment_info.dart';

class PaymentParser {
  /// Map of package names to human-readable App Names as specified in the requirements.
  static final Map<String, String> packageMap = {
    'com.google.android.apps.nbu.paisa.user': 'Google Pay',
    'com.phonepe.app': 'PhonePe',
    'net.one97.paytm': 'Paytm',
    'in.amazon.mShop.android.shopping': 'Amazon Pay',
    'in.org.npci.upiapp': 'BHIM',
    'com.sbi.lotusintouch': 'SBI YONO',
    'com.snapwork.hdfc': 'HDFC MobileBanking',
    'com.csam.icici.bank.imobile': 'ICICI iMobile',
    'com.axis.mobile': 'Axis Mobile',
    'com.msf.konyapplication': 'Kotak Mobile',
    'com.indusind.mobilebanking': 'IndusInd Indus Mobile',
    'com.bsb.mobilebanking': 'Bank of Baroda',
    'com.canara.bank': 'Canara Bank',
    'com.unionbank.ecommerce.mobile.android': 'Union Bank',
    'com.pnb.mobilebanking': 'Punjab National Bank',
    'com.federalbank.mobile': 'Federal Bank',
    'com.yesbank': 'YES Bank',
    'com.whatsapp': 'WhatsApp Pay',
    'com.nextbillion.groww': 'Groww UPI',
    'com.dreamplug.androidapp': 'CRED Pay',
    'in.islice.app': 'Slice Pay',
    'co.jupiter.app': 'Jupiter',
    'me.fi.app': 'Fi Money',
    'com.mobikwik_new': 'Mobikwik',
    'com.freecharge.android': 'FreeCharge',
    'com.airtelretail.shop': 'Airtel Thanks',
    'com.jio.payment': 'Jio Money',
  };

  /// Parses the notification payload to extract payment details.
  /// Returns null if the notification is not from a tracked package or not related to receiving money.
  static PaymentInfo? parse(String packageName, String title, String text) {
    if (!packageMap.containsKey(packageName)) return null;

    final appName = packageMap[packageName]!;
    final combinedText = '$title $text';

    // Amount extraction: Matches ₹500, Rs. 500, INR 500, 500.00 INR
    final amountRegex = RegExp(r'(?:Rs\.?|INR|₹)\s*([\d,]+\.?\d*)|([\d,]+\.?\d*)\s*(?:INR)', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(combinedText);
    double? extractedAmount;
    
    if (amountMatch != null) {
      String amountStr = amountMatch.group(1) ?? amountMatch.group(2) ?? '0';
      amountStr = amountStr.replaceAll(',', ''); // Clear thousands separators
      extractedAmount = double.tryParse(amountStr);
    }

    // If no amount is detected or amount is zero, this is not a payment received notification
    if (extractedAmount == null || extractedAmount <= 0) {
      return null;
    }

    // Sender extraction: Matches "received from Rahul", "from VPA abc@okicici", "credited by XYZ"
    String senderName = 'Someone';
    final senderRegex = RegExp(r'(?:from|by)\s+([A-Za-z0-9\s@\.]+)');
    final senderMatch = senderRegex.firstMatch(combinedText);
    
    if (senderMatch != null) {
      senderName = senderMatch.group(1)!.trim();
      // Remove trailing text like 'on', 'for', etc.
      final stopWords = [' on ', ' for ', ' ref ', ' txn ', ' UPI'];
      for (var word in stopWords) {
        final idx = senderName.toLowerCase().indexOf(word.toLowerCase());
        if (idx != -1) {
          senderName = senderName.substring(0, idx).trim();
          break;
        }
      }
    }

    // Transaction ID extraction (Optional)
    String? txnId;
    final txnRegex = RegExp(r'(?:TxnId|Ref No|UPI Ref|UTR)(?:\s*[:\-]?\s*)([A-Za-z0-9]+)', caseSensitive: false);
    final txnMatch = txnRegex.firstMatch(combinedText);
    if (txnMatch != null) {
      txnId = txnMatch.group(1)!.trim();
    }

    return PaymentInfo(
      amount: extractedAmount,
      senderName: senderName,
      appName: appName,
      timestamp: DateTime.now(),
      rawText: combinedText,
      transactionId: txnId,
    );
  }
}
