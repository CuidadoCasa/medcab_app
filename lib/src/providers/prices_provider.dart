import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_medcab/src/models/prices.dart';

class PricesProvider {

  late CollectionReference _ref;

  PricesProvider() {
    _ref = FirebaseFirestore.instance.collection('Prices');
  }

  Future<Prices> getAll() async {
    DocumentSnapshot document = await _ref.doc('info').get();
    Prices prices = Prices.fromJson(document.data() as Map<String,dynamic>);
    return prices;
  }

}