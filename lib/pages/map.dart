import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';

class ConductorMapScreen extends StatefulWidget {
  final String usuario;
  
  const ConductorMapScreen({required this.usuario, Key? key}) : super(key: key);

  @override
  _ConductorMapScreenState createState() => _ConductorMapScreenState();
}

class _ConductorMapScreenState extends State<ConductorMapScreen> with WidgetsBindingObserver {
  GoogleMapController? mapController;
  Location location = Location();
  late LatLng _initialcameraposition;
  late StreamSubscription<LocationData> locationSubscription;
  late String _conductorId; // ID único generado para este conductor
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref('user_locations');
  final Map<String, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Agregar observador
    _initialcameraposition = LatLng(0.0, 0.0);
    _conductorId = widget.usuario; // Utilizar el ID de usuario proporcionado
    locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      _updateLocation(currentLocation);
    });
    _listenToUsuarioChanges();
    _loadInitialUsuarioLocations();
  }

  Future<void> _updateLocation(LocationData locationData) async {
    if (!mounted) return;
    
    await databaseReference.child('conductores').child(_conductorId).child('ubicacion').set({
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
    });
    setState(() {
      _initialcameraposition = LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  void _listenToUsuarioChanges() {
    databaseReference.child('usuarios').onChildChanged.listen((event) {
      String userId = event.snapshot.key!;
      Map? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null && data.containsKey('ubicacion')) {
        Map<dynamic, dynamic> ubicacion = data['ubicacion'];
        if (ubicacion != null) {
          double latitude = ubicacion['latitude'];
          double longitude = ubicacion['longitude'];
          _updateMarker(userId, latitude, longitude);
        }
      } else {
        _removeMarker(userId);
      }
    });

    databaseReference.child('usuarios').child('ubicacion').onChildRemoved.listen((event) {
      String userId = event.snapshot.key!;
      _removeMarker(userId);
    });
  }

  void _loadInitialUsuarioLocations() async {
    DataSnapshot snapshot = await databaseReference.child('usuarios').get();
    if (snapshot.value != null) {
      Map<dynamic, dynamic>? usuarios = snapshot.value as Map<dynamic, dynamic>?;
      if (usuarios != null) {
        usuarios.forEach((key, value) {
          if (value is Map<dynamic, dynamic> && value.containsKey('ubicacion')) {
            Map<dynamic, dynamic> ubicacion = value['ubicacion'];
            if (ubicacion != null) {
              double latitude = ubicacion['latitude'];
              double longitude = ubicacion['longitude'];
              _updateMarker(key, latitude, longitude);
            }
          }
        });
      }
    }
  }

  Future<BitmapDescriptor> _getMarkerIconFromAsset() async {
    return await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/user_map.png',
    );
  }

  void _updateMarker(String id, double latitude, double longitude) async {
    if (!mounted) return;

    final icon = await _getMarkerIconFromAsset();
    setState(() {
      _markers.remove(id);
      _markers[id] = Marker(
        markerId: MarkerId(id),
        position: LatLng(latitude, longitude),
        icon: icon,
        infoWindow: InfoWindow(title: 'Usuario $id'),
      );
    });
  }

  void _removeMarker(String id) {
    if (!mounted) return;

    setState(() {
      _markers.remove(id);
    });
  }

  @override
  void dispose() {
    _removeConductorLocation();
    locationSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _removeConductorLocation() {
    databaseReference.child('conductores').child(_conductorId).child('ubicacion').remove();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _removeConductorLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialcameraposition,
          zoom: 15.5,
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
