import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:keke/screens/destination_search_screen.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  void _requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
        _updateMarker();
      });
    });
  }

  void _updateMarker() {
    if (_currentLocation != null) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            infoWindow: const InfoWindow(title: 'My Location'),
          ),
        );
      });
    }
  }

  void _centerOnUser() {
    if (_currentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(6.5244, 3.3792), // Lagos, Nigeria
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          // Top search bar and profile icon
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DestinationSearchScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8.0),
                            const Text(
                              'Where to?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.mic, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('images/user_avatar.png'), // Replace with your avatar asset
                  ),
                ],
              ),
            ),
          ),

          // Center on user button
          Positioned(
            bottom: 300, // Adjust this value to position the button correctly
            right: 16,
            child: FloatingActionButton(
              onPressed: _centerOnUser,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.35,
            maxChildSize: 0.6,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Pull handle
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),

                    // Content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        children: [
                          const Text(
                            'Good evening, Adewale',
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          _buildDestinationTile(
                            icon: Icons.home,
                            title: 'Home',
                            subtitle: '142 Ahmadu Bello Way, Victo...',
                            time: '25 min',
                          ),
                          const SizedBox(height: 16.0),
                          _buildDestinationTile(
                            icon: Icons.work,
                            title: 'Work',
                            subtitle: 'Landmark Centre, Water Cor...',
                            time: '40 min',
                          ),
                        ],
                      ),
                    ),

                    // Bottom Navigation Bar
                    BottomNavigationBar(
                      currentIndex: _selectedIndex,
                      onTap: _onItemTapped,
                      selectedItemColor: const Color(0xFFBF5102),
                      unselectedItemColor: Colors.grey,
                      showUnselectedLabels: true,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.map),
                          label: 'Map',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.list_alt),
                          label: 'Activity',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person),
                          label: 'Account',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationTile(
      {required IconData icon, required String title, required String subtitle, required String time}) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.grey[600]),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
