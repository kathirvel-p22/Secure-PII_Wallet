import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class SSSConfigDialog extends StatefulWidget {
  final Function(int totalShares, int threshold) onConfigured;

  const SSSConfigDialog({
    super.key,
    required this.onConfigured,
  });

  @override
  State<SSSConfigDialog> createState() => _SSSConfigDialogState();
}

class _SSSConfigDialogState extends State<SSSConfigDialog> {
  int _totalShares = 5;
  int _threshold = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Row(
        children: [
          Icon(Icons.settings, color: AppColors.neon),
          SizedBox(width: 8),
          Text('SSS Configuration', style: AppTypography.h2),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure Shamir\'s Secret Sharing parameters for maximum security.',
              style: AppTypography.body,
            ),
            const SizedBox(height: 24),
            
            // Total Shares
            const Text('Total Shares to Generate', style: AppTypography.labelCaps),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shares: $_totalShares', style: AppTypography.bodyMedium),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _totalShares > 3 ? () {
                              setState(() {
                                _totalShares--;
                                if (_threshold > _totalShares) {
                                  _threshold = _totalShares;
                                }
                              });
                            } : null,
                            icon: const Icon(Icons.remove),
                          ),
                          IconButton(
                            onPressed: _totalShares < 10 ? () {
                              setState(() {
                                _totalShares++;
                              });
                            } : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Slider(
                    value: _totalShares.toDouble(),
                    min: 3,
                    max: 10,
                    divisions: 7,
                    activeColor: AppColors.neon,
                    onChanged: (value) {
                      setState(() {
                        _totalShares = value.round();
                        if (_threshold > _totalShares) {
                          _threshold = _totalShares;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Threshold
            const Text('Threshold (Shares needed to unlock)', style: AppTypography.labelCaps),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Threshold: $_threshold', style: AppTypography.bodyMedium),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _threshold > 2 ? () {
                              setState(() {
                                _threshold--;
                              });
                            } : null,
                            icon: const Icon(Icons.remove),
                          ),
                          IconButton(
                            onPressed: _threshold < _totalShares ? () {
                              setState(() {
                                _threshold++;
                              });
                            } : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Slider(
                    value: _threshold.toDouble(),
                    min: 2,
                    max: _totalShares.toDouble(),
                    divisions: _totalShares - 2,
                    activeColor: AppColors.accent,
                    onChanged: (value) {
                      setState(() {
                        _threshold = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Security Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neon),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔐 Security Level: ${_getSecurityLevel()}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.neon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You will receive $_totalShares shares. Any $_threshold shares can unlock your file.',
                    style: AppTypography.metadata,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Redundancy: ${_totalShares - _threshold} shares can be lost safely.',
                    style: AppTypography.metadata.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Examples
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended Configurations:',
                    style: AppTypography.labelCaps,
                  ),
                  const SizedBox(height: 8),
                  _buildRecommendation('Personal Use', '3 of 5', 'Good balance of security and convenience'),
                  _buildRecommendation('Business', '4 of 7', 'Higher security with team redundancy'),
                  _buildRecommendation('Maximum Security', '5 of 9', 'Enterprise-grade protection'),
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
            widget.onConfigured(_totalShares, _threshold);
            Navigator.pop(context);
          },
          child: const Text('CONFIGURE'),
        ),
      ],
    );
  }

  Widget _buildRecommendation(String title, String config, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.neon,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title ($config)',
                  style: AppTypography.metadata.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSecurityLevel() {
    double ratio = _threshold / _totalShares;
    if (ratio <= 0.4) return 'MAXIMUM';
    if (ratio <= 0.6) return 'HIGH';
    if (ratio <= 0.8) return 'MEDIUM';
    return 'BASIC';
  }
}