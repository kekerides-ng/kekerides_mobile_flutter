import 'package:flutter/material.dart';
import 'package:keke/screens/chat_screen.dart';
import 'package:keke/screens/home_screen.dart';
import 'package:keke/screens/rating_screen.dart';

class TripInProgressScreen extends StatelessWidget {
  const TripInProgressScreen({super.key});

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DESTINATION', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const Text('Lagos City Mall', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                      Row(
                        children: const [
                          Chip(
                            label: Text('On Time', style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.zero,
                          ),
                          SizedBox(width: 8),
                          Text('Arrival 10:45 AM', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Text('12', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFBF5102))),
                        Text('MINS', style: TextStyle(color: Color(0xFFBF5102))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress'),
                  Text('Elapsed: 08:32'),
                ],
              ),
              const SizedBox(height: 8.0),
              const LinearProgressIndicator(value: 0.7, minHeight: 6, color: Color(0xFFBF5102), backgroundColor: Colors.orangeAccent),
               const SizedBox(height: 8.0),
              const Text('3.4 km remaining', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24.0),
               Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Row(
                       children: [
                         CircleAvatar(
                           radius: 20,
                           child: Icon(Icons.person, size: 24),
                         ),
                         SizedBox(width: 12),
                         Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Emmanuel O.', style: TextStyle(fontWeight: FontWeight.bold)),
                             Text('Toyota Camry • LSD-429...', style: TextStyle(color: Colors.grey)),
                           ],
                         ),
                       ],
                     ),
                     Row(
                       children: [
                         IconButton(onPressed: (){}, icon: const Icon(Icons.call, color: Color(0xFFBF5102))),
                         IconButton(
                           onPressed: (){
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => const ChatScreen(driverName: 'Emmanuel O.')),
                             );
                           }, 
                           icon: const Icon(Icons.message, color: Color(0xFFBF5102))
                         ),
                       ],
                     )
                   ],
                 ),
               ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(icon: Icons.share, label: 'Share'),
                  _buildActionButton(icon: Icons.shield, label: 'Safety'),
                  ElevatedButton.icon(
                    onPressed: () {
                      // End trip simulation
                      Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(builder: (_) => const HomeScreen()), 
                          (route) => false
                      );
                      // Show rating screen
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const RatingScreen(driverName: 'Emmanuel O.'),
                      );
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('End Trip', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBF5102),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({required IconData icon, required String label}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.black, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
