class Place {
  final String name;
  final int tokenAvailable;
  final int totalPeople;
  final String address;
  final int time;
  final String coverPic;
  final String galleryPic1;
  final String galleryPic2;

  Place({ this.name, this.tokenAvailable, this.totalPeople, this.address, this.time, this.coverPic, this.galleryPic1, this.galleryPic2 });

  

}

class PlaceData {

  final String uid;
  final String name;
  final int tokenAvailable;
  final int totalPeople;
  final String address;
  final int time;
  final String coverPic;
  final String galleryPic1;
  final String galleryPic2;

  PlaceData({this.uid, this.name, this.tokenAvailable, this.totalPeople, this.address, this.time, this.coverPic, this.galleryPic1, this.galleryPic2 });
}