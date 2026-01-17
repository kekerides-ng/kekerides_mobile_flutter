import 'package:flutter/material.dart';

class DestinationSearchScreen extends StatefulWidget {
  const DestinationSearchScreen({super.key});

  @override
  State<DestinationSearchScreen> createState() => _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends State<DestinationSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan your ride'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
                hintText: 'Ikeja City Mall',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Where to?',
                suffixIcon: const Icon(Icons.close, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShortcut(icon: Icons.home, label: 'Home'),
                _buildShortcut(icon: Icons.work, label: 'Work'),
                _buildShortcut(icon: Icons.fitness_center, label: 'Gym'),
                const CircleAvatar(
                  backgroundColor: Color(0xFFF2F2F2),
                  child: Icon(Icons.add, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Set location on map'),
              onTap: () {},
            ),
            const Divider(),
            const SizedBox(height: 12.0),
            const Text(
              'RECENT',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            _buildRecentTile(
              title: 'Murtala Muhammed Airport',
              subtitle: 'Ikeja, Lagos',
            ),
            _buildRecentTile(
              title: 'Shoprite Jabi Lake',
              subtitle: 'Bala Sokoto Way, Abuja',
            ),
            _buildRecentTile(
              title: 'Eko Hotels & Suites',
              subtitle: 'Adetokunbo Ademola Street, Victoria Island',
            ),
            _buildRecentTile(
              title: 'Landmark Beach',
              subtitle: 'Water Corporation Dr, Lagos',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcut({required IconData icon, required String label}) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFF2F2F2),
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 8.0),
        Text(label),
      ],
    );
  }

  Widget _buildRecentTile({required String title, required String subtitle}) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {},
    );
  }
}
