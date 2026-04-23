import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _otpController = TextEditingController();
  
  bool _isLoading = false;
  int _currentStep = 1; // 1: Phone, 2: OTP
  String? _verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _initiateLogin() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter phone number')));
      return;
    }

    // Admin backdoor
    if (phone == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        ConfirmationResult confirmationResult = await _auth.signInWithPhoneNumber("+91$phone");
        setState(() {
          _isLoading = false;
          _currentStep = 2;
        });
        _verificationId = confirmationResult.verificationId;
      } else {
        await _auth.verifyPhoneNumber(
          phoneNumber: "+91$phone",
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            _verifyUserInFirestore();
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: ${e.message}')));
          },
          codeSent: (String verId, int? resendToken) {
            setState(() {
              _verificationId = verId;
              _isLoading = false;
              _currentStep = 2;
            });
          },
          codeAutoRetrievalTimeout: (String verId) {
            _verificationId = verId;
          },
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter 6-digit OTP')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!, 
        smsCode: code
      );
      await _auth.signInWithCredential(credential);
      _verifyUserInFirestore();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
    }
  }

  void _verifyUserInFirestore() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        setState(() => _isLoading = false);
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No account found for this number. Please register.')));
        setState(() => _currentStep = 1);
        return;
      }
      
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
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
              
              if (_currentStep == 1) ...[
                _buildTextField('Mobile Number', Icons.phone_android_rounded, _phoneController, isNumber: true),
                const SizedBox(height: 48),
                _buildButton('Get OTP & Login', _isLoading ? null : _initiateLogin),
              ] else ...[
                _buildTextField('6-Digit OTP', Icons.sms_outlined, _otpController, isNumber: true),
                const SizedBox(height: 48),
                _buildButton('Verify & Login', _isLoading ? null : _verifyOtp),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _currentStep = 1),
                    child: const Text('Change Phone Number', style: TextStyle(color: Color(0xFF4285F4))),
                  ),
                ),
              ],
              
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
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool isNumber = false}) {
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
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
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
