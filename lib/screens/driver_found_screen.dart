import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keke/screens/trip_in_progress_screen.dart';

class DriverFoundScreen extends StatefulWidget {
  const DriverFoundScreen({super.key});

  @override
  State<DriverFoundScreen> createState() => _DriverFoundScreenState();
}

class _DriverFoundScreenState extends State<DriverFoundScreen> {

  @override
  void initState() {
    super.initState();
    // Simulate a delay for the driver to arrive
    Timer(const Duration(seconds: 5), () {
      Navigator.pop(context); // Close the current sheet
      _showTripInProgressSheet(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.6,
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
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 12.0),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Driver Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Arriving in 5 min', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.shield_outlined, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 16.0),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chinedu O.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 16.0),
                          SizedBox(width: 4.0),
                          Text('4.8 • 120 rides', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                ],
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.orange),
                        SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('VEHICLE', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text('Toyota Corolla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Silver • Sedan', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('PLATE NO.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('ABC - 123 - DE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text('Call Driver', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBF5102),
                      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.message, size: 28.0),
                    color: Colors.black,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTripInProgressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TripInProgressScreen(),
    );
  }
}
