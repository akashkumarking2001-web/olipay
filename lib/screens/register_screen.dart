import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  
  String _selectedPlan = 'Monthly Standard';
  double _planAmount = 199.0;
  
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _handleRegistration() async {
    final shop = _shopNameController.text.trim();
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (shop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your Shop Name')));
      return;
    }
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid 10-digit mobile number')));
      return;
    }
    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a 4-digit PIN')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if user already exists
      final userDoc = await _firestore.collection('users').where('phone', isEqualTo: phone).get();
      if (userDoc.docs.isNotEmpty) {
        throw "An account with this phone number already exists.";
      }

      final uid = "user_$phone";
      int days = _selectedPlan.contains('Monthly') ? 30 : 365;
      if (_selectedPlan.contains('Trial')) days = 30; 
      
      await _firestore.collection('users').doc(uid).set({
        'shopName': shop,
        'phone': phone,
        'pin': pin, // Storing PIN for custom auth
        'plan': _selectedPlan,
        'joinedAt': FieldValue.serverTimestamp(),
        'expiryDate': DateTime.now().add(Duration(days: days)),
        'role': 'merchant',
        'status': 'active',
      });

      // Set session in provider
      if (mounted) {
        await Provider.of<AppProvider>(context, listen: false).setSession(uid);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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
                const Text('Create Account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF4285F4))),
                const SizedBox(height: 8),
                const Text('Launch your business soundbox in minutes.', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                const SizedBox(height: 32),
                
                _buildTextField('Shop / Business Name', Icons.storefront_rounded, _shopNameController),
                const SizedBox(height: 20),
                _buildTextField('Mobile Number', Icons.phone_android_rounded, _phoneController, isNumber: true),
                const SizedBox(height: 20),
                _buildTextField('Set 4-Digit Login PIN', Icons.lock_outline_rounded, _pinController, isNumber: true, isPin: true),
                
                const SizedBox(height: 32),
                const Text('Choose Your Plan', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                _buildPlanCard('1 Month Trial', 99.0, 'Full feature access for 30 days'),
                const SizedBox(height: 12),
                _buildPlanCard('Monthly Standard', 199.0, '₹199 per month recurring'),
                const SizedBox(height: 12),
                _buildPlanCard('Annual Gold', 1599.0, 'Best value - Save over 30%'),
                const SizedBox(height: 40),
                
                _buildButton('Register & Start', _isLoading ? null : _handleRegistration),
                const SizedBox(height: 24),
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
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(hint, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14))),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLength: isPin ? 4 : (isNumber ? 10 : null),
          obscureText: isPin,
          decoration: InputDecoration(
            counterText: "",
            hintText: 'Enter $hint',
            prefixIcon: Icon(icon, color: const Color(0xFF4285F4)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2)),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.w900, fontSize: 16)),
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
