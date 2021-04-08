import 'package:VirQ/models/place.dart';
import "package:cloud_firestore/cloud_firestore.dart";

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });
  final CollectionReference placesCollection = Firestore.instance.collection('places');
  
  Future updatePlaceData(String name, int tokenAvailable, int totalPeople) async {
    return await placesCollection.document(uid).setData({
      'name': name,
      'tokenAvailable': tokenAvailable,
      'totalPeople': totalPeople,
    });
  }

  List<Place> _placeListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return Place(
        name: doc.data['name'] ?? '',
        tokenAvailable: doc.data['tokenAvailable'] ?? 0,
        totalPeople: doc.data['totalPeople'] ?? 0,
      );
    }).toList();
  }

  Stream<List<Place>> get places {
    return placesCollection.snapshots()
      .map(_placeListFromSnapshot);
  }
}