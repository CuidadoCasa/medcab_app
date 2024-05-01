import 'package:flutter/material.dart';

class VariablesProvider with ChangeNotifier {
  
  int _menuSelect  = 0;
  String _nombreCompleto = '';
  String _idCuentaConnect = '';
  bool _isConect = false;

  bool _isModeTest = false;

  Map<String,dynamic> _filtros = {};
  Map<String,dynamic> _dataUsuario = {
    'nombre': '',
    'correo': '',
    'costumer': '',
    'connect': ''
  };

  bool get isModeTest => _isModeTest;
  set isModeTest(bool value){
    _isModeTest = value;
    notifyListeners();
  }

  bool get isConect => _isConect;
  set isConect(bool value){
    _isConect = value;
    notifyListeners();
  }

  Map<String,dynamic> get dataUsuario => _dataUsuario;
  set dataUsuario(Map<String,dynamic> value){
    _dataUsuario = value;
    notifyListeners();
  }

  Map<String,dynamic> get filtros => _filtros;
  set filtros(Map<String,dynamic> value){
    _filtros = value;
    notifyListeners();
  }

  int get menuSelect => _menuSelect;
  set menuSelect(int value){
    _menuSelect = value;
    notifyListeners();
  }

  String get nombreCompleto => _nombreCompleto;
  set nombreCompleto(String value){
    _nombreCompleto = value;
    notifyListeners();
  }

  String get idCuentaConnect => _idCuentaConnect;
  set idCuentaConnect(String value){
    _idCuentaConnect = value;
    notifyListeners();
  }

}