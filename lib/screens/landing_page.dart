import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class LandingPage extends StatelessWidget {
  LandingPage({Key? key}) : super(key: key);

  static List<Map<String, dynamic>> getAllUpiApps() {
    return [
      {'name': 'PhonePe', 'icon': Icons.account_balance_wallet, 'color': Colors.purple},
      {'name': 'Google Pay', 'icon': Icons.g_mobiledata, 'color': Colors.blue},
      {'name': 'Paytm', 'icon': Icons.payment, 'color': Colors.lightBlue},
      {'name': 'BHIM', 'icon': Icons.account_balance, 'color': Colors.orange},
      {'name': 'Amazon Pay', 'icon': Icons.shopping_cart, 'color': Colors.yellow.shade800},
      {'name': 'WhatsApp', 'icon': Icons.chat, 'color': Colors.green},
      {'name': 'BharatPe', 'icon': Icons.store, 'color': Colors.blue.shade900},
      {'name': 'MobiKwik', 'icon': Icons.wallet, 'color': Colors.blue},
      {'name': 'Freecharge', 'icon': Icons.flash_on, 'color': Colors.red},
      {'name': 'CRED', 'icon': Icons.credit_card, 'color': Colors.black},
      {'name': 'FamPay', 'icon': Icons.family_restroom, 'color': Colors.orange},
      {'name': 'PayZapp', 'icon': Icons.payment, 'color': Colors.blue},
      {'name': 'iMobile', 'icon': Icons.smartphone, 'color': Colors.red},
      {'name': 'SBI YONO', 'icon': Icons.account_balance, 'color': Colors.blue.shade800},
      {'name': 'Airtel Pay', 'icon': Icons.cell_tower, 'color': Colors.red},
      {'name': 'JioPay', 'icon': Icons.network_check, 'color': Colors.blue},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4285F4).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4285F4).withOpacity(0.1),
                            border: Border.all(color: const Color(0xFF4285F4).withOpacity(0.3), width: 2),
                          ),
                          child: const Icon(Icons.account_balance_wallet_rounded, size: 60, color: Color(0xFF4285F4)),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                RichText(
                  text: const TextSpan(
                    text: 'Oli',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4285F4),
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Pay',
                        style: TextStyle(color: Color(0xFF34A853)),
                      ),
                      TextSpan(
                        text: ' for Business',
                        style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Unified UPI & Voice Notifications.\nSmart, Secure, and Instant!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B), height: 1.5),
                ),
                const SizedBox(height: 40),
                
                // Highlights Section
                _buildHighlightsGrid(),
                
                const SizedBox(height: 50),
                
                // Supported Apps Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBC05),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Accept All UPI Apps',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => _showAllAppsBottomSheet(context),
                        child: const Text('Read More', style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildSupportedAppsGrid(),
                
                const SizedBox(height: 50),
                
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF4285F4).withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: const Text('Register Business', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4285F4),
                      side: const BorderSide(color: Color(0xFF4285F4), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    child: const Text('Login to Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightsGrid() {
    final highlights = [
      {'title': 'Instant\nUPI Alerts', 'icon': Icons.notifications_active_outlined, 'color': const Color(0xFF34A853)},
      {'title': 'No Hardware\nNeeded', 'icon': Icons.stay_current_portrait_outlined, 'color': const Color(0xFF4285F4)},
      {'title': 'No KYC\nRequired', 'icon': Icons.description_outlined, 'color': const Color(0xFFFBBC05)},
      {'title': 'Alerts in Your\nLanguage', 'icon': Icons.translate_outlined, 'color': const Color(0xFFEA4335)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: highlights.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final item = highlights[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: (item['color'] as Color).withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: (item['color'] as Color).withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'] as IconData, color: item['color'] as Color, size: 32),
              const SizedBox(height: 12),
              Text(
                item['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSupportedAppsGrid() {
    final displayApps = getAllUpiApps().take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayApps.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final app = displayApps[index];
        return _buildAppItem(app);
      },
    );
  }

  Widget _buildAppItem(Map<String, dynamic> app) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (app['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(app['icon'] as IconData, color: app['color'] as Color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            app['name'] as String,
            style: const TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAllAppsBottomSheet(BuildContext context) {
    final allApps = getAllUpiApps();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text(
                    'All Supported UPI Apps',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF4285F4).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text('${allApps.length} Apps', style: const TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Olipay supports notifications from over 50+ UPI apps. Here are the most popular ones:',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: allApps.length,
                itemBuilder: (context, index) => _buildAppItem(allApps[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Got it', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
