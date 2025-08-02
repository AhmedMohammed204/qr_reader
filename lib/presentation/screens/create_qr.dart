import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_reader/core/qr_bloc/qr_cubit.dart';
import 'package:qr_reader/core/qr_bloc/qr_state.dart';
import 'package:qr_reader/data/general/cls_general.dart';
import 'package:qr_reader/presentation/theme/colors.dart';
import 'package:qr_reader/presentation/theme/font_theme.dart';
import 'package:qr_reader/presentation/widgets/generate_options_popup.dart';
import 'package:qr_reader/presentation/widgets/generate_qr_section.dart';
import 'package:qr_reader/presentation/widgets/hidden_text.dart';
import 'package:qr_reader/presentation/widgets/qr_image.dart';
import 'package:qr_reader/presentation/widgets/qr_popup.dart';
import 'package:qr_reader/presentation/widgets/wid_hider.dart';

class CreateQR extends StatefulWidget {
  const CreateQR({super.key});
  @override
  State<CreateQR> createState() => _CreateQRState();
}

class _CreateQRState extends State<CreateQR> with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  late BuildContext parentContext;

  Timer? _timer;
  late AnimationController _animationController;
  static const int _refreshDurationInSeconds = 15;
  String? _currentPassKey;

  @override
  void initState() {
    super.initState();
    parentContext = context;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _refreshDurationInSeconds),
    );
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _generateMainQrCode();
    _timer = Timer.periodic(
      const Duration(seconds: _refreshDurationInSeconds),
      (timer) => _generateMainQrCode(),
    );
  }

  void _generateMainQrCode() async {
    _animationController.forward(from: 0.0);

    double? balance = await clsGeneral.balance;
    if (!mounted) return;

    if (balance <= 0) {
      context.read<MainQrCubit>().notifiMainQrNoEnoughBalance();
      return;
    }

    context.read<MainQrCubit>().createMainQr(
      amount: balance,
      expiration: DateTime.now().add(
        const Duration(seconds: _refreshDurationInSeconds),
      ),
    );
  }

  void _handleGeneratePress() async {
    final text = _amountController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an amount first.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final double? amount = double.tryParse(text);
    if (amount == null || amount <= 0 ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter a valid amount.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    if(amount > await clsGeneral.balance) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not enough balance.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (!mounted) return;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => GenerateOptionsPopup(amount: amount),
    );

    if (result != null) {
      final duration = result['duration'] as Duration;
      if (!mounted) return;

      context.read<QrCubit>().createQrData(amount, duration);
    }
  }

  void _showQrPopup({
    required double amount,
    required Duration duration,
  }) {
    final qrCubit = parentContext.read<QrCubit>();

    showDialog(
      context: parentContext,
      builder: (context) {
        return QrDisplayPopup(
          qrCubit: qrCubit,
          amount: amount,
          duration: duration,
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QrCubit, QrState>(
      listener: (context, state) {
        if (state is CreatingCustomQr) {
          _showQrPopup(amount: state.amount, duration: state.duration);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Column(
              children: [
                _buildTitle,
                GenerateQrSection(
                  amountController: _amountController,
                  onGenerate: _handleGeneratePress,
                ),
                const SizedBox(height: 40),
                _buildMainQrSectionWithTimer(),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get _buildTitle {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Create QR Code.",
          style: TextStyle(fontSize: FontTheme.titleSize),
        ),
      ],
    );
  }

  Widget _buildMainQrSectionWithTimer() {
    return BlocBuilder<MainQrCubit, MainQrState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildMainQrCases(state),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTimerIndicator(),
                const SizedBox(width: 16),
                BlocBuilder<MainQrCubit, MainQrState>(
                  builder: (context, state) {
                    if (state is MainQrLoaded) {
                      _currentPassKey = state.passKey;
                      return _buildPassKeyHider();
                    } else {
                      _currentPassKey = null;
                      return const SizedBox();
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildQrPart(String qr) {
    return widHider(
      placeholder: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: clsColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            "QR Code Generated",
            style: TextStyle(color: clsColors.primaryText),
          ),
        ),
      ),
      child: QrImageWidget(qrData: qr),
    );
  }

  Widget _buildMainQrCases(MainQrState state) {
    if (state is MainQrLoaded) {
      return _buildQrPart(state.qr);
    }
    if (state is MainQrNoEnoughBalance) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: clsColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            "Not enough balance",
            style: TextStyle(color: clsColors.primaryText),
          ),
        ),
      );
    }
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: clsColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildTimerIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final remainingSeconds =
            (_refreshDurationInSeconds * (1 - _animationController.value))
                .ceil();
        return Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _animationController.value,
                    strokeWidth: 3,
                    backgroundColor: clsColors.secondaryText.withValues(
                      alpha: 0.3,
                    ),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      clsColors.gradientEnd,
                    ),
                  ),
                  Center(
                    child: Text(
                      '$remainingSeconds',
                      style: const TextStyle(
                        color: clsColors.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Auto-refresh',
              style: TextStyle(color: clsColors.secondaryText, fontSize: 16),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPassKeyHider() {
    return HiddenText(currentPassKey: _currentPassKey ?? '');
  }
}
