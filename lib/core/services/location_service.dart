import 'package:geolocator/geolocator.dart';

Future<Position> currentPosition() async =>
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

Future<Position?> lastKnownPosition() async =>
    await Geolocator.getLastKnownPosition();

Future<LocationPermission> isPermitted() async =>
    await Geolocator.checkPermission();

Future<LocationPermission> requestPermission() async =>
    await Geolocator.requestPermission();

Future<bool> isLocationServiceEnabled() async =>
    await Geolocator.isLocationServiceEnabled();

double distanceBetweenLocation(
        {required double startLatitude,
        required double startLongitude,
        required double endLatitude,
        required double endLongitude}) =>
    Geolocator.bearingBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);


void checkLocationPermission() async {
        if(!await isLocationServiceEnabled()){
                print("Please enable location service");
        }else{
                if (await isPermitted() == LocationPermission.denied) {
                        if (await requestPermission() == LocationPermission.denied) {
                                print("Permission denied!");
                        }
                }
        }
}

