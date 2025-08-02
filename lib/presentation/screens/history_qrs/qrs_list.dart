import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_reader/core/DTOs/qr_dtos.dart';
import 'package:qr_reader/core/qr_bloc/qr_cubit.dart';
import 'package:qr_reader/core/qr_bloc/qr_state.dart';
import 'package:qr_reader/presentation/theme/colors.dart';
import 'package:qr_reader/presentation/widgets/hidden_text.dart';

class QrsList extends StatelessWidget {
  final List<QrDTO> qrs;
  const QrsList({super.key, required this.qrs});

  @override
  Widget build(BuildContext context) {
    if (qrs.isEmpty) {
      return const _EmptyState();
    }

    qrs.sort((a, b) {
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: qrs.length,
      itemBuilder: (context, index) {
        return BlocProvider(
          create: (context) => ManageQrCubit(),
          child: _QrCard(qr: qrs[index]),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner_rounded,
            size: 80,
            color: clsColors.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No QR Codes Found',
            style: TextStyle(color: clsColors.secondaryText, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a new QR code to see it here.',
            style: TextStyle(color: clsColors.secondaryText.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatefulWidget {
  final QrDTO qr;
  const _QrCard({required this.qr});

  @override
  State<_QrCard> createState() => _QrCardState();
}

class _QrCardState extends State<_QrCard> {
  late bool _isActive;
  late bool _isExpired;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _isActive = widget.qr.isActive;
    _updateExpirationStatus();

    if (_isActive && !_isExpired) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateExpirationStatus();
      });
    }
  }

  void _updateExpirationStatus() {
    final now = DateTime.now();
    final isExpiredNow = now.isAfter(widget.qr.expiresAt);

    if (mounted) {
      setState(() {
        _isExpired = isExpiredNow;
        if (_isExpired) {
          _timer?.cancel();
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double _calculateExpirationProgress() {
    final now = DateTime.now();
    if (!_isActive || now.isAfter(widget.qr.expiresAt)) {
      return 1.0;
    }
    final totalDuration = widget.qr.expiresAt
        .difference(widget.qr.createdAt)
        .inSeconds;
    if (totalDuration <= 0) return 1.0;
    final elapsed = now.difference(widget.qr.createdAt).inSeconds;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  String _formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final difference = dt.difference(now);

    if (difference.isNegative) {
      return "Expired ${DateFormat.yMMMd().format(dt)}";
    }
    if (difference.inDays > 0) {
      return 'in ${difference.inDays}d ${difference.inHours.remainder(24)}h';
    }
    if (difference.inHours > 0) {
      return 'in ${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    }
    if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes}m ${difference.inSeconds.remainder(60)}s';
    }
    if (difference.inSeconds > 0) {
      return 'in ${difference.inSeconds}s';
    }
    return 'Expiring now';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageQrCubit, ManageQrState>(
      listener: (context, state) {
        if (state is QrDeactivationError) {
          _showErrorDialog(context, state.message);
        }
        if (state is QrDeactivated) {
          setState(() {
            _isActive = false;
            _timer?.cancel();
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: clsColors.cardBackground.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: clsColors.secondaryText.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  const Divider(height: 20, color: clsColors.secondaryText),
                  _buildInfoSection(),
                  const SizedBox(height: 12),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "AMOUNT",
              style: TextStyle(
                color: clsColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${widget.qr.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: clsColors.primaryText,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        _StatusChip(isActive: _isActive, isExpired: _isExpired),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          text: 'Created: ${DateFormat.yMMMd().format(widget.qr.createdAt)}',
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.timer_outlined,
          text: 'Expires ${_formatRelativeTime(widget.qr.expiresAt)}',
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _calculateExpirationProgress(),
          backgroundColor: clsColors.secondaryText.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            _isExpired || !_isActive
                ? clsColors.secondaryText
                : clsColors.successGreen,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final canBeDeactivated = _isActive && !_isExpired;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: HiddenText(currentPassKey: widget.qr.passKey)),
        if (canBeDeactivated)
          BlocBuilder<ManageQrCubit, ManageQrState>(
            builder: (context, state) {
              if (state is QrDeactivating) {
                return const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: clsColors.linkBlue,
                  ),
                );
              }
              return IconButton(
                icon: const Icon(
                  Icons.power_settings_new_rounded,
                  color: clsColors.errorRed,
                ),
                onPressed: () =>
                    _showDeactivationConfirmationDialog(context, widget.qr),
                tooltip: 'Deactivate QR',
                splashRadius: 20,
              );
            },
          ),
      ],
    );
  }

  void _showDeactivationConfirmationDialog(BuildContext context, QrDTO qr) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: clsColors.cardBackground.withValues(alpha: 0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(color: clsColors.secondaryText.withValues(alpha: 0.2)),
            ),
            title: const Text(
              'Confirm Deactivation',
              style: TextStyle(
                color: clsColors.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: clsColors.secondaryText,
                  fontSize: 15,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Are you sure you want to deactivate this QR code?\n\n',
                  ),
                  TextSpan(
                    text: 'Amount: \$${qr.amount.toStringAsFixed(2)}\n',
                    style: const TextStyle(
                      color: clsColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: 'ID: ${qr.id}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: clsColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<ManageQrCubit>().deactivateQr(qr.id);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  'Deactivate',
                  style: TextStyle(
                    color: clsColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;
  final bool isExpired;
  const _StatusChip({required this.isActive, required this.isExpired});

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color color;

    if (!isActive) {
      text = 'Inactive';
      color = clsColors.secondaryText;
    } else if (isExpired) {
      text = 'Expired';
      color = clsColors.errorRed;
    } else {
      text = 'Active';
      color = clsColors.successGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: clsColors.secondaryText, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: clsColors.secondaryText,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: clsColors.cardBackground.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: clsColors.secondaryText.withValues(alpha: 0.2)),
          ),
          title: const Text(
            'Error',
            style: TextStyle(color: clsColors.errorRed),
          ),
          content: Text(
            message,
            style: const TextStyle(color: clsColors.secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: clsColors.linkBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
