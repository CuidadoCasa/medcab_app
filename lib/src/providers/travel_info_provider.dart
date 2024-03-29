import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_medcab/src/models/travel_info.dart';

class TravelInfoProvider {

  late CollectionReference _ref;

  TravelInfoProvider() {
    _ref = FirebaseFirestore.instance.collection('TravelInfo');
  }

  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<TravelInfo?> getById(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();

    if (document.exists) {
      TravelInfo travelInfo = TravelInfo.fromJson(document.data() as Map<String,dynamic>);
      return travelInfo;
    }

    return null;
  }

  Future<void> create(TravelInfo travelInfo) async {
    String errorMessage;

    try {
      return _ref.doc(travelInfo.id).set(travelInfo.toJson());
    } catch(error) {
      errorMessage = '$error';
    }

    return Future.error(errorMessage);
  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }

}