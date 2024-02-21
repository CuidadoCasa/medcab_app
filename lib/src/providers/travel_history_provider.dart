import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_medcab/src/models/client.dart';
import 'package:app_medcab/src/models/driver.dart';
import 'package:app_medcab/src/models/travel_history.dart';
import 'package:app_medcab/src/providers/client_provider.dart';
import 'package:app_medcab/src/providers/driver_provider.dart';

class TravelHistoryProvider {

  late CollectionReference _ref;

  TravelHistoryProvider() {
    _ref = FirebaseFirestore.instance.collection('TravelHistory');
  }

  Future<String?> create(TravelHistory travelHistory) async {
    String errorMessage;

    try {
      String id = _ref.doc().id;
      travelHistory.id = id;

      await _ref.doc(travelHistory.id).set(travelHistory.toJson()); // ALMACENAMOS LA INFORMACION
      return id;
    } catch(error) {
      errorMessage = '$error';
    }

    return Future.error(errorMessage);
  }

  Future<List<TravelHistory>> getByIdClient(String idClient) async {
    QuerySnapshot querySnapshot = await _ref.where('idClient', isEqualTo: idClient).orderBy('timestamp', descending: true).get();
    List<Object?> allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    List<TravelHistory> travelHistoryList = [];

    for (int i = 0; i < allData.length; i++) {
      Map<String, dynamic> data = allData[i] as Map<String,dynamic>;
      travelHistoryList.add(TravelHistory.fromJson(data));
    }

    for (TravelHistory travelHistory in travelHistoryList) {
      DriverProvider driverProvider = DriverProvider();
      Driver ? driver = await driverProvider.getById(travelHistory.idDriver!);
      travelHistory.nameDriver = driver!.username;
    }

    return travelHistoryList;
  }

  Future<List<TravelHistory>> getByIdDriver(String idClient) async {
    QuerySnapshot querySnapshot = await _ref.where('idDriver', isEqualTo: idClient).orderBy('timestamp', descending: true).get();
    List<Object?> allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    List<TravelHistory> travelHistoryList = [];

    for (int i = 0; i < allData.length; i++) {
      Map<String, dynamic> data = allData[i] as Map<String,dynamic>;
      travelHistoryList.add(TravelHistory.fromJson(data));
    }

    for (TravelHistory travelHistory in travelHistoryList) {
      ClientProvider clientProvider = ClientProvider();
      Client ? client = await clientProvider.getById(travelHistory.idClient!);
      travelHistory.nameDriver = client!.username;
    }

    return travelHistoryList;
  }

  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<TravelHistory?> getById(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();

    if (document.exists) {
      TravelHistory client = TravelHistory.fromJson(document.data() as Map<String,dynamic>);
      return client;
    }

    return null;
  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }

  Future<void> delete(String id) {
    return _ref.doc(id).delete();
  }

}