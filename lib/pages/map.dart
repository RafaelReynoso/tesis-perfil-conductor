import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class ConductorMapScreen extends StatefulWidget {
  const ConductorMapScreen({super.key});

  @override
  _ConductorMapScreenState createState() => _ConductorMapScreenState();
}

class _ConductorMapScreenState extends State<ConductorMapScreen> {
  GoogleMapController? mapController;
  Location location = Location();
  late LatLng _initialcameraposition;
  late StreamSubscription<LocationData> locationSubscription;
  late String _conductorId;
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('user_locations');
  Map<String, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initialcameraposition = LatLng(0.0, 0.0);
    _conductorId = Uuid().v4();
    locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      _updateLocation(currentLocation);
    });
    _listenToUsuarioChanges();
    _loadInitialUsuarioLocations();
  }

  Future<void> _updateLocation(LocationData locationData) async {
    await databaseReference.child('conductores').child(_conductorId).set({
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
    });
    setState(() {
      _initialcameraposition = LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  void _listenToUsuarioChanges() {
    databaseReference.child('usuarios').onChildChanged.listen((event) {
      String usuarioId = event.snapshot.key!;
      Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
      double latitude = data['latitude'];
      double longitude = data['longitude'];
      _updateMarker(usuarioId, latitude, longitude);
    });
  }

  void _loadInitialUsuarioLocations() async {
    DataSnapshot snapshot = await databaseReference.child('usuarios').get();
    Map<dynamic, dynamic>? usuarios = snapshot.value as Map<dynamic, dynamic>?;
    usuarios?.forEach((key, value) {
      double latitude = value['latitude'];
      double longitude = value['longitude'];
      _updateMarker(key, latitude, longitude);
    });
  }

  void _updateMarker(String id, double latitude, double longitude) {
    setState(() {
      _markers.remove(id);  // Eliminar el marcador anterior
      _markers[id] = Marker(
        markerId: MarkerId(id),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: 'Usuario $id'),
      );
    });
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialcameraposition,
          zoom: 14.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: Set<Marker>.of(_markers.values),
      ),
    );
  }
}
