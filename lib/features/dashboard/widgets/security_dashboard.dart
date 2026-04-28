import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/security/security_score.dart';
import '../../../providers/providers.dart';

class SecurityDashboard extends ConsumerWidget {
  const SecurityDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(filesProvider);
    final session = ref.watch(sessionProvider);

    return filesAsync.when(
      data: (files) {
        // Calculate security metrics
        final totalFiles = files.length;
        final highSecurityFiles = files.where((f) => f.isHighSecurity).length;
        final shamirFiles = files.where((f) => f.isShamirMode).length;

        // Calculate security score
        final securityScore = SecurityScore.calculateScore(
          password: 'dummy_password', // We don't store actual password
          usesHighSecurity: highSecurityFiles > 0,
          usesShamir: shamirFiles > 0,
          failedAttempts: session.failedAttempts,
          totalFiles: totalFiles,
          highSecurityFiles: highSecurityFiles,
        );

        final securityLevel = SecurityScore.getSecurityLevel(securityScore);
        final securityColor = Color(
          int.parse(
            '0xFF${SecurityScore.getSecurityColor(securityScore).substring(1)}',
          ),
        );

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neon.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neon.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.neon.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: AppColors.neon,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Security Dashboard', style: AppTypography.h2),
                        Text(
                          'Real-time security monitoring',
                          style: AppTypography.metadata.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Security Score
              _buildSecurityScore(securityScore, securityLevel, securityColor),
              const SizedBox(height: 20),

              // Security Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Total Files',
                      totalFiles.toString(),
                      Icons.folder,
                      AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'High Security',
                      highSecurityFiles.toString(),
                      Icons.shield,
                      AppColors.neon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'SSS Protected',
                      shamirFiles.toString(),
                      Icons.key,
                      AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Security Status
              _buildSecurityStatus(session),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error),
        ),
        child: const Row(
          children: [
            Icon(Icons.error, color: AppColors.error),
            SizedBox(width: 12),
            Text('Security dashboard unavailable', style: AppTypography.body),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityScore(int score, String level, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Security Score', style: AppTypography.labelCaps),
              Text(
                level,
                style: AppTypography.labelCaps.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Score Progress Bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: score / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$score/100',
                style: AppTypography.bodyMedium.copyWith(color: color),
              ),
              Text(
                '${(score / 100 * 100).toInt()}%',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.bodyMedium.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.metadata.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatus(dynamic session) {
    final isLocked = session.isLocked;
    final failedAttempts = session.failedAttempts;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocked
            ? AppColors.error.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLocked ? AppColors.error : AppColors.success,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLocked ? Icons.lock : Icons.lock_open,
            color: isLocked ? AppColors.error : AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLocked ? 'LOCKED' : 'ACTIVE SESSION',
                  style: AppTypography.labelCaps.copyWith(
                    color: isLocked ? AppColors.error : AppColors.success,
                  ),
                ),
                Text(
                  failedAttempts > 0
                      ? 'Failed attempts: $failedAttempts'
                      : 'Secure access granted',
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
}
