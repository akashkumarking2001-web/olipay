import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'home_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({Key? key}) : super(key: key);

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _hasNotificationListenerPerm = false;
  bool _hasIgnoreBatteryPerm = false;
  bool _hasNotificationPostPerm = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      _hasNotificationListenerPerm = (await NotificationsListener.hasPermission) ?? false;
      _hasIgnoreBatteryPerm = await Permission.ignoreBatteryOptimizations.isGranted;
      _hasNotificationPostPerm = await Permission.notification.isGranted;
    } catch(e) {
      _hasNotificationListenerPerm = true;
      _hasIgnoreBatteryPerm = true;
      _hasNotificationPostPerm = true;
    }
    setState(() {});
  }

  void _proceedIfReady() {
    if (_hasNotificationListenerPerm && _hasNotificationPostPerm) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please grant the required permissions first.')),
      );
    }
  }

  void _requestListenerPermission() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Prominent Disclosure', 
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)
        ),
        content: const Text(
          'Olipay collects, reads, and processes the text of incoming notifications from UPI apps '
          '(like Google Pay, PhonePe, and Paytm) EVEN WHEN the app is closed or not in use. '
          'This data is used exclusively on your device to trigger payment voice announcements '
          'and is NEVER shared, sold, or uploaded to any third-party marketing servers.\n\n'
          'To enable the Soundbox feature, you must grant Notification Access in the next screen.',
          style: TextStyle(color: Color(0xFF64748B), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4), 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              NotificationsListener.openPermissionSettings();
            },
            child: const Text('I Agree'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('App Permissions', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.security_rounded, size: 80, color: Color(0xFF4285F4)),
            const SizedBox(height: 24),
            const Text(
              'Required Access',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            const Text(
              'To provide instant voice alerts, Olipay requires background access to read payment notifications.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 40),
            
            _buildPermTile(
              title: '1. Notification Access',
              subtitle: 'Read UPI alerts for voice announcements',
              icon: Icons.notifications_active_outlined,
              isGranted: _hasNotificationListenerPerm,
              onTap: _requestListenerPermission,
            ),
            
            _buildPermTile(
              title: '2. Post Notifications',
              subtitle: 'Show service status in background',
              icon: Icons.message_outlined,
              isGranted: _hasNotificationPostPerm,
              onTap: () async {
                await Permission.notification.request();
                _checkPermissions();
              },
            ),

            _buildPermTile(
              title: '3. Battery Optimization',
              subtitle: 'Ensure service never gets killed',
              icon: Icons.battery_saver_outlined,
              isGranted: _hasIgnoreBatteryPerm,
              isOptional: true,
              onTap: () async {
                await Permission.ignoreBatteryOptimizations.request();
                _checkPermissions();
              },
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: const Color(0xFF4285F4).withOpacity(0.3),
                ),
                onPressed: _proceedIfReady,
                child: const Text('Start Using Olipay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPermTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isGranted,
    required VoidCallback onTap,
    bool isOptional = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isGranted ? const Color(0xFF34A853).withOpacity(0.2) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isGranted ? const Color(0xFF34A853) : const Color(0xFF4285F4)).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isGranted ? const Color(0xFF34A853) : const Color(0xFF4285F4), size: 24),
        ),
        title: Text(title, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(
          isOptional ? '$subtitle (Recommended)' : subtitle, 
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)
        ),
        trailing: isGranted 
            ? const Icon(Icons.check_circle, color: Color(0xFF34A853), size: 28)
            : TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF4285F4)),
                child: const Text('Grant', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
      ),
    );
  }
}
