import 'package:flutter/material.dart';

class ButtonApp extends StatelessWidget {

  final Color color;
  final Color textColor;
  final String text;
  final IconData icon;
  final Function onPressed;
  final Widget icono;
  final Color fondoBoton;

  const ButtonApp({
    super.key, 
    this.color = Colors.black,
    this.textColor = Colors.white,
    this.icon = Icons.arrow_forward_ios,
    this.fondoBoton = const Color(0xFF1A69B2),
    required this.onPressed,
    required this.text,
    required this.icono
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: fondoBoton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor
                ),
              )
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 50,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.transparent,
                child: icono
              ),
            ),
          )
        ],
      ),
    );
  }
}
