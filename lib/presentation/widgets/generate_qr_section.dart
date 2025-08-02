// lib/generate_qr_section.dart

import 'package:flutter/material.dart';
import 'package:qr_reader/presentation/theme/colors.dart';
import 'package:qr_reader/presentation/widgets/wid_button.dart';

class GenerateQrSection extends StatelessWidget {
  final TextEditingController amountController;
  final VoidCallback onGenerate;

  const GenerateQrSection({
    super.key,
    required this.amountController,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: amountController,
          style: const TextStyle(
            color: clsColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter Amount',
            hintStyle: const TextStyle(
              color: clsColors.secondaryText,
              fontWeight: FontWeight.normal,
            ),
            suffixText: 'SAR',
            suffixStyle: const TextStyle(
              color: clsColors.secondaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: clsColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
        const SizedBox(height: 24),
        widButton(onGenerate: onGenerate, buttonText: 'Generate QR Code'),
      ],
    );
  }
}
