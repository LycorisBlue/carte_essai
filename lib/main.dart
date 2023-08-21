import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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
  List<LatLng> routpoints = [LatLng(52.05884, -1.345583)];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    Timer.periodic(Duration(seconds: 2), (Timer timer) {
      _getCurrentLocation();
    }); 
  }

  Future<void> _getCurrentLocation() async {
    bool servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print('Service de localisation désactivé');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenStreetMap'),
        centerTitle: true,
      ),
      body: _currentLocation != null
          ? SafeArea(
              child: SizedBox(
                height: 500,
                width: 400,
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
                    zoom: 18,
                  ),
                  nonRotatedChildren: [
                    AttributionWidget.defaultWidget(
                      source: 'OpenStreetMap contributors',
                      onSourceTapped: null,
                    ),
                  ],
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
                          width: 40,
                          height: 40,
                          builder: (ctx) => Container(
                            child: Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 40.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylineCulling: false,
                      polylines: [
                        Polyline(
                          points: routpoints,
                          color: Colors.blue,
                          strokeWidth: 9,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
