import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class PinInput extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final bool obscureText;
  final bool enabled;
  final String? errorText;

  const PinInput({
    super.key,
    required this.length,
    required this.onCompleted,
    this.onChanged,
    this.obscureText = true,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<PinInput> createState() => PinInputState();
}

class PinInputState extends State<PinInput> with TickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enabled && _focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // All fields filled, complete PIN
        _focusNodes[index].unfocus();
        final pin = _controllers.map((c) => c.text).join();
        widget.onCompleted(pin);
      }
    }

    // Call onChanged callback
    final currentPin = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(currentPin);
  }

  void _onKeyPressed(String value, int index) {
    if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  void shake() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    if (widget.enabled && _focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  widget.length,
                  (index) => _buildPinField(index),
                ),
              ),
            );
          },
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.errorText!,
            style: AppTypography.metadata.copyWith(
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildPinField(int index) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? AppColors.neon
              : widget.errorText != null
                  ? AppColors.error
                  : AppColors.divider,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        enabled: widget.enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: widget.obscureText,
        style: AppTypography.h2.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          if (value.length <= 1 && RegExp(r'^\d*$').hasMatch(value)) {
            _onChanged(value, index);
          } else if (value.length > 1) {
            // Handle paste
            _handlePaste(value, index);
          }
        },
        onTap: () {
          // Clear field on tap for easier editing
          _controllers[index].clear();
        },
      ),
    );
  }

  void _handlePaste(String pastedText, int startIndex) {
    final digits = pastedText.replaceAll(RegExp(r'[^\d]'), '');
    
    for (int i = 0; i < digits.length && (startIndex + i) < widget.length; i++) {
      _controllers[startIndex + i].text = digits[i];
    }

    // Move focus to appropriate field
    final nextIndex = (startIndex + digits.length).clamp(0, widget.length - 1);
    if (nextIndex < widget.length) {
      _focusNodes[nextIndex].requestFocus();
    }

    // Check if PIN is complete
    final currentPin = _controllers.map((c) => c.text).join();
    if (currentPin.length == widget.length) {
      widget.onCompleted(currentPin);
    }
  }
}