import 'package:flutter/material.dart';
import 'package:keke/screens/signup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int? _selectedIndex;

  void _selectCard(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _continue() {
    if (_selectedIndex == null) return;

    // TODO: Navigate to next screen based on selection
    final role = _selectedIndex == 0 ? 'passenger' : 'driver';
    print('Selected role: $role');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                "Welcome to Keke",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B3B3B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "How would you like to use Keke?",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 32),

              // Passenger Card
              GestureDetector(
                onTap: () => _selectCard(0),
                child: buildOptionCard(
                  imagePath: 'images/role.png',
                  title: "I'm a Passenger",
                  subtitle: "Book rides easily and get to your destination",
                  icon1: Icons.flag,
                  label1: "Easy booking",
                  icon2: Icons.safety_check,
                  label2: "Safe rides",
                  selected: _selectedIndex == 0,
                ),
              ),
              const SizedBox(height: 16),

              // Driver Card
              GestureDetector(
                onTap: () => _selectCard(1),
                child: buildOptionCard(
                  imagePath: 'images/role.png',
                  title: "I'm a Driver",
                  subtitle: "Offer rides and earn money on your schedule",
                  icon1: Icons.attach_money,
                  label1: "Earn money",
                  icon2: Icons.schedule,
                  label2: "Flexible hours",
                  selected: _selectedIndex == 1,
                ),
              ),
              const Spacer(),

              // Continue Button
              SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIndex == null ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: _selectedIndex == null
                        ? Colors.grey
                        : const Color(0xFFBF5102),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "By continuing, you agree to our Terms of Service and Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOptionCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required IconData icon1,
    required String label1,
    required IconData icon2,
    required String label2,
    required bool selected,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? const Color(0xFFBF5102) : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(selected ? 0.2 : 0.1),
            spreadRadius: selected ? 2 : 1,
            blurRadius: selected ? 6 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image with Text Overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)),
                child: Image.asset(
                  imagePath,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black54,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black54,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Selection indicator
              if (selected)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBF5102),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          // Bottom section with icons and labels
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  icon1,
                  size: 18,
                  color: selected
                      ? const Color(0xFFBF5102)
                      : const Color(0xFF4B5563),
                ),
                const SizedBox(width: 6),
                Text(
                  label1,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFBF5102)
                        : const Color(0xFF4B5563),
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  icon2,
                  size: 18,
                  color: selected
                      ? const Color(0xFFBF5102)
                      : const Color(0xFF4B5563),
                ),
                const SizedBox(width: 6),
                Text(
                  label2,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFBF5102)
                        : const Color(0xFF4B5563),
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}