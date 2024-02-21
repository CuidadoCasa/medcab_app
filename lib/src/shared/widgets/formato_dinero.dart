class FormatoDinero {
  
  String numeroComa = 'MJ';
  String numeroSinSigno = 'MJ';

  void convertirNum(double cantidad){

    double num1 = cantidad;
    String numString  = num1.toStringAsFixed(2);
    int auxNum = numString.indexOf('.');
    String numDecima = numString.substring(numString.length - 2, numString.length);
    String numEntero = numString.substring(0, auxNum);

    if(num1 == 0){
      numeroComa = '\$0.00';
      numeroSinSigno = '0.00';
    } else
    if(numEntero.length <= 3){
      numeroComa = '\$$numString';
      numeroSinSigno = numString;
    } else 
    if(numEntero.length <= 6){
      numeroComa = '\$${numEntero.substring(0,(numEntero.length - 3))},${numEntero.substring((numEntero.length - 3),numEntero.length)}.$numDecima';
      numeroSinSigno = '${numEntero.substring(0,(numEntero.length - 3))},${numEntero.substring((numEntero.length - 3),numEntero.length)}.$numDecima';
    } else
    if(numEntero.length <= 9){
      numeroComa = '\$${numEntero.substring(0,(numEntero.length - 6))},${numEntero.substring((numEntero.length - 6),(numEntero.length - 3))},${numEntero.substring((numEntero.length - 3),numEntero.length)}.$numDecima';
      numeroSinSigno = '${numEntero.substring(0,(numEntero.length - 6))},${numEntero.substring((numEntero.length - 6),(numEntero.length - 3))},${numEntero.substring((numEntero.length - 3),numEntero.length)}.$numDecima';
    }
  }

  String formatoMoney(double cantidad){

    double num1 = cantidad;
    String numString  = num1.toStringAsFixed(2);
    int auxNum = numString.indexOf('.');
    String numDecima = numString.substring(numString.length - 2, numString.length);
    String numEntero = numString.substring(0, auxNum);

    if(num1 == 0){
      numeroComa = '\$0.00';
      numeroSinSigno = '0.00';
    } else
    if(numEntero.length <= 3){
      numeroComa = '\$$numString';
      numeroSinSigno = numString;
    } else 
    if(numEntero.length <= 6){
      numeroComa = '\$${numEntero.substring(0,(numEntero.length - 3))},${numEntero.substring((numEntero.length - 3),numEntero.length)}.$numDecima';
      numeroSinSigno = '${numEntero.substring(0,(numEntero.length - 3))},${numEntero.substring((numEntero.length - 3),numEntero.length)}.$numDecima';
    } else
    if(numEntero.length <= 9){
      numeroComa = '\$${numEntero.substring(0,(numEntero.length - 6))},${numEntero.substring((numEntero.length - 6),(numEntero.length - 3))},${numEntero.substring((numEntero.length - 3),numEntero.length)}.$numDecima';
      numeroSinSigno = '${numEntero.substring(0,(numEntero.length - 6))},${numEntero.substring((numEntero.length - 6),(numEntero.length - 3))},${numEntero.substring((numEntero.length - 3),numEntero.length)}.$numDecima';
    }

    return numeroComa;
  }

  String formatoMoneySinCeros(int cantidad){

    int num1 = cantidad;
    String numString = num1.toString();
    String numEntero = num1.toString();

    if(num1 == 0){
      numeroComa = '\$ 0';
    } else
    if(numEntero.length <= 3){
      numeroComa = '\$ $numString';
    } else 
    if(numEntero.length <= 6){
      numeroComa = '\$ ${numEntero.substring(0,(numEntero.length - 3))},${numEntero.substring((numEntero.length - 3),numEntero.length)}';
    } else
    if(numEntero.length <= 9){
      numeroComa = '\$ ${numEntero.substring(0,(numEntero.length - 6))},${numEntero.substring((numEntero.length - 6),(numEntero.length - 3))},${numEntero.substring((numEntero.length - 3),numEntero.length)}';
    }

    // String newNumero = numeroComa.replaceAll(RegExp(r'.00'), '');

    return numeroComa;
  }

}