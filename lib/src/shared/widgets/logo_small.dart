import 'package:flutter/material.dart';

class LogoSmallApp extends StatelessWidget {
  
  const LogoSmallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width:  40,
      child: Image.asset(
        'assets/img/icon.png',
        fit: BoxFit.contain,
      )
    );
  }
}