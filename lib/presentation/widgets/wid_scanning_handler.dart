import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_reader/core/qr_bloc/qr_cubit.dart';
import 'package:qr_reader/core/qr_bloc/qr_state.dart';
import 'package:qr_reader/presentation/theme/colors.dart';
import 'package:qr_reader/presentation/widgets/wid_numaric_input.dart';

// ignore: camel_case_types
class widScanningHandler extends StatelessWidget {
  final VoidCallback onScanFlowComplete;
  final Widget child;

  const widScanningHandler({
    super.key,
    required this.onScanFlowComplete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<QrCubit, QrState>(
      listener: (context, state) {
        if (state is QrDetected) {
          _startScanFlow(context, state.encryptedQr);
        } else if (state is QrErrorScan) {
          _scanField(context);
        } else if (state is QrError) {
          _showResultDialog(
            context,
            title: 'Scan Error --1',
            message: state.message,
            icon: Icons.error_outline_rounded,
            iconColor: Colors.redAccent,
          ).then((_) => onScanFlowComplete());
        }
        else if (state is QrSuccessScan) {
          _showResultDialog(
            context,
            title: 'Scan Successful',
            message: 'Payment completed successfully.',
            icon: Icons.check_circle_outline_rounded,
            iconColor: Colors.green,
          ).then((_) => onScanFlowComplete());
        }
      },
      child: child,
    );
  }

  Future<void> _startScanFlow(BuildContext context, String encryptedQr) async {
    final enteredAmount = await _showAmountPrompt(context);
    if (enteredAmount == null) {
      onScanFlowComplete();
      return;
    }
    if(!context.mounted) return;
    final passKeyCorrect = await _showPasswordPrompt(context, enteredAmount);
    if (passKeyCorrect == null) {
      if (!context.mounted) return;
      context.read<QrCubit>().scanningError();
    } else {
      if (!context.mounted) return;
      context.read<QrCubit>().scanQr(
        encryptedQr: encryptedQr,
        amount: enteredAmount,
        passkey: passKeyCorrect,
      );
    }

    onScanFlowComplete();
  }

  Future<double?> _showAmountPrompt(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: clsColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Enter Amount',
          style: TextStyle(color: clsColors.primaryText),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: clsColors.primaryText,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: 'SAR ',
              prefixStyle: const TextStyle(
                color: clsColors.secondaryText,
                fontSize: 22,
              ),
              hintText: '0.00',
              hintStyle: TextStyle(
                color: clsColors.secondaryText.withValues(alpha: .5),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: clsColors.secondaryText),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: clsColors.gradientEnd, width: 2),
              ),
            ),
            validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                ? 'Enter a valid amount'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text(
              'Cancel',
              style: TextStyle(color: clsColors.secondaryText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: clsColors.gradientEnd,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(double.parse(controller.text));
              }
            },
            child: const Text(
              'Next',
              style: TextStyle(color: clsColors.primaryText),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showPasswordPrompt(BuildContext context, double enteredAmount) {
    final controller = TextEditingController();
    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: clsColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        // The title is clear and concise
        title: Text(
          'Enter Passkey for Payment of SAR ${enteredAmount.toStringAsFixed(2)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: clsColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This payment is protected.',
              textAlign: TextAlign.center,
              style: TextStyle(color: clsColors.secondaryText, fontSize: 14),
            ),
            const SizedBox(height: 24),
            widNumericInput(
              controller: controller,
              length: 4,
              isPassword: true,
              activeColor: clsColors.gradientEnd,
              textColor: clsColors.primaryText,
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: clsColors.gradientEnd,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop(controller.text);
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: clsColors.primaryText, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    ).then((result) => result);
  }

  Future<void> _showResultDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: clsColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: clsColors.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                color: clsColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: clsColors.linkBlue,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(color: clsColors.primaryText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _scanField(BuildContext context) async {
    await _showResultDialog(
      context,
      title: 'Scan Failed',
      message: 'This QR code is invalid or has expired.',
      icon: Icons.error_outline_rounded,
      iconColor: Colors.redAccent,
    );
    onScanFlowComplete();
  }
}
