import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum DurationOption { min5, min15, hour1, day1, custom }

class GenerateOptionsPopup extends StatefulWidget {
  final double? amount;

  const GenerateOptionsPopup({super.key, required this.amount});

  @override
  State<GenerateOptionsPopup> createState() => _GenerateOptionsPopupState();
}

class _GenerateOptionsPopupState extends State<GenerateOptionsPopup> {
  DurationOption _selectedOption = DurationOption.min15;
  double _customDays = 0;
  double _customHours = 0;
  double _customMinutes = 0;
  double _customSeconds = 0;

  void _generate() {
    final duration = _calculateDuration();
    if (duration.inSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a duration greater than zero.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final targetDate = DateTime.now().add(duration);
    Navigator.of(context).pop({'duration': duration, 'targetDate': targetDate});
  }

  Duration _calculateDuration() {
    switch (_selectedOption) {
      case DurationOption.min5:
        return const Duration(minutes: 5);
      case DurationOption.min15:
        return const Duration(minutes: 15);
      case DurationOption.hour1:
        return const Duration(hours: 1);
      case DurationOption.day1:
        return const Duration(days: 1);
      case DurationOption.custom:
        return Duration(
          days: _customDays.toInt(),
          hours: _customHours.toInt(),
          minutes: _customMinutes.toInt(),
          seconds: _customSeconds.toInt(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 8),
                    _buildAmountDisplay(),
                    const SizedBox(height: 24),
                    _buildQuickOptions(),
                    const SizedBox(height: 16),
                    _buildCustomDurationSelector(),
                    const SizedBox(height: 24),
                    _buildGenerateButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Set Expiry Duration',
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Text(
      'Amount: \$${widget.amount?.toStringAsFixed(2) ?? '0.00'}',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.8),
        fontSize: 16,
      ),
    );
  }

  Widget _buildQuickOptions() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: [
        _buildOptionChip(DurationOption.min5, '5 min'),
        _buildOptionChip(DurationOption.min15, '15 min'),
        _buildOptionChip(DurationOption.hour1, '1 hour'),
        _buildOptionChip(DurationOption.day1, '1 day'),
        _buildOptionChip(DurationOption.custom, 'Custom'),
      ],
    );
  }

  Widget _buildOptionChip(DurationOption option, String label) {
    final isSelected = _selectedOption == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedOption = option);
        }
      },
      backgroundColor: Colors.white.withValues(alpha: 0.1),
      selectedColor: Colors.deepPurpleAccent.withValues(alpha: 0.8),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
        fontWeight: FontWeight.w600,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? Colors.deepPurpleAccent
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      pressElevation: 0,
    );
  }

  Widget _buildCustomDurationSelector() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _selectedOption == DurationOption.custom
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSlider(
                  label: 'Days',
                  value: _customDays,
                  max: 30,
                  onChanged: (val) => setState(() => _customDays = val),
                ),
                const SizedBox(height: 8),
                _buildSlider(
                  label: 'Hours',
                  value: _customHours,
                  max: 23,
                  onChanged: (val) => setState(() => _customHours = val),
                ),
                const SizedBox(height: 8),
                _buildSlider(
                  label: 'Minutes',
                  value: _customMinutes,
                  max: 59,
                  onChanged: (val) => setState(() => _customMinutes = val),
                ),
                const SizedBox(height: 8),
                _buildSlider(
                  label: 'Seconds',
                  value: _customSeconds,
                  max: 59,
                  onChanged: (val) => setState(() => _customSeconds = val),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        CupertinoSlider(
          value: value,
          min: 0,
          max: max,
          divisions: max.toInt(),
          onChanged: onChanged,
          activeColor: Colors.deepPurpleAccent,
          thumbColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _generate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: const Text(
          'Generate QR Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}