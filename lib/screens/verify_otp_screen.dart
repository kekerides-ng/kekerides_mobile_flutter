import 'dart:async';
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
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _otpFocusNodes;
  String _verificationCode = '';

  int _resendTimer = 60;
  Timer? _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (index) => TextEditingController());
    _otpFocusNodes = List.generate(6, (index) => FocusNode());
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _handleOtpInput(int index, String value) {
    // Update the verification code
    final otpDigits = _verificationCode.split('');
    while (otpDigits.length <= index) {
      otpDigits.add('');
    }
    otpDigits[index] = value;
    _verificationCode = otpDigits.join();

    // Move to the next field if there is a value
    if (value.isNotEmpty && index < _otpControllers.length - 1) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
    }

    // If all fields are filled, trigger verification
    if (_verificationCode.length == 6 &&
        !_verificationCode.contains(RegExp(r'\s'))) {
      _verifyOtp();
    }
  }

  void _handleBackspace(int index, String value) {
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    }
  }

  Future<void> _verifyOtp() async {
    final authStore = ref.read(authNotifierProvider.notifier);

    try {
      final result = await authStore.verifyOtp(
        otp: _verificationCode,
        email: widget.emailOrPhone,
      );

      if (result['success'] == true) {
        widget.onVerified();
      } else {
        _showError(result['message'] ?? 'OTP verification failed');
        // Clear OTP fields on failure
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button aligned to start
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: const Color(0xFF4B5563),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: 20),

                // Title - centered
                const Text(
                  'Verify Code',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B3B3B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description - centered
                Column(
                  children: [
                    const Text(
                      'Enter the 6-digit code sent to',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.emailOrPhone,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // OTP Input Fields - centered with proper spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _otpFocusNodes[index].hasFocus
                              ? const Color(0xFFBF5102)
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
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

                // Verify Button - centered
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (isLoading || _verificationCode.length != 6)
                        ? null
                        : _verifyOtp,
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
                      'Verify',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Show error message from auth store if any
                // if (authState.errorMessage != null &&
                //     authState.errorMessage!.isNotEmpty)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 16),
                //     child: Text(
                //       authState.errorMessage!,
                //       style: const TextStyle(
                //         color: Colors.red,
                //         fontSize: 14,
                //       ),
                //       textAlign: TextAlign.center,
                //     ),
                //   ),

                const SizedBox(height: 24),

                // Resend Code Section - centered
                Column(
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (_resendTimer > 0)
                      Text(
                        'Resend code in $_resendTimer seconds',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      TextButton(
                        onPressed:
                        (_isResending || isLoading) ? null : _resendOtp,
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFBF5102)),
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

                // Alternative contact method - centered
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Having trouble?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'If you didn\'t receive the code, check your spam folder or try another method.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
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
                          textAlign: TextAlign.center,
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
