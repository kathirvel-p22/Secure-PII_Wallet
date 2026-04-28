import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/security/access_logger.dart';
import '../../../providers/providers.dart';

class AccessLogsScreen extends ConsumerStatefulWidget {
  const AccessLogsScreen({super.key});

  @override
  ConsumerState<AccessLogsScreen> createState() => _AccessLogsScreenState();
}

class _AccessLogsScreenState extends ConsumerState<AccessLogsScreen> {
  List<AccessLog> _logs = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    
    try {
      final storage = ref.read(storageProvider);
      final logger = AccessLogger(storage);
      
      List<AccessLog> logs;
      switch (_filter) {
        case 'failed':
          logs = await logger.getFailedAttempts();
          break;
        case 'today':
          final allLogs = await logger.getRecentLogs(limit: 1000);
          final today = DateTime.now();
          logs = allLogs.where((log) => 
            log.timestamp.year == today.year &&
            log.timestamp.month == today.month &&
            log.timestamp.day == today.day
          ).toList();
          break;
        default:
          logs = await logger.getRecentLogs(limit: 100);
      }
      
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load logs: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCESS LOGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip('All', 'all'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip('Today', 'today'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip('Failed', 'failed'),
                ),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.neon),
                    ),
                  )
                : _logs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return _buildLogTile(log);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() => _filter = value);
        _loadLogs();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neon : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.neon : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? Colors.black : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildLogTile(AccessLog log) {
    final isSuccess = log.success;
    final iconColor = isSuccess ? AppColors.success : AppColors.error;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getActionIcon(log.accessType),
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          log.fileName ?? 'System Action',
          style: AppTypography.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${log.displayAction} • ${log.displayTime}',
              style: AppTypography.metadata.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (!isSuccess && log.errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                log.errorMessage!,
                style: AppTypography.metadata.copyWith(
                  color: AppColors.error,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSuccess 
                ? AppColors.success.withOpacity(0.2)
                : AppColors.error.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isSuccess ? 'SUCCESS' : 'FAILED',
            style: AppTypography.labelCaps.copyWith(
              color: iconColor,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.card,
              border: Border.all(color: AppColors.divider, width: 2),
            ),
            child: const Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Access Logs',
            style: AppTypography.h2,
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyMessage(),
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_filter) {
      case 'failed':
        return 'No failed access attempts found';
      case 'today':
        return 'No activity recorded today';
      default:
        return 'No access logs available';
    }
  }

  IconData _getActionIcon(AccessType type) {
    switch (type) {
      case AccessType.view:
        return Icons.visibility;
      case AccessType.download:
        return Icons.download;
      case AccessType.delete:
        return Icons.delete;
      case AccessType.upload:
        return Icons.upload;
      case AccessType.authentication:
        return Icons.login;
    }
  }
}