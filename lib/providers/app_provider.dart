import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_info.dart';

class AppProvider extends ChangeNotifier {
  String _selectedLanguage = 'en-IN';
  String _voiceLanguage = 'en-IN';
  bool _isListening = false;
  List<PaymentInfo> _recentTransactions = [];
  bool _vibrateEnabled = true;
  Timer? _pollingTimer;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get selectedLanguage => _selectedLanguage;
  String get voiceLanguage => _voiceLanguage;
  bool get isListening => _isListening;
  List<PaymentInfo> get recentTransactions => _recentTransactions;
  bool get vibrateEnabled => _vibrateEnabled;

  double get totalToday {
    final now = DateTime.now();
    return _recentTransactions
        .where((t) => t.timestamp.year == now.year && 
                      t.timestamp.month == now.month && 
                      t.timestamp.day == now.day)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalThisMonth {
    final now = DateTime.now();
    return _recentTransactions
        .where((t) => t.timestamp.year == now.year && 
                      t.timestamp.month == now.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalThisYear {
    final now = DateTime.now();
    return _recentTransactions
        .where((t) => t.timestamp.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  AppProvider() {
    _loadPreferences();
    _startPollingTransactions();
    _checkListenerStatus();
    _setupFirestoreListener();
  }

  void _setupFirestoreListener() {
    _transactionSubscription?.cancel();
    final user = _auth.currentUser;
    if (user != null) {
      _transactionSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _recentTransactions = snapshot.docs.map((doc) {
            final data = doc.data();
            return PaymentInfo(
              amount: (data['amount'] as num).toDouble(),
              senderName: data['senderName'] ?? 'Someone',
              appName: data['appName'] ?? 'UPI App',
              timestamp: (data['timestamp'] as Timestamp).toDate(),
              rawText: data['rawText'] ?? '',
              transactionId: data['transactionId'],
            );
          }).toList();
          notifyListeners();
        }
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _transactionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString('selected_language') ?? 'en-IN';
    _voiceLanguage = prefs.getString('voice_language') ?? 'en-IN';
    _vibrateEnabled = prefs.getBool('vibrate_enabled') ?? true;
    _refreshTransactions(prefs);
    
    // Auto-delete older than 30 days
    _cleanOldTransactions(prefs);
    notifyListeners();
  }

  void _refreshTransactions(SharedPreferences prefs) {
    final rawList = prefs.getStringList('transactions') ?? [];
    _recentTransactions = rawList.map((str) => PaymentInfo.fromJson(jsonDecode(str))).toList();
  }

  Future<void> _cleanOldTransactions(SharedPreferences prefs) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    bool changed = false;
    _recentTransactions.removeWhere((t) {
      if (t.timestamp.isBefore(thirtyDaysAgo)) {
        changed = true;
        return true;
      }
      return false;
    });

    if (changed) {
      List<String> rawList = _recentTransactions.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList('transactions', rawList);
    }
  }

  // Poll local storage periodically since the background isolate updates SharedPreferences
  void _startPollingTransactions() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      var rawList = prefs.getStringList('transactions') ?? [];
      if (rawList.length != _recentTransactions.length || 
         (rawList.isNotEmpty && jsonDecode(rawList.first)['timestamp'] != _recentTransactions.first.timestamp.toIso8601String())) {
        _refreshTransactions(prefs);
        notifyListeners();
      }
    });
  }

  Future<void> _checkListenerStatus() async {
    if (kIsWeb) return;
    _isListening = await NotificationsListener.isRunning ?? false;
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _selectedLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', lang);
    notifyListeners();
  }

  Future<void> setVoiceLanguage(String lang) async {
    _voiceLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_language', lang);
    notifyListeners();
  }
  
  Future<void> setVibrate(bool val) async {
    _vibrateEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrate_enabled', val);
    notifyListeners();
  }

  Future<void> startListener() async {
    if (kIsWeb) {
      _isListening = true;
      notifyListeners();
      return;
    }
    await NotificationsListener.startService(
      title: "Olipay is active",
      description: "Listening for incoming payments",
      showWhen: true,
    );
    _isListening = true;
    notifyListeners();
  }

  Future<void> stopListener() async {
    if (kIsWeb) {
      _isListening = false;
      notifyListeners();
      return;
    }
    await NotificationsListener.stopService();
    _isListening = false;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('transactions', []);
    _recentTransactions.clear();
    notifyListeners();
  }

  Future<void> deleteTransaction(int index) async {
    if (index >= 0 && index < _recentTransactions.length) {
      _recentTransactions.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      List<String> rawList = _recentTransactions.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('transactions', rawList);
      notifyListeners();
    }
  }

  /// Manually add a transaction (for debugging or simulation)
  Future<void> addTransaction(PaymentInfo payment) async {
    // 1. Add to Local
    _recentTransactions.insert(0, payment);
    final prefs = await SharedPreferences.getInstance();
    List<String> rawList = _recentTransactions.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('transactions', rawList);
    
    // 2. Add to Firestore if logged in
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('transactions').add({
        'amount': payment.amount,
        'senderName': payment.senderName,
        'appName': payment.appName,
        'timestamp': Timestamp.fromDate(payment.timestamp),
        'rawText': payment.rawText,
        'transactionId': payment.transactionId,
      });
    }
    
    notifyListeners();
  }
}
