// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class widNumericInput extends StatefulWidget {
  final int length;
  final TextEditingController controller;
  final bool isPassword;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? textColor;

  const widNumericInput({
    super.key,
    this.length = 4,
    required this.controller,
    this.isPassword = false,
    this.activeColor,
    this.inactiveColor,
    this.textColor,
  });

  @override
  State<widNumericInput> createState() => _widNumericInputState();
}

class _widNumericInputState extends State<widNumericInput> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _controllers = List.generate(widget.length, (index) => TextEditingController());
    _isObscured = widget.isPassword;
    widget.controller.addListener(_updateFieldsFromMainController);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    widget.controller.removeListener(_updateFieldsFromMainController);
    super.dispose();
  }

  void _updateFieldsFromMainController() {
    final text = widget.controller.text;
    for (int i = 0; i < widget.length; i++) {
      if (i < text.length) {
        if (_controllers[i].text != text[i]) {
          _controllers[i].text = text[i];
        }
      } else {
        if (_controllers[i].text.isNotEmpty) {
          _controllers[i].clear();
        }
      }
    }
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    _updateMainController();
  }

  void _updateMainController() {
    final newText = _controllers.map((c) => c.text).join();
    if (widget.controller.text != newText) {
      widget.controller.text = newText;
    }
  }

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? Theme.of(context).primaryColor;
    final inactiveColor = widget.inactiveColor ?? Colors.grey.shade700;
    final textColor = widget.textColor ?? Colors.white;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.length, (index) {
            return SizedBox(
              width: 50,
              height: 60,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                obscureText: _isObscured,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: inactiveColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: activeColor, width: 2.5),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) => _onChanged(value, index),
              ),
            );
          }),
        ),
        if (widget.isPassword)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GestureDetector(
              onTap: _toggleObscure,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: inactiveColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isObscured ? "Show Passkey" : "Hide Passkey",
                    style: TextStyle(color: inactiveColor),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}