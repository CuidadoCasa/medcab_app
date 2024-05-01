import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:app_medcab/src/models/metodo_info.dart';
import 'package:app_medcab/src/pages/client/metodos_pago/agregar_metodo.dart';
import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

final _paletaColors = PaletaColors();

class MetodosPage extends StatefulWidget {
  const MetodosPage({super.key});

  @override
  State<MetodosPage> createState() => _MetodosPageState();
}

class _MetodosPageState extends State<MetodosPage> {

  String emailUser = '';
  String userId = '';
  String idCostumerStripe = '';
  String baseUrl = 'https://api-medcab.onrender.com';

  bool trabajando = true;

  List<dynamic> listMisMetodos = [];
  List<IconData> listIconos = [
    FontAwesomeIcons.ccVisa,
    FontAwesomeIcons.ccMastercard,
    FontAwesomeIcons.ccPaypal,
    FontAwesomeIcons.creditCard,
    FontAwesomeIcons.ccAmex,
  ];

  @override
  void initState() {
    _initData();
    super.initState();
  }

  void _initData() async {
    final user = FirebaseAuth.instance.currentUser;
    final dataProvider = Provider.of<VariablesProvider>(context, listen: false);

    if(user != null){

      String uidUser = user.uid;
      Map<String,dynamic> datosPersonData = {};
      Map<String,dynamic> datosPersonDataGen = {};

      DocumentSnapshot<Map<String, dynamic>> datosPerson = await FirebaseFirestore.instance
      .collection('Clients')
      .doc(uidUser)
      .collection('informacion')
      .doc('personal')
      .get();

      DocumentSnapshot<Map<String, dynamic>> datosPersonGen = await FirebaseFirestore.instance
      .collection('Clients')
      .doc(uidUser)
      .get();

      if(datosPerson.data() != null){
        datosPersonData = datosPerson.data()!;
        idCostumerStripe = datosPersonData.containsKey('idCostumerStripe') ? datosPersonData['idCostumerStripe'] : '';
        dataProvider.dataUsuario.update('costumer', (value) => idCostumerStripe);
      }

      if(datosPersonGen.data() != null){
        datosPersonDataGen = datosPersonGen.data()!;
        dataProvider.dataUsuario.update('nombre', (value) => datosPersonDataGen['username']);
        dataProvider.dataUsuario.update('correo', (value) => datosPersonDataGen['email']);
      }      

      if(idCostumerStripe.isNotEmpty){
        listMisMetodos = await _recuperarListaMetodos(idCostumerStripe);
      }
    }

    if(mounted){
      trabajando = false;
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked : (didPop){
        Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mis métodos de pago',
            style: TextStyle(
              fontSize: 18
            )
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: trabajando ? Colors.grey : _paletaColors.mainA,
          onPressed: (){
            if(!trabajando){
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const AgregarMetodoPage(),
                ),
              );
            }
          },
          child: const Icon(
            CupertinoIcons.add_circled,
            color: Colors.white,
          ),
        ),
        body: trabajando ? Center(
          child: CupertinoActivityIndicator(
            radius: 40,
            color: _paletaColors.mainA,
          )
        ) : _listMetodos(),
      ),
    );
  }

  Widget _listMetodos(){
    return ListView.builder(
      itemCount: listMisMetodos.length,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      itemBuilder: (BuildContext context, int index){
        MetodoItemModel infoTemp = metodoItemModelFromJson(jsonEncode(listMisMetodos[index]));
        return _itemMetodo(infoTemp);
      }
    );
  }

  Widget _itemMetodo(MetodoItemModel infoMetodo){
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        iconColor: _paletaColors.mainA,
        tileColor: Colors.grey.shade100,
        leading: FaIcon(
          listIconos[0]
        ),
        title: Text(
          '${infoMetodo.card.brand} terminada con ${infoMetodo.card.last4}',
          style: const TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        subtitle: Text(
          'Creado en: ${DateTime.fromMillisecondsSinceEpoch(infoMetodo.created * 1000)}',
          style: const TextStyle(
            fontWeight: FontWeight.normal
          ),
        ),
      ),
    );
  }
  
  Future<List<dynamic>> _recuperarListaMetodos(String idCustomer) async {
    List<dynamic> misMetodosReturn = [];
    final variablesProvider = Provider.of<VariablesProvider>(context, listen: false);

    try {
      Dio dio = Dio();
      String url = '';
      url = variablesProvider.isModeTest ? '$baseUrl/api/test/medcab/listMisMetodos' : '$baseUrl/api/medcab/listMisMetodos';

      Map<String, dynamic> datos = {
        'isUserCostumerStripe' : idCustomer,
      };

      Response response = await dio.post(
        url,
        data: datos,
      );

      if(response.statusCode == 200){
        misMetodosReturn = response.data['listMetodos'];
      }
      return misMetodosReturn;

    } catch (e) {
      return [];
    }
  }
}
