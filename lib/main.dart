import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GeolocatorApp(),
    );
  }
}

class GeolocatorApp extends StatefulWidget {
  const GeolocatorApp({Key? key}) : super(key: key);

  @override
  _GeolocatorAppState createState() => _GeolocatorAppState();
}

class _GeolocatorAppState extends State<GeolocatorApp> {
      Position? _currentLocation;
    late bool servicePermission = false;
    late LocationPermission permission;

    String _currentAdress = "";

    Future<Position> _getCurrentLocation() async {
      servicePermission = await Geolocator.isLocationServiceEnabled();
      if (!servicePermission) {
        print('je suis lostvayne');
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return await Geolocator.getCurrentPosition();
    }

    _getAdressFromCoordinates() async {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            _currentLocation!.latitude, _currentLocation!.longitude);
        Placemark place = placemarks[0];

        setState(() {
          _currentAdress = "${place.country}, ${place.locality}";
        });
      } catch (e) {
        print(e);
      }
    }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Lycoris Blue'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Lacation coordinate',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
                'Latitude = ${_currentLocation?.latitude}  Longitude = ${_currentLocation?.longitude}'),
            SizedBox(
              height: 30,
            ),
            Text(
              'Lacation Address',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text('${_currentAdress}'),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
                onPressed: () async {
                  _currentLocation = await _getCurrentLocation();
                  await _getAdressFromCoordinates();
                },
                child: Text('my position'))
          ],
        ),
      ),
    );
  }
}
