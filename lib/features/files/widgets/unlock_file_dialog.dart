import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/providers.dart';
import '../models/file_meta.dart';

class UnlockFileDialog extends ConsumerStatefulWidget {
  final FileMeta file;
  final Function(String password, List<String>? keys) onUnlock;
  final Function(String password, List<String>? keys)? onDownload;

  const UnlockFileDialog({
    super.key,
    required this.file,
    required this.onUnlock,
    this.onDownload,
  });

  @override
  ConsumerState<UnlockFileDialog> createState() => _UnlockFileDialogState();
}

class _UnlockFileDialogState extends ConsumerState<UnlockFileDialog> {
  final _passwordController = TextEditingController();
  final List<TextEditingController> _shareControllers = [];

  bool _obscurePassword = true;
  bool _isUnlocking = false;
  int? _threshold;
  bool _isLoadingThreshold = false;

  @override
  void initState() {
    super.initState();
    if (widget.file.isShamirMode) {
      _loadThreshold();
    } else if (widget.file.isHighSecurity) {
      // Legacy high security mode - always 3 keys
      _threshold = 3;
      _initializeControllers();
    }
  }

  Future<void> _loadThreshold() async {
    setState(() => _isLoadingThreshold = true);
    
    try {
      final keyService = ref.read(keyProvider);
      final threshold = await keyService.getShamirThreshold(widget.file.id);
      
      setState(() {
        _threshold = threshold;
        _isLoadingThreshold = false;
      });
      
      _initializeControllers();
    } catch (e) {
      setState(() {
        _threshold = 3; // Fallback to 3 if we can't get threshold
        _isLoadingThreshold = false;
      });
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    if (_threshold == null) return;
    
    _shareControllers.clear();
    // Create more input fields than the threshold to allow flexibility
    final numFields = (_threshold! + 2).clamp(3, 8); // At least 3, max 8 fields
    for (int i = 0; i < numFields; i++) {
      _shareControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    for (final controller in _shareControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _unlock() async {
    await _performAction('view');
  }

  Future<void> _download() async {
    await _performAction('download');
  }

  Future<void> _performAction(String action) async {
    if (_passwordController.text.isEmpty) {
      _showError('Please enter password');
      return;
    }

    List<String>? keys;
    if (widget.file.isHighSecurity && _threshold != null) {
      // For SSS mode, collect all non-empty shares (user can provide any number >= threshold)
      final nonEmptyShares = _shareControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      
      if (nonEmptyShares.length < _threshold!) {
        _showError(
          widget.file.isShamirMode
              ? 'Please enter at least $_threshold shares (you have ${nonEmptyShares.length})'
              : 'Please enter all $_threshold keys',
        );
        return;
      }
      
      keys = nonEmptyShares;
    }

    setState(() => _isUnlocking = true);

    try {
      if (action == 'download' && widget.onDownload != null) {
        await widget.onDownload!(_passwordController.text, keys);
      } else {
        await widget.onUnlock(_passwordController.text, keys);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isUnlocking = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.file.isHighSecurity ? Icons.security : Icons.lock,
                color: AppColors.neon,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Unlock File', style: AppTypography.h2)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.file.name,
            style: AppTypography.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.file.isHighSecurity
                  ? AppColors.neon.withValues(alpha: 0.2)
                  : AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.file.isShamirMode ? 'HIGH_SSS' : widget.file.mode,
              style: AppTypography.labelCaps.copyWith(
                fontSize: 10,
                color: widget.file.isHighSecurity
                    ? AppColors.neon
                    : AppColors.accent,
              ),
            ),
          ),
        ],
      ),
      content: _isLoadingThreshold
          ? const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.neon),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Password
                  Text('PASSWORD', style: AppTypography.labelCaps),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTypography.secureInput,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    onSubmitted: widget.file.isHighSecurity ? null : (_) => _unlock(),
                  ),

                  // Keys/Shares (High Security)
                  if (widget.file.isHighSecurity && _threshold != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.file.isShamirMode ? 'SHAMIR SHARES' : 'SECURITY KEYS',
                      style: AppTypography.labelCaps,
                    ),
                    const SizedBox(height: 8),
                    if (widget.file.isShamirMode) ...[
                      Text(
                        'Enter any $_threshold or more of your saved shares to unlock this file',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Shares can be entered in any order. You only need $_threshold shares to unlock.',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Copy and paste your shares exactly as shown during upload:',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          'Example: 1-79296670353c4c967e23388e6a3c31d38ee7cd53305730c947e5e0051026de23',
                          style: AppTypography.metadata.copyWith(
                            color: AppColors.neon,
                            fontFamily: 'monospace',
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Dynamic share/key input fields
                    ...List.generate(_shareControllers.length, (index) {
                      final isRequired = index < _threshold!;
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < _shareControllers.length - 1 ? 8 : 0),
                        child: TextField(
                          controller: _shareControllers[index],
                          style: AppTypography.secureInput.copyWith(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: widget.file.isShamirMode 
                                ? 'Share ${index + 1}${isRequired ? ' *' : ' (optional)'}'
                                : 'Key ${index + 1}',
                            hintText: widget.file.isShamirMode
                                ? 'Paste share ${index + 1} here'
                                : 'Enter key ${index + 1}',
                            helperText: widget.file.isShamirMode && !isRequired
                                ? 'Extra shares for redundancy'
                                : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isUnlocking ? null : () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        if (widget.onDownload != null) ...[
          ElevatedButton(
            onPressed: _isUnlocking ? null : _download,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: _isUnlocking
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('DOWNLOAD'),
          ),
          const SizedBox(width: 8),
        ],
        ElevatedButton(
          onPressed: _isUnlocking ? null : _unlock,
          child: _isUnlocking
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : const Text('VIEW'),
        ),
      ],
    );
  }
}