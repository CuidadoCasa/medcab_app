import 'package:app_medcab/src/api/environment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart' as places;
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';


class BusquedaPage extends StatefulWidget {
  const BusquedaPage({super.key});
  @override
  State<BusquedaPage> createState() => _BusquedaPageState();
}

class _BusquedaPageState extends State<BusquedaPage> {
  
  final _controlSarch = TextEditingController();

  List<AutocompletePrediction> busquedaResults = [];

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if(mounted){
          Navigator.pop(context, {'ciudad': ''});
        }
        return false;
      },      
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(),
        body: _listOpciones()
      ),
    );
  }

  AppBar _appBar(){
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: true,
      title: const Text(
        'Ubicación paciente',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      toolbarHeight: 60,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _cuadroBusqueda(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cuadroBusqueda(){
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 250,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey)
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.search, color: Colors.grey),
              SizedBox(
                width: 200,
                child: TextFormField(
                  controller: _controlSarch,
                  autofocus: true,
                  style: const TextStyle(fontSize: 14),
                  keyboardType: TextInputType.visiblePassword,
                  decoration: const InputDecoration(
                    hintText: 'Buscar ',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintStyle: TextStyle(
                      fontFamily: 'Textos'
                    )
                  ),
                  onChanged: (String ? value)=> _createNewList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ); 
  }

  Widget _listOpciones(){
    return ListView.builder(
      shrinkWrap: true,
      itemCount: busquedaResults.length,
      padding: const EdgeInsets.only(bottom: 20, left: 10),
      itemBuilder: (BuildContext context, int index){
        return _itemBusqueda(busquedaResults[index]);
      },
    );
  }

  Widget _itemBusqueda(AutocompletePrediction titulo){

    String miTitulo = '${titulo.primaryText}, ${titulo.secondaryText}';

    return ListTile(
      onTap: ()=> _regresar(titulo, miTitulo),
      leading: const Icon(
        Icons.place,
        color: Colors.deepPurple,
      ),
      title: Text(
        miTitulo,
        style: TextStyle(
          color: Colors.grey.shade600
        )
      ),
    );

    // return InkWell(
    //   onTap: ()=> _regresar(titulo, miTitulo),
    //   splashColor: Colors.transparent,
    //   highlightColor: Colors.transparent,
    //   hoverColor: Colors.transparent,
    //   child: Container(
    //     margin: const EdgeInsets.only(bottom: 8),
    //     padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    //     alignment: Alignment.centerLeft,
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(10),
    //       color: Colors.white
    //     ),
    //     child: Text(miTitulo),
    //   ),
    // );
  }

  void _regresar(AutocompletePrediction p, String titulo) async {
    final places.GoogleMapsPlaces lugaresApi = places.GoogleMapsPlaces(apiKey: Environment.API_KEY_MAPS);
    places.PlacesDetailsResponse detail = await lugaresApi.getDetailsByPlaceId(p.placeId, language: 'es');
    
    double lat = detail.result.geometry!.location.lat;
    double lng = detail.result.geometry!.location.lng;

    final referencias = detail.result.addressComponents;

    String referenciaCiudad = '';
    String referenciaEstado = '';
    
    int ubicCiudad = 0;
    int ubicEstado = 0;
    
    if(referencias.length >= 4){
      ubicEstado = (referencias.length - 3);
      ubicCiudad = (referencias.length - 4);

      referenciaCiudad = referencias[ubicCiudad].longName;
      referenciaEstado = referencias[ubicEstado].longName;
    }

    _regresarBusqueda(titulo, lat, lng, referenciaCiudad, referenciaEstado);
  }

  void _regresarBusqueda(String miTitulo, double lat, double lng, String ciudad, String estado){
    Navigator.pop(
      context, 
      {
        'ciudad': miTitulo, 
        'lat': lat, 
        'lng': lng,
        'referenciaCiudad': ciudad,
        'referenciaEstado': estado,
      }
    );
  }

  void _createNewList() async {
    if(_controlSarch.text.trim().isNotEmpty){
      final places = FlutterGooglePlacesSdk(Environment.API_KEY_MAPS);
      final predictions = await places.findAutocompletePredictions(_controlSarch.text.trim());
      List<AutocompletePrediction> lista = predictions.predictions;
      busquedaResults = lista;
      setState((){});
    }
  }
}