import 'package:VirQ/models/place.dart';
import 'package:VirQ/models/user.dart';
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
        address: doc.data['address'] ?? '',
        coverPic: doc.data['coverPic'] ?? '',
        galleryPic1: doc.data['galleryPic1'] ?? '',
        galleryPic2: doc.data['galleryPic2'] ?? '',
        galleryPic3: doc.data['galleryPic3'] ?? '',
      );
    }).toList();
  }


  PlaceData _placeDataFromSnapshot(DocumentSnapshot snapshot){
    return PlaceData(
      uid: uid,
      name: snapshot.data['name'],
      tokenAvailable: snapshot.data['tokenAvailable'],
      totalPeople: snapshot.data['totalPeople'],
      address: snapshot.data['address'],
      coverPic: snapshot.data['coverPic'],
      galleryPic1: snapshot.data['galleryPic1'],
      galleryPic2: snapshot.data['galleryPic2'],
      galleryPic3: snapshot.data['galleryPic3'],
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

  Future updateUserData(String email, String status, String queueAt, int token, String time, int eta) async {
    return await userCollection.document(uid).setData({
      'email': email,
      'status': status,
      'queueAt': queueAt,
      'token': token,
      'time': time,
      'eta': eta,
    });
  }

  List<User> _userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return User(
        uid: doc.documentID ?? '',
        email: doc.data['email'] ?? 0,
        status: doc.data['status'] ?? 0,
        queueAt: doc.data['queueAt'] ?? '',
        token: doc.data['token'] ?? '',
        time: doc.data['time'] ?? '',
        eta: doc.data['eta'] ?? '',
      );
    }).toList();
  }

    Stream<List<User>> get users {
    return userCollection.snapshots()
      .map(_userListFromSnapshot);
  }
}