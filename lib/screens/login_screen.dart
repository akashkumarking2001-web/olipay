import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'admin_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _handleLogin() async {
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter phone number')));
      return;
    }

    // Admin backdoor
    if (phone == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      return;
    }

    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter 4-digit PIN')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userDoc = await _firestore.collection('users').where('phone', isEqualTo: phone).get();
      
      if (userDoc.docs.isEmpty) {
        throw "No account found for this number. Please register.";
      }

      final userData = userDoc.docs.first.data();
      if (userData['pin'] == pin) {
        final uid = userDoc.docs.first.id;
        if (mounted) {
          await Provider.of<AppProvider>(context, listen: false).setSession(uid);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      } else {
        throw "Incorrect PIN. Please try again.";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4285F4)),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF4285F4)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Access your business dashboard securely.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                ),
                const SizedBox(height: 48),
                
                _buildTextField('Mobile Number', Icons.phone_android_rounded, _phoneController, isNumber: true),
                const SizedBox(height: 24),
                _buildTextField('4-Digit PIN', Icons.lock_outline_rounded, _pinController, isNumber: true, isPin: true),
                
                const SizedBox(height: 48),
                _buildButton('Login', _isLoading ? null : _handleLogin),
                
                const SizedBox(height: 32),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Color(0xFF64748B)),
                        children: [
                          TextSpan(
                            text: "Register Now",
                            style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool isNumber = false, bool isPin = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(hint, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
        ),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          maxLength: isPin ? 4 : (isNumber ? 10 : null),
          obscureText: isPin,
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            counterText: "",
            hintText: 'Enter your $hint',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF4285F4)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4285F4), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        onPressed: onPressed,
        child: _isLoading 
            ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
