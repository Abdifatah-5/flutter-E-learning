import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  String username = "";
  String email = "";
  String password = "";
  bool isLoginPage = false;

  void beginAuth() {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      formKey.currentState!.save();
      submitToFirebase(email, password, username);
    }
  }

  Future<void> submitToFirebase(
      String email, String password, String username) async {
    final auth = FirebaseAuth.instance;
    try {
      if (isLoginPage) {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        UserCredential userCredential = await auth
            .createUserWithEmailAndPassword(email: email, password: password);
        print("userCredential $userCredential");
        String uid = userCredential.user!.uid;
        print("userCredential $uid");
        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          'username': username,
          'email': email,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLoginPage)
                TextFormField(
                  key: const ValueKey('Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 4) {
                      return 'Enter at least 4 characters';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    username = value!;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains("@")) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value!;
                },
                decoration: const InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('password'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Enter a valid password';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value!;
                },
                decoration: const InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 46,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: beginAuth,
                  child: Text(isLoginPage ? 'Login' : 'Sign Up'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLoginPage = !isLoginPage;
                  });
                },
                child:
                    Text(isLoginPage ? 'Not a member?' : 'Already a member?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
