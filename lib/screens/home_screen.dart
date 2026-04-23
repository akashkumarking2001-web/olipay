import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/payment_info.dart';
import 'settings_screen.dart';
import '../utils/payment_parser.dart';
import '../services/tts_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Olipay Dashboard', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined, color: Color(0xFF4285F4)),
            tooltip: 'Simulate Payment',
            onPressed: () => _simulatePayment(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildStatusHeader(provider),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(provider),
                  const SizedBox(height: 24),
                  if (provider.recentTransactions.isNotEmpty) ...[
                    _buildSectionTitle('Latest Payment'),
                    _buildLiveCard(provider.recentTransactions.first),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionTitle('Recent History'),
                  _buildTransactionsList(provider, context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (provider.isListening ? const Color(0xFF34A853) : const Color(0xFFEA4335)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: provider.isListening ? const Color(0xFF34A853) : const Color(0xFFEA4335),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  provider.isListening ? 'Service Active' : 'Service Stopped',
                  style: TextStyle(
                    color: provider.isListening ? const Color(0xFF34A853) : const Color(0xFFEA4335),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: provider.isListening,
              activeColor: const Color(0xFF4285F4),
              onChanged: (val) {
                if (val) {
                  provider.startListener();
                } else {
                  provider.stopListener();
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
      ),
    );
  }

  Widget _buildStatsSection(AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Today', provider.totalToday, const Color(0xFF4285F4))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('This Month', provider.totalThisMonth, const Color(0xFF34A853))),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard('This Year', provider.totalThisYear, const Color(0xFFFBBC05), isWide: true),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, double amount, Color color, {bool isWide = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat('#,##,###').format(amount)}',
            style: TextStyle(fontSize: isWide ? 32 : 24, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCard(PaymentInfo payment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4285F4), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4285F4).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RECENT ACTIVITY', style: TextStyle(color: Colors.white70, letterSpacing: 1.2, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(DateFormat('hh:mm a').format(payment.timestamp), style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '₹${payment.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              payment.senderName,
              style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(payment.appName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(AppProvider provider, BuildContext context) {
    if (provider.recentTransactions.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No transactions yet', style: TextStyle(color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.recentTransactions.length,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemBuilder: (context, index) {
        final t = provider.recentTransactions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  t.senderName.isNotEmpty ? t.senderName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            title: Text(t.senderName, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
            subtitle: Row(
              children: [
                Text(t.appName, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(width: 6),
                const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                const SizedBox(width: 6),
                Text(DateFormat('hh:mm a').format(t.timestamp), style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            trailing: Text(
              '+₹${t.amount.toStringAsFixed(0)}',
              style: const TextStyle(color: Color(0xFF34A853), fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  void _simulatePayment(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Test Payment Notification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('This will simulate an incoming payment of ₹500 from "John Doe" via Google Pay to test the system.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _processSimulatedPayment(provider);
                },
                child: const Text('Simulate Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _processSimulatedPayment(AppProvider provider) {
    const String packageName = 'com.google.android.apps.nbu.paisa.user';
    const String title = 'Google Pay';
    const String text = '₹500.00 received from John Doe for shop rent';

    final payment = PaymentParser.parse(packageName, title, text);
    if (payment != null) {
      provider.addTransaction(payment);
      final tts = TtsService();
      tts.speakPayment(payment, provider.voiceLanguage);
    }
  }
}
