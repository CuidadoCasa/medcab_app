import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class MisAvisos {
  final _paletaColores = PaletaColors();

  void showToastStripe(String mensaje, int duracion, FToast ftoast, bool hasError) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.blueAccent.shade700,
      ),
      child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            mensaje,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Textos'
            )
          ),
        ],
      ),
    );

    ftoast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(milliseconds: duracion),
    );
  }

  void showToast(String mensaje, int duracion, FToast ftoast, bool hasError) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: hasError ? Colors.redAccent : _paletaColores.mainB,
      ),
      child: Text(
        mensaje,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Textos'
        )
      ),
    );

    ftoast.showToast(
      child: toast,
      gravity: hasError ? ToastGravity.TOP : ToastGravity.BOTTOM,
      toastDuration: Duration(milliseconds: duracion),
    );
  }
  
  void ventanaAviso(BuildContext context, String descripcion, {IconData icono = CupertinoIcons.exclamationmark_shield_fill}){  
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return AlertDialog(
          elevation: 50,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          title: Text(
            'Cuidado En Casa',
            style: TextStyle(
              color: _paletaColores.mainA,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Icon(
                    CupertinoIcons.exclamationmark_shield_fill,
                    size: 40,
                    color: _paletaColores.mainB,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  descripcion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Textos',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _botonMensaje('Ok', _paletaColores.mainA, ()=> Navigator.pop(context)),
              ],
            ),
          ],
        );
      }
    );
  }
  
  void ventanaAvisoNullAction(BuildContext context, String descripcion, {IconData icono = CupertinoIcons.exclamationmark_shield_fill}){  
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          elevation: 50,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          title: Text(
            'Cuidado En Casa',
            style: TextStyle(
              color: _paletaColores.mainA,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Icon(
                    CupertinoIcons.exclamationmark_shield_fill,
                    size: 40,
                    color: _paletaColores.mainB,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  descripcion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Textos',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }
    );
  }
  
  void ventanaConfirmarAccion(BuildContext context, String descripcion, Function onpress, {double sizeFuente = 16}){  
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return AlertDialog(
          elevation: 50,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          title: Text(
            'Cuidado En Casa',
            style: TextStyle(
              color: _paletaColores.mainA,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  descripcion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Textos',
                    fontSize: sizeFuente,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _botonMensaje('Cancelar', _paletaColores.mainB, ()=> Navigator.pop(context)),
                _botonMensaje('Aceptar',  Colors.white,  ()=> onpress()),
              ],
            ),
          ],
        );
      }
    );
  }
  
  void ventanaConfirmarCodigo(BuildContext context, Widget cuerpo, Function onpress, {double sizeFuente = 16}){  
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return AlertDialog(
          elevation: 50,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          title: Text(
            'Cuidado En Casa',
            style: TextStyle(
              color: _paletaColores.mainA,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Container(
            color: Colors.white,
            child: cuerpo,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _botonMensaje('Cancelar', _paletaColores.mainB, ()=> Navigator.pop(context)),
                _botonMensaje('Aceptar',  Colors.white,  ()=> onpress()),
              ],
            ),
          ],
        );
      }
    );
  }

  Widget _botonMensaje(String titulo, Color color, Function onpress){
    return ElevatedButton(
      onPressed: ()=> onpress(),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.zero,
        backgroundColor: (titulo == 'Aceptar') ? _paletaColores.mainA : const Color.fromARGB(255, 249, 244, 250),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: SizedBox(
        height: 30,
        width: 100,
        child: Center(
          child: Text(
            titulo,
            style: TextStyle(
              fontFamily: 'Textos',
              color: color,
              fontWeight: FontWeight.bold
            )
          )
        ),
      )
    );
  }

  void ventanaTrabajando(BuildContext context, String titulo){      
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (context) {
        return AlertDialog(
          elevation: 50,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Container(
            height: 200,
            width:  50,
            color: Colors.white,
            alignment: AlignmentDirectional.center,
            child: Column(
              children: [
                Image.asset(
                  'assets/img/icon.png',
                  height: 80,
                ),
                const SizedBox(height: 15),
                CupertinoActivityIndicator(
                  color: _paletaColores.mainB,
                  radius: 20,
                ),
                const SizedBox(height: 15),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: 'Textos'
                  )
                )
              ],
            ),
          )
        );
      }
    );
  }
  
  void showSnackBar(BuildContext context, String text, int duracion, bool error) {
    IconData icono;
    if(error){
      icono = Icons.error_outline_rounded;
    } else {
      icono = Icons.check_circle_outline;
    }

    FocusScope.of(context).requestFocus(FocusNode());
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ListView(
          shrinkWrap: true,
          children: [
            Icon(icono, size: 25, color: Colors.white),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15
              ),
            ),
          ],
        ),
        backgroundColor: error ? Colors.redAccent : _paletaColores.mainA,
        duration: Duration(milliseconds: duracion),
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      )
    );
  }

}
