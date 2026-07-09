import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:amingo/screens/enter_username.dart';
import 'package:amingo/services/auth_service.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  final String email;
  const LoginScreen({super.key, required this.email});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool isResending = false;
  int countdown = 30;
  Timer? timer;
  void startTimer() {
    setState(() {
      countdown = 30;
    });
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    otpController.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> resendOtp() async {
    setState(() {
      isResending = true;
    });

    try {
      await AuthService().resendOtp(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("A new OTP has been sent")));

      startTimer();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to resend OTP")));
    }

    if (!mounted) return;
    setState(() {
      isResending = false;
    });
  }

  Future<void> login() async {
    if (otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 6-digit OTP")),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final response = await AuthService().verifyOtp(
        widget.email,
        otpController.text.trim(),
      );

      // Save user code if present in response
      if (response.data != null && response.data["code"] != null) {
        await AuthService.saveUserCode(response.data["code"].toString());
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CreateUsername()),
      );
    } on DioException catch (e) {
      final message = e.response?.data["detail"] ?? "Something went wrong";

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/amMingo.png',
                  height: height * 0.15,
                ),
              ),
              Center(
                child: Text(
                  "Welcome",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: width * 0.11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Enter the OTP to sign into your account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: width * 0.04,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                "Email Address",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: height * 0.01),
              TextField(
                controller: TextEditingController(text: widget.email),
                readOnly: true,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "hello@example.com",
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),

              Text(
                "OTP",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: height * 0.01),

              TextField(
                controller: otpController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  letterSpacing: 4,
                ),
                cursorColor: colorScheme.primary,
                decoration: InputDecoration(
                  hintText: "123456",
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),

              SizedBox(
                width: double.infinity,
                height: height * 0.06,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "LOGIN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.05,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),

              SizedBox(height: height * 0.01),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: countdown == 0 && !isResending ? resendOtp : null,
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: countdown == 0
                            ? colorScheme.primary
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  countdown > 0
                      ? Text("in $countdown seconds")
                      : const Text("now"),
                ],
              ),

              SizedBox(height: height * 0.04),

              Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.outline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "OR CONTINUE WITH",
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: width * 0.035,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colorScheme.outline)),
                ],
              ),

              SizedBox(height: height * 0.03),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await AuthService().signInWithGoogle();
                    // Note: Current AuthService implementation returns String? (the token)
                    // If the backend redirect setup provides the code in the URL, we'd need
                    // to update AuthService to return a Map or similar to get both.
                    // For now, we fetch the profile after login to ensure we have the code.
                    if (result != null) {
                      debugPrint("Got token: $result");
                      await AuthService.saveToken(result);

                      // Fetch profile to get the code
                      try {
                        final profileResp = await AuthService().getProfile(0);
                        if (profileResp.data != null &&
                            profileResp.data["code"] != null) {
                          await AuthService.saveUserCode(
                            profileResp.data["code"].toString(),
                          );
                        }
                      } catch (e) {
                        debugPrint(
                          "Failed to fetch profile code after Google login: $e",
                        );
                      }

                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateUsername(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google-removebg-preview.png',
                        height: 22,
                      ),
                      SizedBox(width: height * 0.02),
                      Text(
                        "Sign in with Google",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: width * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
