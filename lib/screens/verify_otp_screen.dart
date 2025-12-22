import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keke/stores/auth_store.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String emailOrPhone;
  final VoidCallback onVerified;

  const VerifyOtpScreen({
    super.key,
    required this.emailOrPhone,
    required this.onVerified,
  });

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  String _verificationCode = '';
  int _resendTimer = 60;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus first OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
            _startResendTimer();
          }
        });
      }
    });
  }

  void _handleOtpInput(int index, String value) {
    // Update the verification code
    final otpDigits = _verificationCode.split('');
    if (index < otpDigits.length) {
      otpDigits[index] = value;
    } else {
      otpDigits.add(value);
    }
    _verificationCode = otpDigits.join();

    // Move focus to next field
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
    }

    // Auto-submit when all digits are entered
    if (_verificationCode.length == 6) {
      _verifyOtp();
    }
  }

  void _handleBackspace(int index, String value) {
    if (value.isEmpty && index > 0) {
      // Move focus to previous field
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
      // Clear previous field
      _otpControllers[index - 1].clear();

      // Update verification code
      final otpDigits = _verificationCode.split('');
      if (index - 1 < otpDigits.length) {
        otpDigits[index - 1] = '';
      }
      _verificationCode = otpDigits.join();
    }
  }

  Future<void> _verifyOtp() async {
    if (_verificationCode.length != 6) {
      _showError('Please enter the 6-digit code');
      return;
    }

    final authStore = ref.read(authNotifierProvider.notifier);

    try {
      final result = await authStore.verifyOtp(
        otp: _verificationCode,
        email: widget.emailOrPhone,
      );

      if (result['success'] == true) {
        // Clear OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _verificationCode = '';

        // Call the verification success callback
        widget.onVerified();
      } else {
        _showError(result['message'] ?? 'OTP verification failed');

        // Clear OTP fields on failure for re-entry
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _verificationCode = '';
        FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
      }
    } catch (error) {
      _showError('OTP verification failed: $error');
    }
  }

  Future<void> _resendOtp() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isResending = true;
    });

    final authStore = ref.read(authNotifierProvider.notifier);

    try {
      final result = await authStore.resendOtp(
        email: widget.emailOrPhone,
      );

      if (result['success'] == true) {
        // Reset timer and clear OTP fields
        setState(() {
          _resendTimer = 60;
          _isResending = false;
        });

        // Clear OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _verificationCode = '';
        FocusScope.of(context).requestFocus(_otpFocusNodes[0]);

        // Start the timer again
        _startResendTimer();

        _showSuccess('New code sent successfully');
      } else {
        _showError(result['message'] ?? 'Failed to resend OTP');
        setState(() {
          _isResending = false;
        });
      }
    } catch (error) {
      _showError('Failed to resend OTP: $error');
      setState(() {
        _isResending = false;
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: const Color(0xFF4B5563),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Verify Code',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B3B3B),
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                    children: [
                      const TextSpan(
                        text: 'Enter the 6-digit code sent to\n',
                      ),
                      TextSpan(
                        text: widget.emailOrPhone,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFBF5102),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.only(bottom: 8),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _handleOtpInput(index, value);
                          } else {
                            _handleBackspace(index, value);
                          }
                        },
                        onTap: () {
                          // Clear the field when tapped (for re-entry)
                          _otpControllers[index].clear();
                          final otpDigits = _verificationCode.split('');
                          if (index < otpDigits.length) {
                            otpDigits[index] = '';
                          }
                          _verificationCode = otpDigits.join();
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (isLoading || _verificationCode.length != 6) ? null : _verifyOtp,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Show error message from auth store if any
                if (authState.errorMessage != null && authState.errorMessage!.isNotEmpty)
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

                const SizedBox(height: 24),

                // Resend Code Section
                Column(
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_resendTimer > 0)
                      Text(
                        'Resend code in $_resendTimer seconds',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      )
                    else
                      TextButton(
                        onPressed: (_isResending || isLoading) ? null : _resendOtp,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: _isResending
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBF5102)),
                          ),
                        )
                            : const Text(
                          'Resend Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBF5102),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),

                // Alternative contact method
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Having trouble?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'If you didn\'t receive the code, check your spam folder or try another method.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to alternative verification method
                          print('Use alternative method');
                        },
                        child: const Text(
                          'Use alternative verification method',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBF5102),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}