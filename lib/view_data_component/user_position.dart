import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class UserPosition {
  UserPosition._pr();
  static final UserPosition _instance = UserPosition._pr();
  static UserPosition get instance => _instance;

  BehaviorSubject<LatLng> _subject = BehaviorSubject<LatLng>();
  Stream<LatLng> get stream => _subject.stream;
  LatLng get current => _subject.value;
  void populate(LatLng coordinate) {
    _subject.add(coordinate);
  }

  Future<Placemark?> translateCoordinate() async {
    try {
      final LatLng c = LatLng(current.latitude, current.longitude);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(c.latitude, c.longitude);
      if (placemarks.isEmpty) return null;
      return placemarks.first;
    } catch (e) {
      return null;
    }
  }

  dispose() {
    _subject = BehaviorSubject<LatLng>();
  }
}
