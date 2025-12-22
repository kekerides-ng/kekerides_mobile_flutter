import 'package:flutter/material.dart';
import 'package:keke/screens/login_screen.dart';
import 'package:keke/screens/role_selection_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({Key? key}) : super(key: key);

  // Helper to build white rounded buttons with left icon and centered text
  Widget _buildAuthButton({
    required Widget leading,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Gradient bottomGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        Color(0xFFd48b56),
        Color(0xFFBF5102),
      ],
      stops: [0.0, 0.55, 1.0],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top area: logo + tagline
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  Image.asset('images/logo2.png', width: 120),
                  const SizedBox(height: 12),
                  const Text(
                    'Ride hailing made easy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom card-like area with gradient background
            Expanded(
              flex: 7,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: bottomGradient,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Social buttons with actual logos
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            // Google button with logo
                            _buildAuthButton(
                              leading: Image.asset(
                                'images/google.png', // Add your Google logo image
                                width: 24,
                                height: 24,
                              ),
                              text: 'Continue with Google',
                              onTap: () {
                                // TODO: implement google sign in
                              },
                            ),

                            // Apple button with logo
                            _buildAuthButton(
                              leading: Image.asset(
                                'images/apple.png', // Add your Apple logo image
                                width: 24,
                                height: 24,
                              ),
                              text: 'Continue with Apple',
                              onTap: () {
                                // TODO: implement apple sign in
                              },
                            ),

                            // Facebook button with logo
                            _buildAuthButton(
                              leading: Image.asset(
                                'images/facebook_logo.png', // Add your Facebook logo image
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1877F2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'f',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              text: 'Continue with Facebook',
                              onTap: () {
                                // TODO: implement facebook sign in
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Divider with "Or"
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Or',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Continue with email button
                      _buildAuthButton(
                        leading: const SizedBox(width: 0),
                        text: 'Continue with email',
                        textColor: const Color(0xFFBF5102),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RoleSelectionScreen(),
                            ),
                          );
                        },
                      ),

                      const Spacer(),

                      // Bottom footer
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.9)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}