import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final paletaColores = PaletaColors();

class FormGeneralConTitulo extends StatelessWidget {

  final TextEditingController control;
  final String titulo;
  
  final double ancho;
  final double alto;
  
  final int lineas;
  final int maxLenght;
  
  final TextCapitalization capitalizacion;
  final TextInputType tipoTeclado;
  final FocusNode focusForm;
  
  final bool ver;
  final bool centro;
  final bool autovalidar;

  final Function onChange;
  final Function onComplete;
  final FormFieldValidator<String>? validator;

  final List<TextInputFormatter> inputFormatters;

  const FormGeneralConTitulo({
    Key? key, 
    required this.control,
    required this.titulo,
    required this.onChange,
    required this.focusForm,
    required this.onComplete,
    required this.maxLenght,
    required this.validator,
    this.ancho = 300,
    this.alto = 40,
    this.lineas = 1,
    this.tipoTeclado = TextInputType.text,
    this.capitalizacion = TextCapitalization.none,
    this.ver = true,
    this.centro = false,
    this.autovalidar = false,
    this.inputFormatters = const []
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo, 
            style: const TextStyle(
              fontFamily: 'Textos',
              color: Colors.grey, 
              fontWeight: FontWeight.normal, 
              fontSize: 15
            )
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: ancho,
            child: TextFormField(
              inputFormatters: inputFormatters,
              autovalidateMode: autovalidar ? AutovalidateMode.always : AutovalidateMode.disabled,
              textAlign: centro ? TextAlign.center : TextAlign.start,
              obscureText: !ver,
              textCapitalization: capitalizacion,
              maxLines: lineas,
              controller: control,
              focusNode: focusForm,
              keyboardType: tipoTeclado,
              maxLength: maxLenght,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Textos'
              ),
              validator: validator,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(
                  fontSize: 10,
                  color: paletaColores.rojoMain
                ),
                errorMaxLines: 4,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.transparent, 
                    width: 0
                  ),
                  borderRadius: BorderRadius.circular(10)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade200, 
                    width: 1
                  ),
                  borderRadius: BorderRadius.circular(10)
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade200, 
                    width: 1
                  ),
                  borderRadius: BorderRadius.circular(10)
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade200, 
                    width: 1
                  ),
                  borderRadius: BorderRadius.circular(10)
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: paletaColores.rojoMain, 
                    width: 1
                  ),
                  borderRadius: BorderRadius.circular(10)
                ),
                counter: const SizedBox.shrink()
              ),
              onChanged: (String value)=> onChange(),
              onEditingComplete: ()=> onComplete(),
            ),
          ),
        ],
      ),
    );
  }
}