import "package:cloud_firestore/cloud_firestore.dart";

class DatabaseService {

  final CollectionReference placesCollection = Firestore.instance.collection('Places');
  
}