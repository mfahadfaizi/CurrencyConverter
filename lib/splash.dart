import 'package:currency/currency_convert_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> myInitMethod() async {
    await Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
              builder: (context) => const CurrencyConverterScreen()),
          (_) => false);
    });
  }

  @override
  void initState() {
    myInitMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage('assets/icon.png'),
              fit: BoxFit.contain,
            ),
          )),
    );
  }
}
