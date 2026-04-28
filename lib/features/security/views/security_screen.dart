import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/security/security_score.dart';
import '../../../providers/providers.dart';
import '../widgets/access_logs_viewer.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SECURITY CENTER'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'OVERVIEW', icon: Icon(Icons.dashboard)),
            Tab(text: 'LOGS', icon: Icon(Icons.history)),
            Tab(text: 'SETTINGS', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildLogsTab(), _buildSettingsTab()],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final filesAsync = ref.watch(filesProvider);
    final session = ref.watch(sessionProvider);

    return filesAsync.when(
      data: (files) {
        final totalFiles = files.length;
        final highSecurityFiles = files.where((f) => f.isHighSecurity).length;
        final shamirFiles = files.where((f) => f.isShamirMode).length;

        final securityScore = SecurityScore.calculateScore(
          password: 'dummy_password',
          usesHighSecurity: highSecurityFiles > 0,
          usesShamir: shamirFiles > 0,
          failedAttempts: session.failedAttempts,
          totalFiles: totalFiles,
          highSecurityFiles: highSecurityFiles,
        );

        final suggestions = SecurityScore.getImprovementSuggestions(
          securityScore,
          password: 'dummy_password',
          usesHighSecurity: highSecurityFiles > 0,
          usesShamir: shamirFiles > 0,
          totalFiles: totalFiles,
          highSecurityFiles: highSecurityFiles,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Score Card
              _buildSecurityScoreCard(securityScore),
              const SizedBox(height: 20),

              // Security Metrics
              _buildSecurityMetrics(totalFiles, highSecurityFiles, shamirFiles),
              const SizedBox(height: 20),

              // Improvement Suggestions
              if (suggestions.isNotEmpty) ...[
                _buildImprovementSuggestions(suggestions),
                const SizedBox(height: 20),
              ],

              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error: $error', style: AppTypography.body)),
    );
  }

  Widget _buildLogsTab() {
    return const AccessLogsViewer();
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Settings
          _buildSettingsSection('Security Settings', Icons.security, [
            _buildSettingsTile(
              'Auto-Lock Timeout',
              'Lock app after inactivity',
              '2 minutes',
              Icons.timer,
              onTap: () => _showTimeoutDialog(),
            ),
            _buildSettingsTile(
              'Failed Attempts Limit',
              'Max failed login attempts',
              '3 attempts',
              Icons.block,
              onTap: () => _showAttemptsDialog(),
            ),
            _buildSettingsTile(
              'Biometric Authentication',
              'Use fingerprint/face unlock',
              'Coming Soon',
              Icons.fingerprint,
              enabled: false,
            ),
          ]),
          const SizedBox(height: 24),

          // Data Management
          _buildSettingsSection('Data Management', Icons.storage, [
            _buildSettingsTile(
              'Clear Access Logs',
              'Remove old activity logs',
              'Last 30 days kept',
              Icons.delete_sweep,
              onTap: () => _showClearLogsDialog(),
            ),
            _buildSettingsTile(
              'Export Encrypted Vault',
              'Backup your secure files',
              'Coming Soon',
              Icons.backup,
              enabled: false,
            ),
            _buildSettingsTile(
              'Security Audit',
              'Check for vulnerabilities',
              'Run scan',
              Icons.security_update_good,
              onTap: () => _runSecurityAudit(),
            ),
          ]),
          const SizedBox(height: 24),

          // Advanced Features
          _buildSettingsSection('Advanced Features', Icons.tune, [
            _buildSettingsTile(
              'Screenshot Protection',
              'Block screenshots in app',
              'Coming Soon',
              Icons.screenshot_monitor,
              enabled: false,
            ),
            _buildSettingsTile(
              'Intrusion Detection',
              'Monitor suspicious activity',
              'Active',
              Icons.warning,
              trailing: const Switch(
                value: true,
                onChanged: null, // Coming soon
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSecurityScoreCard(int score) {
    final level = SecurityScore.getSecurityLevel(score);
    final color = Color(
      int.parse('0xFF${SecurityScore.getSecurityColor(score).substring(1)}'),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.security, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Security Score', style: AppTypography.h2),
                    Text(
                      'Overall security assessment',
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$score/100',
                    style: AppTypography.h1.copyWith(color: color),
                  ),
                  Text(
                    level,
                    style: AppTypography.labelCaps.copyWith(color: color),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppColors.bg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityMetrics(int total, int highSecurity, int shamir) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Files',
            total.toString(),
            Icons.folder,
            AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'High Security',
            highSecurity.toString(),
            Icons.shield,
            AppColors.neon,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'SSS Protected',
            shamir.toString(),
            Icons.key,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.h2.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.metadata.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementSuggestions(List<String> suggestions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'SECURITY RECOMMENDATIONS',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions
              .map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '•',
                        style: TextStyle(color: AppColors.warning),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(suggestion, style: AppTypography.metadata),
                      ),
                    ],
                  ),
                ),
              )
              ,
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUICK ACTIONS', style: AppTypography.labelCaps),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Upload File',
                Icons.upload,
                AppColors.neon,
                () => context.push('/upload'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Lock App',
                Icons.lock,
                AppColors.error,
                () {
                  ref.read(sessionProvider.notifier).lock();
                  context.go('/unlock');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.metadata.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.neon, size: 20),
            const SizedBox(width: 8),
            Text(title, style: AppTypography.labelCaps),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    String value,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? AppColors.neon : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      subtitle: Text(subtitle, style: AppTypography.metadata),
      trailing:
          trailing ??
          Text(
            value,
            style: AppTypography.metadata.copyWith(
              color: enabled ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );
  }

  void _showTimeoutDialog() {
    // TODO: Implement timeout settings dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timeout settings coming soon')),
    );
  }

  void _showAttemptsDialog() {
    // TODO: Implement attempts limit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attempts limit settings coming soon')),
    );
  }

  void _showClearLogsDialog() {
    // TODO: Implement clear logs dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clear logs feature coming soon')),
    );
  }

  void _runSecurityAudit() {
    // TODO: Implement security audit
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Security audit coming soon')));
  }
}
