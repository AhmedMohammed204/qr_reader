// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:qr_reader/presentation/theme/colors.dart';

class widHider extends StatefulWidget {
  final Widget child;
  final Widget? placeholder;

  const widHider({super.key, required this.child, this.placeholder});

  @override
  State<widHider> createState() => _widHiderState();
}

class _widHiderState extends State<widHider> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isRevealed = !_isRevealed;
        });
      },
      // Use a Stack to layer the placeholder on top of an invisible child
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. The actual child, made invisible.
          // It's always in the tree to define the size of the Stack.
          Opacity(opacity: 0, child: widget.child),

          // 2. The content that animates in and out.
          // We use AnimatedOpacity for a smooth fade effect.
          AnimatedOpacity(
            opacity: _isRevealed ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            // When the child is revealed, show it.
            child: _isRevealed ? widget.child : Container(),
          ),

          AnimatedOpacity(
            opacity: _isRevealed ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            // When the child is hidden, show the placeholder.
            child: _isRevealed
                ? Container()
                : (widget.placeholder ?? _buildDefaultPlaceholder()),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: clsColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: clsColors.secondaryText.withValues(alpha: 0.5),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_off_outlined,
            color: clsColors.secondaryText,
            size: 18,
          ),
          SizedBox(width: 8),
          Text("Show", style: TextStyle(color: clsColors.secondaryText)),
        ],
      ),
    );
  }
}
