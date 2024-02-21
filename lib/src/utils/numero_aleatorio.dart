import 'dart:math';

class Calculos {

  static int obtenerNumeroAleatorio() {
    Random random = Random();
    int numeroAleatorio = random.nextInt(6);
    return numeroAleatorio;
  }

}