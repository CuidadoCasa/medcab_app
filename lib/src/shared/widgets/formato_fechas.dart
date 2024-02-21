class FormatoFechas {
  String obtenerFechaRerservaBottom(DateTime fecha) {
    List<String> nombresMeses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun', 
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    
    String nombreMes = nombresMeses[fecha.month - 1];
    String dia = fecha.day.toString().padLeft(2, '0');

    return '$dia $nombreMes';
  }

  String obtenerFechaFormateada(DateTime fecha) {
    List<String> nombresMeses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    String nombreMes = nombresMeses[fecha.month - 1];
    String dia = fecha.day.toString().padLeft(2, '0');

    return '$dia de $nombreMes';
  }

  String fechaCard(int ref) {

    DateTime fecha = DateTime.fromMillisecondsSinceEpoch(ref);

    List<String> nombresMeses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    String nombreMes = nombresMeses[fecha.month - 1];
    int year = fecha.year;

    return '$nombreMes $year';
  }
}