import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/tts_service.dart';
import '../utils/legal_content.dart';
import 'legal_doc_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TtsService _ttsService = TtsService();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('Voice & Sound'),
          _buildSettingCard(
            child: Column(
              children: [
                _buildLanguageSelector(provider),
                const Divider(height: 32, color: Color(0xFFF1F5F9)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF4285F4).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.volume_up_rounded, color: Color(0xFF4285F4)),
                  ),
                  title: const Text('Test Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Hear how your notifications sound'),
                  trailing: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF4285F4), size: 32),
                  onTap: () => _ttsService.testSpeak(provider.voiceLanguage),
                ),
                const Divider(height: 32, color: Color(0xFFF1F5F9)),
                SwitchListTile(
                  title: const Text('Vibrate on Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Add physical feedback to alerts'),
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF34A853),
                  value: provider.vibrateEnabled,
                  onChanged: (val) => provider.setVibrate(val),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          _buildSectionHeader('Device Optimization'),
          _buildSettingCard(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To ensure Olipay works 24/7, please enable these settings for your device:',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
                SizedBox(height: 16),
                _GuideItem(brand: 'Xiaomi', instruction: 'AutoStart -> ON, Battery -> No restrictions'),
                _GuideItem(brand: 'Samsung', instruction: 'Device Care -> Never sleeping apps -> Add Olipay'),
                _GuideItem(brand: 'Oppo/Vivo', instruction: 'Phone Manager -> Startup Manager -> Enable Olipay'),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          _buildSectionHeader('Account & Security'),
          _buildSettingCard(
            child: Column(
              children: [
                _buildLegalTile('Privacy Policy', LegalContent.privacyPolicy, Icons.privacy_tip_outlined),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildLegalTile('Terms & Conditions', LegalContent.terms, Icons.description_outlined),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildLegalTile('Refund Policy', LegalContent.refundPolicy, Icons.assignment_return_outlined),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEA4335)),
              label: const Text('Sign Out', style: TextStyle(color: Color(0xFFEA4335), fontWeight: FontWeight.bold)),
            ),
          ),
          const Center(
            child: Text('Version 1.0.0 (Production Ready)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLegalTile(String title, String content, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF64748B), size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => LegalDocScreen(title: title, content: content)));
      },
    );
  }

  Widget _buildLanguageSelector(AppProvider provider) {
    final languages = {
      'en-IN': 'English',
      'ta-IN': 'Tamil (தமிழ்)',
      'hi-IN': 'Hindi (हिन्दी)',
      'te-IN': 'Telugu (తెలుగు)',
      'ml-IN': 'Malayalam (മലയാളம்)'
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Voice Alert Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: languages.entries.map((entry) {
            final isSelected = provider.voiceLanguage == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              selectedColor: const Color(0xFF4285F4),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
              onSelected: (val) { if (val) provider.setVoiceLanguage(entry.key); },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _GuideItem extends StatelessWidget {
  final String brand;
  final String instruction;
  const _GuideItem({required this.brand, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
            child: Text(brand, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1E293B))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(instruction, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
        ],
      ),
    );
  }
}
