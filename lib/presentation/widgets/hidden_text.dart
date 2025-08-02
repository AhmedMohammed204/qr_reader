import 'package:flutter/material.dart';
import 'package:qr_reader/presentation/theme/colors.dart';
import 'package:qr_reader/presentation/widgets/wid_hider.dart';

class HiddenText extends StatelessWidget {
  final String _currentPassKey;
  const HiddenText({super.key, required String currentPassKey})
      : _currentPassKey = currentPassKey;

  @override
  Widget build(BuildContext context) {
    return widHider(
      child: Container(
        key: ValueKey(_currentPassKey),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: clsColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.key_rounded,
              color: clsColors.secondaryText,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _currentPassKey,
              style: const TextStyle(
                color: clsColors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}