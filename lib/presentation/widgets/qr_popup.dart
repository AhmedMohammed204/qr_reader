import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_reader/core/qr_bloc/qr_cubit.dart';
import 'package:qr_reader/core/qr_bloc/qr_state.dart';
import 'package:qr_reader/presentation/theme/colors.dart';
import 'package:qr_reader/presentation/widgets/hidden_text.dart';
import 'package:qr_reader/presentation/widgets/qr_image.dart';

class QrDisplayPopup extends StatelessWidget {
  final double amount;
  final Duration duration;
  final DateTime? targetDate;
  final QrCubit qrCubit;

  const QrDisplayPopup({
    super.key,
    required this.amount,
    required this.duration,
    this.targetDate,
    required this.qrCubit,
  });

  String _formatDuration(Duration d) {
    final parts = <String>[];
    if (d.inDays > 0) {
      parts.add('${d.inDays}d');
    }
    if (d.inHours.remainder(24) > 0) {
      parts.add('${d.inHours.remainder(24)}h');
    }
    if (d.inMinutes.remainder(60) > 0) {
      parts.add('${d.inMinutes.remainder(60)}m');
    }
    if (d.inSeconds.remainder(60) > 0 || parts.isEmpty) {
      parts.add('${d.inSeconds.remainder(60)}s');
    }
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: qrCubit,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: clsColors.cardBackground.withValues(alpha:0.85),
                border: Border.all(
                  color: clsColors.secondaryText.withValues(alpha:0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildQrSection(context),
                  const SizedBox(height: 20),
                  _buildDetailsSection(),
                  const SizedBox(height: 24),
                  _buildActionButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const Text(
          "AMOUNT",
          style: TextStyle(
            color: clsColors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: clsColors.primaryText,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQrSection(BuildContext context) {
    return BlocBuilder<QrCubit, QrState>(
      builder: (context, state) {
        if (state is QrCreated) {
          return Column(
            children: [
              QrImageWidget(qrData: state.qrData),
              const SizedBox(height: 16),
              const Text(
                "PASSKEY (TAP TO COPY)",
                style: TextStyle(
                  color: clsColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: state.passKey));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passkey copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: clsColors.successGreen,
                    ),
                  );
                },
                child: HiddenText(currentPassKey: state.passKey),
              ),
            ],
          );
        }
        return SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              color: clsColors.linkBlue.withValues(alpha:0.8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: clsColors.background.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'Expires in',
            value: _formatDuration(duration),
          ),
          if (targetDate != null) ...[
            const Divider(height: 20, color: clsColors.secondaryText),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'On',
              value: DateFormat('dd/MM/yyyy hh:mm a').format(targetDate!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: clsColors.buttonGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Done',
            style: TextStyle(
              color: clsColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: clsColors.secondaryText, size: 18),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(color: clsColors.secondaryText, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: clsColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
