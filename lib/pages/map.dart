import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  late LocationData currentLocation;
  late GoogleMapController mapController;
  late Location location;

  //Marcadores Emulador
  //static const LatLng bus1 = LatLng(37.42391615546027, -122.0779517465993);
  //static const LatLng bus2 = LatLng(37.42878293261052, -122.07808236483937);
  //static const LatLng bus3 = LatLng(37.43342057327887, -122.08215321804273);

  //Marcadores Lima
  //static const LatLng bus4 = LatLng(-12.04787152442874, -76.94837189886861);
  //static const LatLng bus5 = LatLng(-12.043220436234485, -76.93618727254686);
  //static const LatLng bus6 = LatLng(-12.03170355955648, -76.92669225115603);
  
  //Marcador Usuario
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  //Marcador bus
  BitmapDescriptor sourceIconBus = BitmapDescriptor.defaultMarker;
  BitmapDescriptor busIcon = BitmapDescriptor.defaultMarker;


  void setCustomMarkerIcon(){
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/bus.png").then((icon){
      sourceIcon = icon;
    },);
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/bus.png").then((icon){
      currentLocationIcon = icon;
    },);
  }

  //void setCustomMarkerIconBus(){
    //BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/bus.png").then((iconBus){
      //sourceIconBus = iconBus;
    //},);
    //BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/bus.png").then((iconBus){
      //busIcon = iconBus;
    //},);
  //}

  @override
  void initState() {
    super.initState();
    currentLocation = LocationData.fromMap({"latitude": 0.0, "longitude": 0.0});
    location = Location();
    setCustomMarkerIcon();
    //setCustomMarkerIconBus();
    initLocation();
  }

  void initLocation() async {
    await location.requestPermission();
    location.onLocationChanged.listen((LocationData cLoc) {
      if (mounted) {
        setState(() {
          currentLocation = cLoc;
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(cLoc.latitude!, cLoc.longitude!),
                zoom: 15.5,
              ),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 14.5,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("currentLocation"),
            icon: currentLocationIcon,
            position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}