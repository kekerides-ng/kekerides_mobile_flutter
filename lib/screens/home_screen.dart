import 'package:flutter/material.dart';
import 'package:keke/app_config.dart';
import 'package:keke/screens/driver_account_screen.dart';
import 'package:keke/screens/driver_ratings_screen.dart';
import 'package:keke/screens/driver_earnings_screen.dart';
import 'package:keke/screens/account_screen.dart';
import 'package:keke/screens/activity_screen.dart';
import 'package:keke/screens/destination_search_screen.dart';
import 'package:keke/screens/incoming_request_screen.dart';
import 'package:keke/screens/ride_options_screen.dart';
import 'package:keke/screens/wallet_screen.dart';
import 'package:keke/widgets/map_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<State<MapWidget>> _mapKey = GlobalKey<State<MapWidget>>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPassenger = AppConfig.instance.isPassenger;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          isPassenger ? _buildPassengerHomeTab() : _buildDriverHomeTab(),
          isPassenger ? const ActivityScreen() : const DriverEarningsScreen(),
          isPassenger ? const WalletScreen() : const DriverRatingsScreen(),
          isPassenger ? const AccountScreen() : const DriverAccountScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFBF5102),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: isPassenger ? 'Home' : 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(isPassenger ? Icons.history : Icons.account_balance_wallet),
            label: isPassenger ? 'Activity' : 'EARNINGS',
          ),
          BottomNavigationBarItem(
            icon: Icon(isPassenger ? Icons.account_balance_wallet : Icons.star),
            label: isPassenger ? 'Wallet' : 'RATINGS',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'ACCOUNT',
          ),
        ],
      ),
    );
  }

  Widget _buildDriverHomeTab() {
    return Stack(
      children: [
        MapWidget(key: _mapKey),
        
        // Top Section
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Profile & Notification Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage('images/driver_profile.png'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'THE RESILIENT',
                              style: TextStyle(
                                color: Color(0xFFBF5102),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'NAVIGATOR',
                              style: TextStyle(
                                color: Color(0xFFBF5102),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.notifications, color: Color(0xFFBF5102), size: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Earnings Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TODAY'S EARNINGS",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            "₦ 45,200",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Online",
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Go Offline Button
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Logic for incoming request simulation (for testing)
                    _simulateIncomingRequest();
                  },
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text(
                    "GO OFFLINE",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF5102),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _simulateIncomingRequest() {
    // This will be replaced by actual logic later
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const IncomingRequestScreen(),
    );
  }

  Widget _buildPassengerHomeTab() {
    return Stack(
      children: [
        // Map Widget
        MapWidget(key: _mapKey),

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
                      ).then((value) {
                        if (value == true) {
                          // Show the ride options sheet
                          _showRideOptionsSheet();
                        }
                      });
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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3; // Switch to Account tab
                    });
                  },
                  child: const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.person, size: 32),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Center on user button
        Positioned(
          bottom: 300, 
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              // Access the MapWidget's state to call centerOnUser
              final dynamic mapWidgetState = _mapKey.currentState;
              mapWidgetState?.centerOnUser();
            },
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
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showRideOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RideOptionsScreen(),
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
