import 'package:app_medcab/src/shared/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMensaje extends StatelessWidget {

  final String texto;
  final String uid;
  final AnimationController animationController;

  ChatMensaje({
    Key ? key, 
    required this.texto, 
    required this.uid, 
    required this.animationController
  }) : super(key: key);

  final _paletaColors = PaletaColors();

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return FadeTransition(
      opacity: animationController,
      child: SizeTransition(
        sizeFactor: CurvedAnimation(parent: animationController, curve: Curves.easeOut ),
        child: Container(
          child: uid == user!.uid
          ? _myMessage()
          : _notMyMessage(),
        ),
      ),
    );
  }

  Widget _myMessage() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(
          right: 10,
          bottom: 10,
          left: 50
        ),
        decoration: BoxDecoration(
          color: _paletaColors.mainA.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Textos',
            color: Colors.white
          ),
        ),
      ),
    );
  }

  Widget _notMyMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(
          left: 10,
          bottom: 10,
          right: 50
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Textos'
          ),
        ),
      ),
    );
  }
}