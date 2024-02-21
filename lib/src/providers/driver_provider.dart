import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_medcab/src/models/driver.dart';

class DriverProvider {

  late CollectionReference _ref;

  DriverProvider() {
    _ref = FirebaseFirestore.instance.collection('Drivers');
  }

  Future<void> create(Driver driver) async {
    String ? errorMessage;

    try {
      return _ref.doc(driver.id).set(driver.toJson());
    } catch(error) {
      errorMessage = '$error';
    }

    return Future.error(errorMessage);
  
  }

  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<Driver?> getById(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();

    if (document.exists) {
      Driver driver = Driver.fromJson(document.data() as Map<String,dynamic>);
      return driver;
    }

    return null;
  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }

}