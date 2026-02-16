import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Activity'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          final isCompleted = index % 2 == 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tue, 12 Oct • 04:30 PM',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        isCompleted ? 'Completed' : 'Canceled',
                        style: TextStyle(
                          color: isCompleted ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24.0),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(
                        index == 0 ? Icons.motorcycle : Icons.electric_rickshaw,
                        color: Colors.black54,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lagos City Mall',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '142 Ahmadu Bello Way',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '₦500.00',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Wallet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 8.0),
                      const Text(
                        'Emmanuel O.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Spacer(),
                      // Re-book button
                      InkWell(
                        onTap: () {},
                        child: Row(
                          children: const [
                            Icon(Icons.refresh,
                                size: 14, color: Color(0xFFBF5102)),
                            SizedBox(width: 4),
                            Text(
                              'Re-book',
                              style: TextStyle(
                                color: Color(0xFFBF5102),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
