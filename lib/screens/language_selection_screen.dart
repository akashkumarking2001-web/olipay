import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/translations.dart';
import 'landing_page.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<Map<String, String>> languages = [
    {'code': 'en-IN', 'name': 'English', 'native': 'English'},
    {'code': 'ta-IN', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'hi-IN', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'te-IN', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'kn-IN', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    {'code': 'ml-IN', 'name': 'Malayalam', 'native': 'മലയാളം'},
  ];

  String tempAppLang = 'en-IN';
  String tempVoiceLang = 'en-IN';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    tempAppLang = provider.selectedLanguage;
    tempVoiceLang = provider.voiceLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      Translations.get('title', tempAppLang),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Translations.get('subtitle', tempAppLang),
                      style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 40),
                    _buildSectionHeader(Translations.get('app_lang', tempAppLang), Icons.language_rounded),
                    const SizedBox(height: 16),
                    _buildLanguageGrid(true),
                    const SizedBox(height: 40),
                    _buildSectionHeader(Translations.get('voice_lang', tempAppLang), Icons.record_voice_over_rounded),
                    const SizedBox(height: 16),
                    _buildLanguageGrid(false),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final provider = Provider.of<AppProvider>(context, listen: false);
              await provider.setLanguage(tempAppLang);
              await provider.setVoiceLanguage(tempVoiceLang);
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LandingPage()));
              }
            },
            child: Text(
              Translations.get('save_continue', tempAppLang), 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4285F4), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ),
      ],
    );
  }

  Widget _buildLanguageGrid(bool isAppLang) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        final lang = languages[index];
        final isSelected = isAppLang ? tempAppLang == lang['code'] : tempVoiceLang == lang['code'];

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isAppLang) {
                tempAppLang = lang['code']!;
              } else {
                tempVoiceLang = lang['code']!;
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4285F4).withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? const Color(0xFF4285F4) : const Color(0xFFE2E8F0), width: 2),
              boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF4285F4).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(lang['native']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF4285F4) : const Color(0xFF1E293B), overflow: TextOverflow.ellipsis)),
                      Text(lang['name']!, style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFF4285F4).withOpacity(0.7) : const Color(0xFF64748B), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                if (isSelected) const Positioned(top: 8, right: 8, child: Icon(Icons.check_circle, color: Color(0xFF4285F4), size: 18)),
              ],
            ),
          ),
        );
      },
    );
  }
}
