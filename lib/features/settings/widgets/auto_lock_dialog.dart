import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/providers.dart';

class AutoLockDialog extends ConsumerStatefulWidget {
  const AutoLockDialog({super.key});

  @override
  ConsumerState<AutoLockDialog> createState() => _AutoLockDialogState();
}

class _AutoLockDialogState extends ConsumerState<AutoLockDialog> {
  late int _selectedMinutes;

  final List<int> _timerOptions = [1, 2, 3, 5, 10, 15, 30];

  @override
  void initState() {
    super.initState();
    _selectedMinutes = ref.read(autoLockTimerProvider);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Row(
        children: [
          const Icon(Icons.timer, color: AppColors.warning),
          const SizedBox(width: 8),
          Text('Auto-Lock Timer', style: AppTypography.h2),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose how long the app stays unlocked when inactive.',
              style: AppTypography.body,
            ),
            const SizedBox(height: 24),
            
            Text('TIMER OPTIONS', style: AppTypography.labelCaps),
            const SizedBox(height: 16),
            
            ..._timerOptions.map((minutes) => _buildTimerOption(minutes)),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Shorter timers provide better security but may be less convenient.',
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(autoLockTimerProvider.notifier).state = _selectedMinutes;
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Auto-lock timer set to $_selectedMinutes minutes'),
                backgroundColor: AppColors.success,
              ),
            );
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  Widget _buildTimerOption(int minutes) {
    final isSelected = _selectedMinutes == minutes;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMinutes = minutes),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neon.withValues(alpha: 0.2) : AppColors.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.neon : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.neon : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$minutes ${minutes == 1 ? 'minute' : 'minutes'}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected ? AppColors.neon : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  Text(
                    _getTimerDescription(minutes),
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: AppColors.neon,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _getTimerDescription(int minutes) {
    switch (minutes) {
      case 1:
        return 'Maximum security - locks very quickly';
      case 2:
        return 'High security - recommended for sensitive data';
      case 3:
        return 'Good security with reasonable convenience';
      case 5:
        return 'Balanced security and convenience';
      case 10:
        return 'Moderate security for casual use';
      case 15:
        return 'Lower security but more convenient';
      case 30:
        return 'Minimal security - not recommended';
      default:
        return 'Custom timer setting';
    }
  }
}