import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keke/screens/driver_found_screen.dart';

class SearchingForDriverScreen extends StatefulWidget {
  const SearchingForDriverScreen({super.key});

  @override
  State<SearchingForDriverScreen> createState() => _SearchingForDriverScreenState();
}

class _SearchingForDriverScreenState extends State<SearchingForDriverScreen> {

  @override
  void initState() {
    super.initState();
    // Simulate a delay for finding a driver
    Timer(const Duration(seconds: 5), () {
      Navigator.pop(context); // Close the current sheet
      _showDriverFoundSheet(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 0.8,
        builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 24.0),
              const Text(
                'Finding nearby drivers...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "Don't worry, this usually takes less than 2 minutes. We're asking drivers around you.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
              const SizedBox(height: 32.0),
              const LinearProgressIndicator(),
              const SizedBox(height: 32.0),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the searching sheet
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                ),
                child: const Text('Cancel Request', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDriverFoundSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DriverFoundScreen(),
    );
  }
}
