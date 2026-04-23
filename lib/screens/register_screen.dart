import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  String _selectedPlan = 'Monthly Standard';
  double _planAmount = 199.0;
  
  int _currentStep = 1; 
  bool _isLoading = false;
  String? _verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _initiatePhoneVerification() async {
    final phone = _phoneController.text.trim();
    final shop = _shopNameController.text.trim();

    if (shop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your Shop Name')));
      return;
    }
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid 10-digit mobile number')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        // Web Phone Auth logic
        try {
          ConfirmationResult confirmationResult = await _auth.signInWithPhoneNumber("+91$phone");
          setState(() {
            _isLoading = false;
            _currentStep = 2;
          });
          _verificationId = confirmationResult.verificationId;
        } catch (e) {
          setState(() => _isLoading = false);
          _showDemoBypassDialog("Firebase Web Auth Notice: $e", phone);
        }
      } else {
        // Mobile Phone Auth logic
        await _auth.verifyPhoneNumber(
          phoneNumber: "+91$phone",
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            _onAuthSuccess();
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() => _isLoading = false);
            _showDemoBypassDialog("Verification Notice: ${e.message}", phone);
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
      _showDemoBypassDialog("System Notice: $e", phone);
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
      if (_verificationId == null) throw "Verification ID missing";
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!, 
        smsCode: code
      );
      await _auth.signInWithCredential(credential);
      _onAuthSuccess();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP: $e')));
    }
  }

  void _onAuthSuccess() {
    setState(() {
      _isLoading = false;
      _currentStep = 3; 
    });
    final uid = _auth.currentUser?.uid ?? "user_${_phoneController.text}";
    _startCashfreePayment(uid);
  }

  void _showDemoBypassDialog(String error, String phone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Environment Notice', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("OTP services are optimized for Mobile APK. On Web, you might see configuration alerts."),
            const SizedBox(height: 12),
            Text("Reason: ${error.contains('configuration-not-found') ? 'Domain not whitelisted in Firebase Console.' : error}", 
                style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
            const SizedBox(height: 16),
            const Text("Would you like to bypass for testing?"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4285F4), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.pop(context);
              _onPaymentSuccess("DEMO_$phone");
            },
            child: const Text('Proceed (Demo)'),
          ),
        ],
      ),
    );
  }

  Future<void> _startCashfreePayment(String uid) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    _onPaymentSuccess(uid);
  }

  Future<void> _onPaymentSuccess(String uid) async {
    setState(() => _isLoading = true);
    int days = _selectedPlan.contains('Monthly') ? 30 : 365;
    if (_selectedPlan.contains('Trial')) days = 30; 
    
    try {
      await _firestore.collection('users').doc(uid).set({
        'shopName': _shopNameController.text,
        'phone': _phoneController.text,
        'plan': _selectedPlan,
        'joinedAt': FieldValue.serverTimestamp(),
        'expiryDate': DateTime.now().add(Duration(days: days)),
        'role': 'merchant',
      });
    } catch (e) {
      debugPrint("Firestore Error: $e");
    }

    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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
                const Text('Create Account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF4285F4))),
                const SizedBox(height: 8),
                const Text('Launch your business soundbox in minutes.', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                const SizedBox(height: 32),
                
                if (_currentStep == 1) ...[
                  _buildTextField('Shop / Business Name', Icons.storefront_rounded, _shopNameController),
                  const SizedBox(height: 20),
                  _buildTextField('Mobile Number', Icons.phone_android_rounded, _phoneController, isNumber: true),
                  const SizedBox(height: 32),
                  const Text('Choose Your Plan', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildPlanCard('1 Month Trial', 99.0, 'Full feature access for 30 days'),
                  const SizedBox(height: 12),
                  _buildPlanCard('Monthly Standard', 199.0, '₹199 per month recurring'),
                  const SizedBox(height: 12),
                  _buildPlanCard('Annual Gold', 1599.0, 'Best value - Save over 30%'),
                  const SizedBox(height: 40),
                  _buildButton('Get OTP & Register', _isLoading ? null : _initiatePhoneVerification),
                  const SizedBox(height: 24),
                ],

                if (_currentStep == 2) ...[
                  const Text('Verify OTP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  Text('Enter the 6-digit code sent to +91 ${_phoneController.text}', style: const TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 32),
                  _buildTextField('6-Digit OTP', Icons.sms_outlined, _otpController, isNumber: true),
                  const SizedBox(height: 40),
                  _buildButton('Verify & Proceed', _isLoading ? null : _verifyOtp),
                  Center(
                    child: TextButton(onPressed: () => setState(() => _currentStep = 1), child: const Text('Change Phone Number', style: TextStyle(color: Color(0xFF4285F4)))),
                  ),
                ],

                if (_currentStep == 3) ...[
                  const Center(
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        CircularProgressIndicator(color: Color(0xFF4285F4), strokeWidth: 4),
                        SizedBox(height: 24),
                        Text('Activating Your Soundbox...', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(hint, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14))),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLength: isNumber && hint.contains('OTP') ? 6 : (isNumber ? 10 : null),
          decoration: InputDecoration(
            counterText: "",
            hintText: 'Enter $hint',
            prefixIcon: Icon(icon, color: const Color(0xFF4285F4)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(String title, double amount, String subtitle) {
    final isSelected = _selectedPlan == title;
    return GestureDetector(
      onTap: () => setState(() { _selectedPlan = title; _planAmount = amount; }),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4285F4).withOpacity(0.05) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF4285F4) : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.radio_button_off, color: isSelected ? const Color(0xFF4285F4) : const Color(0xFF94A3B8)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, overflow: TextOverflow.ellipsis)),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, overflow: TextOverflow.ellipsis), maxLines: 1),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4285F4), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: onPressed,
        child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
