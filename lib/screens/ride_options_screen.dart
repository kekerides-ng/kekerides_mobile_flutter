import 'package:flutter/material.dart';
import 'package:keke/screens/searching_for_driver_screen.dart';

class RideOptionsScreen extends StatefulWidget {
  const RideOptionsScreen({super.key});

  @override
  State<RideOptionsScreen> createState() => _RideOptionsScreenState();
}

class _RideOptionsScreenState extends State<RideOptionsScreen> {
  String _selectedRide = 'Keke';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 0.8,
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
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16.0),
            children: [
              // Pull handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Select Ride',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              _buildRideOption(
                context,
                icon: Icons.electric_rickshaw,
                title: 'Keke',
                time: '1-3 min',
                price: 'N500-600',
                isSelected: _selectedRide == 'Keke',
              ),
              const SizedBox(height: 12.0),
              _buildRideOption(
                context,
                icon: Icons.motorcycle,
                title: 'Bike',
                time: '1 min',
                price: 'N300-400',
                tag: 'Fastest',
                isSelected: _selectedRide == 'Bike',
              ),
              const SizedBox(height: 24.0),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                title: const Text('Payment Method'),
                subtitle: const Text('Cash'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                   Navigator.pop(context); // Close the ride options sheet
                  _showSearchingForDriverSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBF5102),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text('Confirm $_selectedRide', style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSearchingForDriverSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchingForDriverScreen(),
    );
  }

  Widget _buildRideOption(BuildContext context, {required IconData icon, required String title, required String time, required String price, String? tag, bool isSelected = false}) {
    return GestureDetector(
       onTap: () {
         setState(() {
           _selectedRide = title;
         });
       },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF4E6) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFBF5102) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16.0, color: Colors.grey),
                    const SizedBox(width: 4.0),
                    Text(time, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                if (tag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(tag, style: TextStyle(color: Colors.green[800], fontSize: 12.0)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
