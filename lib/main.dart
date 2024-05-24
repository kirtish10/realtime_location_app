import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _toggleListening(); // Start listening immediately
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_positionStreamSubscription == null) {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Handle the case where location services are not enabled.
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Handle the case where the user denies location permissions.
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Handle the case where the user denies location permissions forever.
        return Future.error('Location permissions are permanently denied');
      }
      _positionStreamSubscription =
          Geolocator.getPositionStream().listen((Position? position) {
        setState(() => _currentPosition = position);
      });
    } else {
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Geolocation Tracker',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.black,
          elevation: 0, // Remove app bar shadow
          actions: [
            IconButton(
              icon: Icon(
                _positionStreamSubscription != null
                    ? Icons.location_disabled
                    : Icons.location_searching,
                color: Colors.white,
              ),
              onPressed: _toggleListening,
            ),
          ],
        ),
        body: Center(
          child: _positionStreamSubscription != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Latitude: ${_currentPosition?.latitude ?? "unknown"}',
                      style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 20), // Add spacing
                    Text(
                      'Longitude: ${_currentPosition?.longitude ?? "unknown"}',
                      style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                )
              : const CircularProgressIndicator(
                  color: Colors.white), // Change progress indicator color
        ),
      ),
    );
  }
}
