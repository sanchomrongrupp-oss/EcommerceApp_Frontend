import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(
    13.7563,
    100.5018,
  ); // Default to Bangkok
  String _address = "Fetching location...";

  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _address = "Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _address = "Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _address = "Location permissions are permanently denied.");
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    _updatePosition(LatLng(position.latitude, position.longitude));
  }

  void _updatePosition(LatLng position) async {
    setState(() {
      _currentPosition = position;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(position));

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}";
        });
      }
    } catch (e) {
      setState(() => _address = "Could not find address.");
    }
  }

  @override
  Widget build(BuildContext context) {
    const kMainColor = Color.fromARGB(255, 227, 207, 54);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Select Location",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        parallaxEnabled: true,
        parallaxOffset: .5,
        panel: _buildAddressDetails(kMainColor),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 15,
              ),
              onMapCreated: (controller) => _mapController = controller,
              onCameraMove: (position) => _currentPosition = position.target,
              onCameraIdle: () => _updatePosition(_currentPosition),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              padding: const EdgeInsets.only(bottom: 200),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 200),
                child: Icon(Icons.location_on, color: Colors.red, size: 50),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 280,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _determinePosition,
                child: const Icon(Icons.my_location, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetails(Color kMainColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Select Delivery Address",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _address,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const TextField(
            decoration: InputDecoration(
              hintText: "Flat / House No. / Floor",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const TextField(
            decoration: InputDecoration(
              hintText: "Nearby Landmark (Optional)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kMainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // Save and pop
                Navigator.pop(context, _address);
              },
              child: const Text(
                "Confirm Location",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
