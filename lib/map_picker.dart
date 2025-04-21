import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _pickedLocation;
  String? _pickedAddress;
  GoogleMapController? _mapController;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accès à la localisation refusé.')),
      );
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
    _mapController?.moveCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
  }

  Future<void> _onTap(LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    String address = placemarks.isNotEmpty
        ? '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}'
        : '${position.latitude}, ${position.longitude}';
    setState(() {
      _pickedLocation = position;
      _pickedAddress = address;
    });
  }

  void _confirmLocation() {
    if (_pickedLocation != null) {
      Navigator.of(context).pop({
        'lat': _pickedLocation!.latitude,
        'lng': _pickedLocation!.longitude,
        'address': _pickedAddress ?? '${_pickedLocation!.latitude},${_pickedLocation!.longitude}'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un lieu de réunion'), backgroundColor: const Color(0xFF491B6D)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(36.7525, 3.0420), zoom: 10),
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                _mapController!.moveCamera(CameraUpdate.newLatLng(
                  LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                ));
              }
            },
            onTap: _onTap,
            markers: {
              if (_pickedLocation != null)
                Marker(
                  markerId: const MarkerId('picked'),
                  position: _pickedLocation!,
                ),
              if (_currentPosition != null)
                Marker(
                  markerId: const MarkerId('current'),
                  position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  infoWindow: const InfoWindow(title: 'Votre position'),
                ),
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Color(0xFF491B6D)),
              onPressed: () async {
                await _determinePosition();
                if (_currentPosition != null) {
                  _mapController?.animateCamera(CameraUpdate.newLatLng(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  ));
                }
              },
              tooltip: 'Aller à ma position',
            ),
          ),
          if (_pickedAddress != null)
            Positioned(
              bottom: 100,
              left: 10,
              right: 10,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(_pickedAddress!, textAlign: TextAlign.center),
                ),
              ),
            ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Confirmer ce lieu'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _pickedLocation == null ? null : _confirmLocation,
            ),
          ),
        ],
      ),
    );
  }
}
