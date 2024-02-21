// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dio/dio.dart';
// import 'package:app_medcab/src/shared/avisos.dart';
// import 'package:app_medcab/src/shared/colors.dart';
// import 'package:app_medcab/src/shared/widgets/botones.dart';
// import 'package:app_medcab/src/shared/widgets/form_general.dart';
// import 'package:app_medcab/src/shared/widgets/formato_dinero.dart';
// import 'package:app_medcab/src/shared/widgets/formato_fechas.dart';
// import 'package:app_medcab/src/shared/widgets/pantalla_carga.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class PruebasPage extends StatefulWidget {

//   const PruebasPage({super.key});

//   @override
//   State<PruebasPage> createState() => _PruebasPageState();
// }

// class _PruebasPageState extends State<PruebasPage> {
//   final formKey = GlobalKey<FormState>();

//   final _paletaColors = PaletaColors();
//   final _formatDinero = FormatoDinero();

//   TextEditingController controlTitular = TextEditingController();
//   TextEditingController controlCorreoE = TextEditingController();
//   TextEditingController conDireccCalle = TextEditingController();
//   TextEditingController conDireccNumer = TextEditingController();
//   TextEditingController conDireccCiuda = TextEditingController();
//   TextEditingController conDireccCodPo = TextEditingController();
//   TextEditingController conDireccEstad = TextEditingController();

//   FocusNode focusTitular = FocusNode();
//   FocusNode focusCorreoE = FocusNode();
//   FocusNode focusDireccCalle = FocusNode();
//   FocusNode focusDireccNumer = FocusNode();
//   FocusNode focusDireccCiuda = FocusNode();
//   FocusNode focusDireccCodPo = FocusNode();
//   FocusNode focusDireccEstad = FocusNode();

//   Map<String,dynamic> dataPropiedad = {
//     'estadProp': 'Puebla',
//     'idPropied': 'mj',
//     'duenoProp': 'dueño',
//     'nombrProp': 'Mayrita'
//   };
//   bool cargando = true;
//   bool autovalidar = false;

//   List<String> rangoSelect = [];

//   List<String> listTi = [
//     'Detalles',
//     'Pago',
//     'Confirmación',
//   ];

//   List<String> titulosBoton = [
//     'Continuar',
//     'Continuar',
//     'Finalizar'
//   ];

//   List<IconData> icons = [
//     CupertinoIcons.doc_richtext,
//     CupertinoIcons.creditcard,
//     CupertinoIcons.check_mark_circled
//   ];

//   int paso = 0;
//   int noches = 1;
//   int intIniFechaReserva = 0;
//   int intFitFechaReserva = 0;
//   double costoPropiedad = 1000;
//   double transferirConect = 0;

//   String idCuentaConnect = '';

//   FToast ? fToast;
//   CardFieldInputDetails? _card;
  
//   @override
//   void initState() {
//     fToast = FToast();
//     fToast!.init(context);
//     _setInitData();
//     super.initState();
//   }

//   void _setInitData(){
//     transferirConect = 1102;
//     idCuentaConnect = '';

//     cargando = false;

//     if(mounted){
//       setState((){});
//     }
//   }

//   @override
//   void dispose() {
//     controlCorreoE.dispose();
//     controlTitular.dispose();
//     conDireccCalle.dispose();
//     conDireccNumer.dispose();
//     conDireccCiuda.dispose();
//     conDireccCodPo.dispose();
//     conDireccEstad.dispose();

//     focusTitular.dispose();
//     focusCorreoE.dispose();
//     focusDireccCalle.dispose();
//     focusDireccNumer.dispose();
//     focusDireccCiuda.dispose();
//     focusDireccCodPo.dispose();
//     focusDireccEstad.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ignore: deprecated_member_use
//     return !cargando ? Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           bool check = await _checkSetupStatutus('seti_1OgFn2EMCsqzRA04le2uPyMD_secret_PVGJhYcchgLpipIIltoYvAgkWS2o0Jp');
//           print('Mayrita');
//           print(check);
//           print('Mayrita');
//         },
//       ),
//       backgroundColor: _paletaColors.fondoMain,
//       bottomNavigationBar: _barraInferior(),
//       appBar: _myAppBar(),
//       body: _body()
//     ) : const PantallaCarga(titulo: 'Cargando...');
//   }

//   AppBar _myAppBar(){
    
//     return AppBar(
//       backgroundColor: _paletaColors.fondoMain,
//       elevation: 0,
//       title: Text(
//         listTi[paso],
//         style: const TextStyle(
//           fontFamily: 'Titulos',
//           fontWeight: FontWeight.bold,
//           fontSize: 18
//         ),
//       ),
//       leading: IconButton(
//         icon: const Icon(
//           Icons.arrow_back_ios, 
//           size: 25,
//         ),
//         onPressed: (){
          
//         }, 
//       ),
//       centerTitle: true,
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(50), 
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 15),
//           child: _progreso()
//         )
//       ),
//     );
//   }

//   Widget _barraInferior(){
//     return Container(
//       height: 70,
//       color: _paletaColors.fondoMain,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           MyBoton(
//             botonChico: true,
//             titulo: titulosBoton[paso],
//             fondo: _paletaColors.mainA,
//             onpress: ()=> _nextStep(),
//           ),
//         ],
//       ),
//     );
//   }

//   void _nextStep(){
//     _makePayment((500 * 3), 'acct_1OA4VjE9Gce7e4Rr', 200);
//   }

//   Widget _body(){
//     switch (paso){
//       case 0:
//         return _ventanaDetalles();
//       case 1:
//         return _ventanaPago();
//       case 2:
//         return _ventanaPagoCorrecto();
//       default:
//         return const Text('Cargando..');
//     }
//   }

//   Widget _progreso(){
//     double ancho = 80;
//     return Container(
//       alignment: AlignmentDirectional.center,
//       child: SizedBox(
//         width: 325,
//         child: Row(
//           children: [
//             _itemStep(45, ancho, _paletaColors.mainA, true,  0),
//             _itemStep(45, ancho, _paletaColors.mainA, false, 1),
//             _itemStep(45, ancho, _paletaColors.mainA, false, 2),
//           ]
//         ),
//       ),
//     );  
//   }

//   Widget _itemStep(double radio, double largo, Color fondo, bool primera, int index){
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Container(
//           height: 5,
//           width: primera ? 0 : largo,
//           margin: const EdgeInsets.symmetric(horizontal: 5),
//           decoration: BoxDecoration(
//             color: (index <= paso) ? fondo : fondo.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(5),
//           ),
//         ),
//         Container(
//           height: radio,
//           width: radio,
//           decoration: BoxDecoration(
//             color: (index <= paso) ? fondo : fondo.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(radio),
//             border: Border.all(color: Colors.white, width: 2)
//           ),
//           child: Icon(
//             icons[index],
//             color: (index <= paso) ? Colors.white : _paletaColors.negroMain 
//           )
//         ),
//       ],
//     );
//   }

//   Widget _ventanaDetalles(){
//     final size = MediaQuery.of(context).size.width;
//     return ListView(
//       shrinkWrap: true,
//       padding: EdgeInsets.symmetric(horizontal: (size > 750) ? 200 : 20),
//       children: [
//         _tituloSeccion('Detalles de tu reserva', 16),
//         _propiedad(),
//         _divider(),
//         _tituloSeccion('Estancia', 16),
//         _detallesEstancia(),
//         _divider(),
//         _tituloSeccion('Costos', 16),
//         _detallesCostos(),
//         _divider(),
//       ],
//     );
//   }

//   Widget _propiedad(){
//     return Row(
//       children: [
//         // ClipRRect(
//         //   borderRadius: BorderRadius.circular(10),
//         //   child: ImagenInternet(
//         //     alto: 150,
//         //     ancho: 180,
//         //     url: 'dataPropiedad',
//         //   ),
//         // ),
//         const SizedBox(width: 15),
//         SizedBox(
//           width: 120,
//           height: 130,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 dataPropiedad['nombrProp'],
//                 maxLines: 3,
//                 style: TextStyle(
//                   fontFamily: 'Titulos',
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: _paletaColors.mainA
//                 )
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 dataPropiedad['estadProp'],
//                 style: TextStyle(
//                   fontFamily: 'Textos',
//                   fontSize: 13,
//                   fontWeight: FontWeight.normal,
//                   color: _paletaColors.negroMain
//                 )
//               ),
//               const SizedBox(height: 8),
//               _estrellas(4)
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   Widget _detallesEstancia(){

//     String inicio = FormatoFechas().obtenerFechaRerservaBottom(DateTime.now());
//     String fin = FormatoFechas().obtenerFechaRerservaBottom(DateTime.now());

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _cajaInfo('Inicia', inicio, CupertinoIcons.calendar_today),
//         _cajaInfo('Noches', noches.toString(), CupertinoIcons.moon_circle),
//         _cajaInfo('Fin',    fin, CupertinoIcons.calendar_today),
//       ],
//     );
//   }

//   Widget _cajaInfo(String titulo, String valor, IconData icono){
//     return Container(
//       height: 80,
//       width: 98,
//       margin: const EdgeInsets.only(top: 10, bottom: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10)
//       ),
//       child: Stack(
//         children: [
//           Icon(icono, color: Colors.black12, size: 25),
//           SizedBox(
//             height: 80,
//             width: 98,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   titulo,
//                   style: TextStyle(
//                     fontFamily: 'Textos',
//                     color: _paletaColors.negroMain,
//                     fontSize: 11
//                   ),
//                 ),
//                 Text(
//                   valor,
//                   style: TextStyle(
//                     fontFamily: 'Titulos',
//                     color: _paletaColors.negroMain,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _detallesCostos(){
//     double costoNoche = costoPropiedad.toDouble();
//     double totalNoches = costoNoche * noches;

//     String cantidadNoche = _formatDinero.formatoMoney(costoNoche);
//     String strCostoNoche = _formatDinero.formatoMoney(totalNoches);

//     return Column(
//       children: [
//         _renglonCosto('Noche ($cantidadNoche) x $noches', strCostoNoche),
//       ]
//     );
//   }

//   Widget _renglonCosto(String titulo, String cantidad){
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Container(
//           height: 35,
//           width: 200,
//           margin: const EdgeInsets.only(left: 15),
//           alignment: Alignment.centerLeft,
//           child: Text(
//             titulo,
//             style: const TextStyle(
//               fontFamily: 'Textos',
//               fontWeight: FontWeight.normal,
//               fontSize: 14
//             )
//           ),
//         ),
//         Container(
//           height: 35,
//           width: 90,
//           margin: const EdgeInsets.only(right: 15),
//           alignment: Alignment.centerRight,
//           child: Text(
//             cantidad.toString(),
//             style: const TextStyle(
//               fontFamily: 'Textos',
//               fontWeight: FontWeight.bold,
//               fontSize: 14
//             )
//           ),
//         )
//       ]
//     );
//   }

//   Widget _ventanaPago(){
//     final size = MediaQuery.of(context).size.width;
//     double ancho = (280/2) - 30;

//     return Form(
//       key: formKey,
//       child: ListView(
//         shrinkWrap: true,
//         padding: EdgeInsets.symmetric(horizontal: (size > 750) ? 200 : 10),
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 10),
//             child: _tituloSeccion('Método de Pago', 16),
//           ),
//           const SizedBox(height: 15),
//           Center(
//             child: FormGeneralConTitulo(
//               autovalidar: autovalidar,
//               maxLenght: 50,
//               titulo: 'Correo',
//               control: controlCorreoE, 
//               focusForm: focusCorreoE,
//               capitalizacion: TextCapitalization.none,
//               tipoTeclado: TextInputType.emailAddress,
//               onChange: (){}, 
//               onComplete: (){
//                 FocusScope.of(context).requestFocus(focusTitular);
//               },
//               validator: (String ? value){
//                 RegExp regex = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
//                 if (!regex.hasMatch(value!)) {
//                   return 'Formato de email incorrecto';
//                 } else {
//                   return null;
//                 }
//               },
//             ),
//           ),
//           const SizedBox(height: 15),
//           Center(
//             child: FormGeneralConTitulo(
//               autovalidar: autovalidar,
//               maxLenght: 90,
//               titulo: 'Nombre completo titular',
//               control: controlTitular, 
//               focusForm: focusTitular,
//               capitalizacion: TextCapitalization.words,
//               onChange: (){},
//               onComplete: (){
//                 FocusScope.of(context).requestFocus(focusDireccCalle);
//               },
//               validator: (String ? value){
//                 if (!_hasTwoSpacios(value!)) {
//                   return 'Nombre completo';
//                 } else {
//                   return null;
//                 }
//               },
//             ),
//           ),
//           const SizedBox(height: 15),
//           Center(
//             child: FormGeneralConTitulo(
//               autovalidar: autovalidar,
//               maxLenght: 100,
//               titulo: 'Direción (calle)',
//               control: conDireccCalle, 
//               focusForm: focusDireccCalle,
//               capitalizacion: TextCapitalization.words,
//               tipoTeclado: TextInputType.text,
//               onChange: (){}, 
//               onComplete: (){
//                 FocusScope.of(context).requestFocus(focusDireccNumer);
//               },
//               validator: (String ? value){
//                 if(value!.isEmpty) {
//                   return 'Calle requerida';
//                 } else {
//                   return null;
//                 }
//               },
//             ),
//           ),
//           const SizedBox(height: 15),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               FormGeneralConTitulo(
//                 autovalidar: autovalidar,
//                 maxLenght: 8,
//                 ancho: ancho,
//                 titulo: 'Direción (número)',
//                 control: conDireccNumer, 
//                 focusForm: focusDireccNumer,
//                 capitalizacion: TextCapitalization.characters,
//                 tipoTeclado: TextInputType.text,
//                 onChange: (){}, 
//                 onComplete: (){
//                   FocusScope.of(context).requestFocus(focusDireccCodPo);
//                 },
//                 validator: (String ? value){
//                   if (value!.isEmpty) {
//                     return 'Número requerido';
//                   } else {
//                     return null;
//                   }
//                 },
//               ),
//               FormGeneralConTitulo(
//                 autovalidar: autovalidar,
//                 maxLenght: 5,
//                 ancho: ancho,
//                 titulo: 'Código Postal',
//                 control: conDireccCodPo, 
//                 focusForm: focusDireccCodPo,
//                 capitalizacion: TextCapitalization.none,
//                 tipoTeclado: TextInputType.number,
//                 centro: true,
//                 onChange: (){}, 
//                 onComplete: (){
//                   FocusScope.of(context).requestFocus(focusDireccCiuda);
//                 },
//                 validator: (String ? value){
//                   if (value!.length < 5) {
//                     return 'Código requerido';
//                   } else {
//                     return null;
//                   }
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),
//           Center(
//             child: FormGeneralConTitulo(
//               autovalidar: autovalidar,
//               maxLenght: 90,
//               titulo: 'Ciudad',
//               control: conDireccCiuda, 
//               focusForm: focusDireccCiuda,
//               capitalizacion: TextCapitalization.words,
//               onChange: (){},
//               onComplete: (){
//                 FocusScope.of(context).requestFocus(focusDireccEstad);
//               },
//               validator: (String ? value){
//                 if (value!.isEmpty) {
//                   return 'Ciudad requerida';
//                 } else {
//                   return null;
//                 }
//               },
//             ),
//           ),
//           const SizedBox(height: 15),
//           Center(
//             child: FormGeneralConTitulo(
//               autovalidar: autovalidar,
//               maxLenght: 90,
//               titulo: 'Estado',
//               control: conDireccEstad, 
//               focusForm: focusDireccEstad,
//               capitalizacion: TextCapitalization.words,
//               onChange: (){},
//               onComplete: (){
//                 FocusScope.of(context).unfocus();
//               },
//               validator: (String ? value){
//                 if (value!.isEmpty) {
//                   return 'Estado requerido';
//                 } else {
//                   return null;
//                 }
//               },
//             ),
//           ),
//           _divider(),
//         ],
//       ),
//     );
//   }

//   Widget _ventanaPagoCorrecto(){
//     return SizedBox(
//       width: MediaQuery.of(context).size.width,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           _iconOk(),
//           const Text(
//             '¡Reserva exitosa!',
//             style: TextStyle(
//               fontFamily: 'Titulos',
//               fontWeight: FontWeight.bold,
//               fontSize: 20
//             )
//           ),
//           const SizedBox(
//             width: 300,
//             child: Text(
//               'Pago procesado de forma correcta, para continuar con el proceso póngase en contacto con el propietario y así estar de acuerdo para su llegada.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontFamily: 'Textos'
//               ),
              
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _iconOk(){

//     Color miColorBase = _paletaColors.mainA;

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: SizedBox(
//         height: 180,
//         width: 180,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             _circulo(miColorBase.withOpacity(0.1), 190),
//             _circulo(miColorBase.withOpacity(0.3), 150),
//             _circulo(miColorBase.withOpacity(0.5), 110),
//             _circulo(miColorBase.withOpacity(1), 60),
//             const Icon(Icons.check_rounded, color: Colors.white, size: 45)
//           ],
//         )
//       ),
//     );
//   }

//   Widget _circulo(Color fondo, double size){
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: fondo,
//         borderRadius: BorderRadius.circular(size)
//       ),
//     );
//   }

//   Widget _estrellas(int calificacion){
//     return Row(
//       children: List.generate(5, (index) {
//         return Icon(
//           index < calificacion ? Icons.star : Icons.star_border,
//           color: Colors.amber,
//           size: 15,
//         );
//       }),
//     );
//   }

//   Widget _tituloSeccion(String titulo, double alto){
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: Text(
//         titulo,
//         style: TextStyle(
//           fontFamily: 'Titulos',
//           color: _paletaColors.negroMain,
//           fontWeight: FontWeight.bold,
//           fontSize: alto
//         ),
//       ),
//     );
//   }

//   Widget _divider(){
//     return Container(
//       height: 1,
//       width: double.infinity,
//       color: Colors.grey.shade300,
//       margin: const EdgeInsets.symmetric(vertical: 25),
//     );
//   }

//   String formato(String input) {
//     input = input.replaceAll(RegExp(r'\s+|-'), '');

//     List<String> groups = [];
//     for (int i = 0; i < input.length; i += 4) {
//       groups.add(input.substring(i, i + 4));
//     }

//     String formatted = groups.join(' ');

//     return formatted;
//   }
  
//   bool _hasTwoSpacios(String texto) {
//     if(texto.trim().isEmpty){
//       return false;
//     } else
//     if(texto.trim().contains(' ')){
//       return true;
//     } else {
//       return false;
//     }
//   }
  
//   Future<void> _makePayment(double amount, String idConnect, double uhomeGanancia)async{
//     String idReservaActual = DateTime.now().millisecondsSinceEpoch.toString();
    
//     try {
//       MisAvisos().ventanaTrabajando(context, 'Preparando todo para su pago...');
//       // bool isDisponible = await _checkDisponibilidad();
//       // if(!isDisponible){
//       //   if(mounted) Navigator.pop(context);
//       //   throw Exception('Lo sentimos alguien más ha reservado en las fechas seleccionadas.'); 
//       // }

//       Map<String,dynamic> response = await _getClientSecret(amount, idConnect, uhomeGanancia);
//       // Map<String,dynamic> response = await _getClientSecretConMetodo(amount, idConnect, uhomeGanancia);
      
//       String clientSecret = response['client'];
//       // // String clientSecret = 'pi_3OgLBiEMCsqzRA0407ERHVH8_secret_W4XpNH8Q1GNMUetzzWWQSzjVT';
//       // String idOperacion = response['id'];
//       // print('Mayrita');
//       // print(clientSecret);

//       await _initializePaymentSheet(clientSecret);
      
//       if(mounted) Navigator.pop(context);
      
//       // await FirebaseFirestore.instance
//       // .collection('reservas')
//       // .doc(idReservaActual)
//       // .set({
//       //   'duenoProp': dataPropiedad['duenoProp'],
//       //   'idHuesped': 'widget.userId',
//       //   'idPropied': dataPropiedad['idPropied'],
//       //   'iniReserv': intIniFechaReserva,
//       //   'finReserv': intFitFechaReserva,
//       //   'listDates': rangoSelect,
//       //   'idTransac': idOperacion,
//       //   'isCancele': 0,
//       // }, SetOptions(merge: true));

//       paso = 2;
//       setState((){});

//     }  on StripeException catch (error) {
//       if(error.error.message == 'The payment flow has been canceled'){
//       } else {
//         print(error);
//         // if(mounted) Navigator.pop(context);
//         MisAvisos().showToastStripe('Error verifique los\ndatos de su tarjeta.', 2500, fToast!, true);
//       }
//     } catch (error) {
//       // _regresar(error);
//     }
//   }

//   void _regresar(error){
//     Navigator.pop(context);
//     MisAvisos().showSnackBar(
//       context,
//       error.toString(), 
//       4500, 
//       true
//     );
//   }

//   Future<void> _initializePaymentSheet(String clientSecret)async{
//     try {
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: clientSecret,
//           setupIntentClientSecret: 'seti_1Oge9vEMCsqzRA04tcxkjx5i_secret_PVfUvOAFcjjMenU08ajQTkVzJWlpp7C',
//           customerEphemeralKeySecret: 'ek_test_YWNjdF8xTzg0Y2pFTUNzcXpSQTA0LGcxTkRKODR4Y2VXYTl1NUQxcWV3NzZUcWViVlJPcFY_00iGjyDIcv',
//           customerId: 'cus_PVfQIWLiN8n0fO',
//           merchantDisplayName: 'u home',
//           // billingDetails: const BillingDetails(
//           //   name: 'Miguel Lopez Castillo',
//           //   email: 'janette@gmail.com',
//           //   address: Address(
//           //     city: 'Rafael Lara Grajales', 
//           //     country: 'MX', 
//           //     line1: 'Privada Camino Nacional', 
//           //     line2: '', 
//           //     postalCode: '7500', 
//           //     state: 'Puebla'

//           //   // name: controlTitular.text.trim(),
//           //   // email: controlCorreoE.text.trim(),
//           //   // address: Address(
//           //   //   city: conDireccCiuda.text.trim(), 
//           //   //   country: 'MX', 
//           //   //   line1: conDireccCalle.text.trim(), 
//           //   //   line2: conDireccNumer.text.trim(), 
//           //   //   postalCode: conDireccCodPo.text.trim(), 
//           //   //   state: conDireccEstad.text.trim()
//           //   )
//           // ),
//         ),
//       );
//       await Stripe.instance.presentPaymentSheet();
//     } catch(e){
//       print(e);
//     }
//   }

//   Future<void> _guardarMetodosPagoStripe(String clientSecret)async{
//     try {
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           // paymentIntentClientSecret: clientSecret,
//           intentConfiguration: IntentConfiguration(
//             mode: IntentMode(
//               currencyCode: 'MX', 
//               amount: 100,
//               setupFutureUsage: IntentFutureUsage.OnSession              
//             )
//           ),
//           setupIntentClientSecret: 'seti_1Oge9vEMCsqzRA04tcxkjx5i_secret_PVfUvOAFcjjMenU08ajQTkVzJWlpp7C',
//           customerId: 'cus_PVfQIWLiN8n0fO',
//           merchantDisplayName: 'u home',
//           billingDetails: const BillingDetails(
//             name: 'Miguel Lopez Castillo',
//             email: 'janette@gmail.com',
//             address: Address(
//               city: 'Rafael Lara Grajales', 
//               country: 'MX', 
//               line1: 'Privada Camino Nacional', 
//               line2: '', 
//               postalCode: '7500', 
//               state: 'Puebla'

//             // name: controlTitular.text.trim(),
//             // email: controlCorreoE.text.trim(),
//             // address: Address(
//             //   city: conDireccCiuda.text.trim(), 
//             //   country: 'MX', 
//             //   line1: conDireccCalle.text.trim(), 
//             //   line2: conDireccNumer.text.trim(), 
//             //   postalCode: conDireccCodPo.text.trim(), 
//             //   state: conDireccEstad.text.trim()
//             )
//           ),
//         ),
//       );
//       await Stripe.instance.presentPaymentSheet();
//     } catch(e){
//       print(e);
//     }
//   }

//   Future<Map<String,dynamic>> _getClientSecret(double amount, String idConnect, double gananciaCuentaConnect)async{
//     Dio dio = Dio();
//     var response = await dio.post(
//       'https://api.stripe.com/v1/payment_intents',
//       options: Options(
//         headers: {
//           'Authorization': 'Bearer ${dotenv.env['STRIPE_SK']}',
//           'Content-Type': 'application/x-www-form-urlencoded'
//         },
//       ),
//       data: {
//         'amount': _calculateAmount(amount),
//         'currency': 'MXN',
//         'transfer_data': {
//           'destination': idConnect,
//           'amount': _calculateAmount(gananciaCuentaConnect),
//         },
//         'customer': 'cus_PVfQIWLiN8n0fO',
//         'metadata': {
//           'customer_name': controlTitular.text.trim(),
//           'customer_email': controlCorreoE.text.trim(),
//           'product_id': 'u home',
//         },
//       },
//     );
//     return {
//       'client' : response.data['client_secret'],
//       'id'     : response.data['id']
//     };
    
//   }

//   Future<Map<String,dynamic>> _getClientSecretConMetodo(double amount, String idConnect, double gananciaCuentaConnect)async{
//     Dio dio = Dio();
//     var response = await dio.post(
//       'https://api.stripe.com/v1/payment_intents',
//       options: Options(
//         headers: {
//           'Authorization': 'Bearer ${dotenv.env['STRIPE_SK']}',
//           'Content-Type': 'application/x-www-form-urlencoded'
//         },
//       ),
//       data: {
//         'amount': _calculateAmount(amount),
//         'currency': 'MXN',
//         'transfer_data': {
//           'destination': idConnect,
//           'amount': _calculateAmount(gananciaCuentaConnect),
//         },
//         'payment_method': 'pm_1OgckxEMCsqzRA04SgeLg9U2',
//       },
//     );
//     return {
//       'client' : response.data['client_secret'],
//       'id'     : response.data['id']
//     };
    
//   }

//   int _calculateAmount(double amount) {
//     String montoString = amount.toStringAsFixed(2);
//     double montoFinal = double.parse(montoString);

//     final calculatedAmount = (montoFinal * 100).truncate();
//     return calculatedAmount;
//   }

//   Future<bool> _checkSetupStatutus(String clientSecret) async {
//     final paymentMethod = await Stripe.instance.createPaymentMethod(
//       options: const PaymentMethodOptions(
//         setupFutureUsage: PaymentIntentsFutureUsage.OffSession,
//       ),
//       params: const PaymentMethodParams.card(
//         paymentMethodData: PaymentMethodData(),
//       )
//     );

//     const billingDetails = BillingDetails(
//       name: "Test User",
//       email: 'email@stripe.com',
//       phone: '+48888000888',
//       address: Address(
//         city: 'Houston',
//         country: 'US',
//         line1: '1459  Circle Drive',
//         line2: '',
//         state: 'Texas',
//         postalCode: '77063',
//       ),
//     ); 
    
//     final setupIntentResult = await Stripe.instance.confirmSetupIntent(
//       paymentIntentClientSecret: clientSecret,
//       params: const PaymentMethodParams.card(
//         paymentMethodData: PaymentMethodData(
//           billingDetails: billingDetails,
//         ),
//       ),
//       options: const PaymentMethodOptions(
//         setupFutureUsage: PaymentIntentsFutureUsage.OffSession,
//       ),
//     );

//     if (setupIntentResult.status == setupIntentResult.status) {
//       return true;
//     } else {
//       return false;
//     }
//   }

// }