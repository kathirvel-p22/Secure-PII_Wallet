import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class KeyInputBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const KeyInputBox({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTypography.secureInput,
      textCapitalization: TextCapitalization.characters,
      maxLength: 8,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
        UpperCaseTextFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: '8 characters',
        counterText: '',
        prefixIcon: const Icon(Icons.vpn_key, color: AppColors.neon),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
