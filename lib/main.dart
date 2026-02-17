import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  await Hive.openBox('sessionBox');
  await Hive.openBox('todoBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isMpinVisible = false;

  final Color primaryColor = const Color(0xFF7B1FA2);

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();
  final mpinController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  String _hashMpin(String mpin) {
    return sha256.convert(utf8.encode(mpin)).toString();
  }

  void signup() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final dob = dobController.text.trim();
    final email = emailController.text.trim();
    final mpin = mpinController.text.trim();
    final contact = contactController.text.trim();
    final address = addressController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^[0-9]{10}$');

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        dob.isEmpty ||
        email.isEmpty ||
        mpin.isEmpty ||
        contact.isEmpty ||
        address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email")),
      );
      return;
    }

    if (!phoneRegex.hasMatch(contact)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid 10-digit contact number")),
      );
      return;
    }

    Hive.box('authBox').put(email, {
      "firstName": firstName,
      "lastName": lastName,
      "dob": dob,
      "contact": contact,
      "address": address,
      "mpin": _hashMpin(mpin),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signup Successful")),
    );

    setState(() => isLogin = true);
  }

  void login() {
    final email = emailController.text.trim();
    final mpin = mpinController.text.trim();

    if (email.isEmpty || mpin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final userData = Hive.box('authBox').get(email);

    if (userData != null && userData["mpin"] == _hashMpin(mpin)) {
      Hive.box('sessionBox').put('currentUser', email);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Home(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE6F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                isLogin ? "Welcome Back 👋" : "Create Account",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              if (!isLogin)
                const Text(
                  "Please enter your details ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    if (!isLogin) ...[
                      inputField(
                        "First Name",
                        Icons.person,
                        controller: firstNameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      inputField(
                        "Last Name",
                        Icons.person_outline,
                        controller: lastNameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      inputField(
                        "Contact Number",
                        Icons.phone,
                        controller: contactController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      inputField(
                        "Address",
                        Icons.location_on,
                        controller: addressController,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "Date of Birth",
                          prefixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: const Color(0xFFF5F6FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            dobController.text =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    inputField(
                      "Email address",
                      Icons.email,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    inputField(
                      "MPIN",
                      Icons.lock,
                      controller: mpinController,
                      isPassword: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLogin ? login : signup,
                        child: Text(
                          isLogin ? "Login" : "Sign up",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin
                        ? "Don’t have an account? "
                        : "Already have an account? ",
                  ),
                  GestureDetector(
                    onTap: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin ? "Sign up" : "Log in",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputField(
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextEditingController? controller,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: isPassword && !isMpinVisible,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    isMpinVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isMpinVisible = !isMpinVisible;
                    });
                  },
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
