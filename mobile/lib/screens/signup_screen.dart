import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _businessController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1765FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.query_stats, color: Color(0xFF1765FF), size: 34),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Grow your',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      'business',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1765FF)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track sales, expenses, and inventory\neffortlessly in one place.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Full Name
              Text('Full Name', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'John Doe',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
              const SizedBox(height: 14),

              // Email Address
              Text('Email Address', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'john@company.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
              const SizedBox(height: 14),

              // Business Name
              Text('Business Name', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _businessController,
                decoration: InputDecoration(
                  hintText: 'Acme Corp',
                  prefixIcon: const Icon(Icons.storefront_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),

              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 14),
                  SizedBox(width: 8),
                  Text('BUSINESS IDENTITY VERIFIED', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),

              const SizedBox(height: 16),

              // Password
              Text('Password', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),

              const SizedBox(height: 22),

              // Create Account
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const SizedBox(),
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shield, size: 16, color: Colors.grey),
                  SizedBox(width: 12),
                  Icon(Icons.cloud_sync, size: 16, color: Colors.grey),
                ],
              ),

              const SizedBox(height: 18),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: TextStyle(color: Colors.grey[600])),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Log In', style: TextStyle(color: Color(0xFF1765FF), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text('By clicking Create Account, you agree to our Terms of Service and Privacy Policy.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
