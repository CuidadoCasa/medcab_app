import 'package:flutter/material.dart';

class LogoApp extends StatelessWidget {
  const LogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: SizedBox(
        height: 90,
        width:  90,
        child: Image.asset(
          'assets/images/log_uhome.png',
          fit: BoxFit.cover,
        )
      )
    );
  }
}