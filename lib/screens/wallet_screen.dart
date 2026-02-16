import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBF5102), Color(0xFFD97020)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBF5102).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    '₦ 12,500.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showInterswitchFundingSheet(context);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Top Up'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFBF5102),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.history, color: Colors.white),
                          label: const Text('History', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32.0),
            
            const Text(
              'Payment Methods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            
            // Interswitch Card Item
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.blue[900], // Interswitch Blue-ish
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Center(
                    child: Text(
                      'VERVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                title: const Text('**** **** **** 4231'),
                subtitle: const Text('Expires 12/25'),
                trailing: Radio(value: true, groupValue: true, onChanged: (v) {}, activeColor: const Color(0xFFBF5102)),
              ),
            ),
            
            const SizedBox(height: 16.0),
            
            // Add New Card
            GestureDetector(
              onTap: () {
                 _showInterswitchFundingSheet(context);
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_circle_outline, color: Color(0xFFBF5102)),
                    SizedBox(width: 8.0),
                    Text(
                      'Add New Card',
                      style: TextStyle(
                        color: Color(0xFFBF5102),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32.0),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            
            // Transactions List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index == 0 ? Colors.red[50] : Colors.green[50],
                      child: Icon(
                        index == 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        color: index == 0 ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(index == 0 ? 'Ride Payment' : 'Wallet Top Up'),
                    subtitle: Text(index == 0 ? 'Yesterday, 4:30 PM' : 'Today, 9:00 AM'),
                    trailing: Text(
                      index == 0 ? '- ₦500.00' : '+ ₦2,000.00',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: index == 0 ? Colors.red : Colors.green,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInterswitchFundingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Interswitch Logo placeholder text or simple UI
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text(
                    'Secured by ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Interswitch',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'GROUP',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              const TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₦ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Redirecting to Interswitch WebPay...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF5102),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('Proceed to Pay', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}
