// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:qr_reader/presentation/theme/colors.dart';

// ignore: camel_case_types
class widButton extends StatelessWidget {

  final VoidCallback onGenerate;
  final String buttonText;
  const widButton({super.key, required this.onGenerate, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
          onPressed: onGenerate,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: clsColors.buttonGradient,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: clsColors.primaryText,
                ),
              ),
            ),
          ),
        );
  }
}