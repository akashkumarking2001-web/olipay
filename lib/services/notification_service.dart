import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_info.dart';
import '../utils/payment_parser.dart';
import 'tts_service.dart';
import '../firebase_options.dart';

class NotificationService {
  static final TtsService _ttsService = TtsService();

  /// Initialize the listener
  static void init() {
    if (kIsWeb) {
      print("Notification listener is not supported on Web.");
      return;
    }
    try {
      NotificationsListener.initialize(callbackHandle: _callback);
    } catch (e) {
      print("Failed to initialize notification listener: $e");
    }
  }

  /// Must be a top-level or static function to be spawned in a background isolate.
  @pragma('vm:entry-point')
  static void _callback(NotificationEvent event) async {
    if (event.packageName == null || event.text == null) return;
    
    final lowerText = event.text!.toLowerCase();
    final lowerTitle = (event.title ?? '').toLowerCase();
    
    // Strict Filtering: Only process if it contains "received", "credited", "added", or "sent to you"
    // and EXCLUDE "failed", "pending", "request", "sent" (unless "sent to you")
    final isReceived = lowerText.contains('received') || 
                       lowerText.contains('credited') || 
                       lowerText.contains('added') ||
                       lowerText.contains('sent to you') ||
                       lowerTitle.contains('received');
                       
    final isRejected = lowerText.contains('failed') || 
                       lowerText.contains('pending') || 
                       lowerText.contains('declined') ||
                       lowerText.contains('request');

    if (!isReceived || isRejected) return;
    
    // Check if the notification is from a supported UPI app
    if (!PaymentParser.packageMap.containsKey(event.packageName)) return;

    // Parse the notification payload to a PaymentInfo object
    final payment = PaymentParser.parse(
      event.packageName!, 
      event.title ?? '', 
      event.text ?? ''
    );

    if (payment != null) {
      // 1. Alert user
      bool shouldVibrate = await _shouldVibrate();
      if (shouldVibrate) {
        HapticFeedback.heavyImpact();
      }

      // 2. Read aloud in preferred language
      String lang = await _getSavedLanguage();
      await _ttsService.speakPayment(payment, lang);

      // 3. Store transaction to local storage
      await _saveTransaction(payment);
      
      // 4. Store to Firestore (Background)
      await _syncToFirestore(payment);
    }
  }

  static Future<void> _syncToFirestore(PaymentInfo payment) async {
    try {
      // Initialize Firebase in isolate if not already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .add({
          'amount': payment.amount,
          'senderName': payment.senderName,
          'appName': payment.appName,
          'timestamp': Timestamp.fromDate(payment.timestamp),
          'rawText': payment.rawText,
          'transactionId': payment.transactionId,
        });
      }
    } catch (e) {
      debugPrint("Firestore background sync failed: $e");
    }
  }

  static Future<bool> _shouldVibrate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vibrate_enabled') ?? true;
  }

  static Future<String> _getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_language') ?? 'en-IN';
  }

  static Future<void> _saveTransaction(PaymentInfo payment) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> transactionsRaw = prefs.getStringList('transactions') ?? [];
    
    // Add the new transaction as a JSON string
    transactionsRaw.insert(0, jsonEncode(payment.toJson()));
    
    // Truncate to maximum 50 entries
    if (transactionsRaw.length > 50) {
      transactionsRaw = transactionsRaw.sublist(0, 50);
    }

    await prefs.setStringList('transactions', transactionsRaw);
  }
}
