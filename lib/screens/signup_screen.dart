import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keke/screens/home_screen.dart';
import 'package:keke/screens/login_screen.dart';
import 'package:keke/screens/verify_otp_screen.dart';
import 'package:keke/stores/auth_store.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final String role;
  const SignupScreen({super.key, this.role = 'passenger'});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licenseExpiryController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    if (_firstNameController.text.isEmpty) {
      _showError('Please enter your first name');
      return false;
    }

    if (_lastNameController.text.isEmpty) {
      _showError('Please enter your last name');
      return false;
    }

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError('Please enter a valid email address');
      return false;
    }

    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      _showError('Please enter a valid phone number');
      return false;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }

    if (widget.role == 'driver') {
      if (_licenseNumberController.text.isEmpty) {
        _showError('Please enter your license number');
        return false;
      }
      if (_licenseExpiryController.text.isEmpty) {
        _showError('Please enter your license expiry date');
        return false;
      }
    }

    if (!_acceptTerms) {
      _showError('You must accept the terms and conditions');
      return false;
    }

    return true;
  }

  Future<void> _signup() async {
    if (!_validateFields()) return;

    final authStore = ref.read(authNotifierProvider.notifier);

    try {
      Map<String, dynamic> result;

      if (widget.role == 'driver') {
        result = await authStore.signUpDriver(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          licenseNumber: _licenseNumberController.text.trim(),
          licenseExpiry: _licenseExpiryController.text.trim(),
        );
      } else {
        result = await authStore.signUp(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          acceptTerms: _acceptTerms,
          role: widget.role,
        );
      }

      if (result['success'] == true) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        _showError(result['message'] ?? 'Signup failed');
      }
    } catch (error) {
      _showError('Signup failed: $error');
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFBF5102),
              onPrimary: Colors.white,
              onSurface: Color(0xFF374151),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _licenseExpiryController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final displayRole = widget.role == 'driver' ? 'Driver!' : 'Traveler!';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color(0xFF4B5563),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Hello ',
                      style: TextStyle(
                        color: const Color(0xFF3B3B3B),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: displayRole,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // First Name and Last Name Fields (Side by Side)
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      hint: 'First name',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      hint: 'Last name',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                inputType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 18),

              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                inputType: TextInputType.phone,
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 18),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Create a password',
                isPassword: true,
                isVisible: _isPasswordVisible,
                onVisibilityChanged: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 18),

              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                isPassword: true,
                isVisible: _isConfirmPasswordVisible,
                onVisibilityChanged: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 18),

              if (widget.role == 'driver') ...[
                _buildTextField(
                  controller: _licenseNumberController,
                  label: 'License Number',
                  hint: 'Enter your driver license number',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _licenseExpiryController,
                  label: 'License Expiry',
                  hint: 'YYYY-MM-DD',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _selectExpiryDate,
                ),
                const SizedBox(height: 18),
              ],

              const SizedBox(height: 24),

              // Accept Terms Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to the terms and conditions',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF5102),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              if (authState.errorMessage != null &&
                  authState.errorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    authState.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(left: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xFFBF5102),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityChanged,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade400,
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    icon,
                    color: const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: isPassword && !isVisible,
                  keyboardType: inputType,
                  readOnly: readOnly,
                  onTap: onTap,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (isPassword)
                IconButton(
                  icon: Icon(
                    isVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF9CA3AF),
                  ),
                  onPressed: onVisibilityChanged,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
