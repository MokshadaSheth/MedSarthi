import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:med_sarathi/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _errorMessage;

  // Password visibility toggles
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _registerUser() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords do not match!";
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();

    try {
      User? user = await _auth.signUpWithEmailAndPassword(email, password);

      if (user != null) {
        await FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
          "username": username,
          "phone": phone,
          "email": email,
          "createdAt": FieldValue.serverTimestamp(),
        });

        print("✅ User data saved to Firestore.");
        Navigator.pushNamed(context, "/login");
      } else {
        setState(() {
          _errorMessage = "Registration failed. Please try again.";
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "Something went wrong";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  void _signInWithGoogle() async {
    try {
      User? user = await _auth.signInWithGoogle();
      if (user != null) {
        // Check if user already exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("Users").doc(user.uid).get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
            "username": user.displayName ?? "",
            "email": user.email,
            "phone": user.phoneNumber ?? "",
            "createdAt": FieldValue.serverTimestamp(),
            "authProvider": "google",
          });
          print("🆕 New Google user added to Firestore");
        } else {
          print("🔁 Existing Google user logged in");
        }

        Navigator.pushNamed(context, "/login"); 
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Google Sign-In failed. Please try again.";
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Join us now!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 30),

              // Username Field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Password Field
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _registerUser,
                child: const Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 16),

              const Text('Or Signup using', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),

              // Google Sign-In Button
              ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                label: const Text("Sign in with Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                child: const Text(
                  "Already a member? Signin",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
