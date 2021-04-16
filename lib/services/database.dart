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


  PlaceData _placeDataFromSnapshot(DocumentSnapshot snapshot){
    return PlaceData(
      uid: uid,
      name: snapshot.data['name'],
      tokenAvailable: snapshot.data['tokenAvailable'],
      totalPeople: snapshot.data['totalPeople'],
    );
  }

  Stream<List<Place>> get places {
    return placesCollection.snapshots()
      .map(_placeListFromSnapshot);
  }

  Stream<PlaceData> get placeData {
    return placesCollection.document(uid).snapshots()
    .map(_placeDataFromSnapshot);
  }
}

class UserDatabaseService {
  
  final String uid;
  UserDatabaseService({ this.uid });

  final CollectionReference userCollection = Firestore.instance.collection('users');

  Future updateUserData(String email, String status, String queueAt, int token) async {

    return await userCollection.document(uid).setData({
      'email': email,
      'status': status,
      'queueAt': queueAt,
      'token': token,
    });
  }
}