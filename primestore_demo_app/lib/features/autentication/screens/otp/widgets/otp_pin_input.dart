import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class TotpInputWidget extends StatelessWidget {
  const TotpInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Default style for empty/inactive boxes
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // Soft grey background fill
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
    );

    // Style when a box is actively focused
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF2563EB), width: 1.5), // Blue border
      ),
    );

    // Style when a box has a number filled in
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
    );

    return Pinput(
      length: 6,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      showCursor: true,
      cursor: Container(
        width: 2,
        height: 24,
        color: const Color(0xFF2563EB),
      ),
      onChanged: (value) {
        // Handle character changes
      },
      onCompleted: (pin) {
        print("Entered OTP: $pin");
      },
    );
  }
}
