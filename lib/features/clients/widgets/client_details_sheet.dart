import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/models.dart';
import 'model_assignment_dialog.dart';

/// Bottom sheet for displaying client details
class ClientDetailsSheet extends ConsumerStatefulWidget {
  final Client client;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onCreateOrder;

  const ClientDetailsSheet({
    super.key,
    required this.client,
    required this.canEdit,
    required this.onEdit,
    required this.onCreateOrder,
  });

  @override
  ConsumerState<ClientDetailsSheet> createState() => _ClientDetailsSheetState();
}

class _ClientDetailsSheetState extends ConsumerState<ClientDetailsSheet> {
  Client? _clientDetails;
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadClientDetails());
    }
  }

  Future<void> _loadClientDetails() async {
    try {
      final api = ref.read(apiServiceProvider);
      final client = await api.getClient(widget.client.id);
      if (mounted) {
        setState(() {
          _clientDetails = client;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _clientDetails = widget.client;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openModelAssignmentDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ModelAssignmentDialog(
        clientId: widget.client.id,
        assignedModelIds: _clientDetails?.assignedModelIds ?? [],
      ),
    );
    if (result == true) {
      _loadClientDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = _clientDetails ?? widget.client;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with avatar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      (client.name.isNotEmpty ? client.name.substring(0, 1).toUpperCase() : '?'),
                      style: AppTypography.h2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: AppTypography.h3.copyWith(
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.customerSince(_formatDate(context, client.createdAt)),
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Stats
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: context.l10n.ordersCountLabel,
                    value: '${client.ordersCount ?? 0}',
                    icon: Icons.receipt_long_outlined,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: context.borderColor,
                ),
                Expanded(
                  child: _StatItem(
                    label: context.l10n.spent,
                    value: _formatCurrency(client.totalSpent ?? 0),
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assigned Models section
                  _buildAssignedModelsSection(context, client),

                  const SizedBox(height: AppSpacing.lg),

                  // Contact info
                  _buildContactSection(context, client),

                  if (client.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildNotesSection(context, client),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Actions
                  Row(
                    children: [
                      if (widget.canEdit) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onEdit();
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(context.l10n.editAction),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onCreateOrder();
                          },
                          icon: const Icon(Icons.add),
                          label: Text(context.l10n.createOrder),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedModelsSection(BuildContext context, Client client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.checkroom_outlined, size: 18, color: context.textSecondaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.availableModels,
                style: AppTypography.labelLarge.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _openModelAssignmentDialog,
              icon: const Icon(Icons.settings, size: 18),
              label: Text(context.l10n.configure),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (client.assignedModels.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.surfaceVariantColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: context.borderColor,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.checkroom_outlined,
                  size: 32,
                  color: context.textTertiaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.noModelsAssigned,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.clientCanOrderAnyModel,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textTertiaryColor,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.surfaceVariantColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: client.assignedModels.map((model) {
                return Chip(
                  avatar: const Icon(
                    Icons.checkroom,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Text(model.name),
                  labelStyle: AppTypography.labelMedium.copyWith(
                    color: context.textPrimaryColor,
                  ),
                  backgroundColor: context.surfaceColor,
                  side: BorderSide(color: context.borderColor),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context, Client client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.contact_phone_outlined, size: 18, color: context.textSecondaryColor),
            const SizedBox(width: 8),
            Text(
              context.l10n.contacts,
              style: AppTypography.labelLarge.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surfaceVariantColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: [
              if (client.contacts.phone != null)
                _ContactRow(
                  icon: Icons.phone_outlined,
                  label: context.l10n.phone,
                  value: client.contacts.phone!,
                  onTap: () {},
                ),
              if (client.contacts.email != null) ...[
                if (client.contacts.phone != null)
                  const Divider(height: AppSpacing.md),
                _ContactRow(
                  icon: Icons.email_outlined,
                  label: context.l10n.email,
                  value: client.contacts.email!,
                  onTap: () {},
                ),
              ],
              if (client.contacts.telegram != null) ...[
                const Divider(height: AppSpacing.md),
                _ContactRow(
                  icon: Icons.telegram,
                  label: context.l10n.telegram,
                  value: client.contacts.telegram!,
                  onTap: () {},
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, Client client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notes_outlined, size: 18, color: context.textSecondaryColor),
            const SizedBox(width: 8),
            Text(
              context.l10n.notes,
              style: AppTypography.labelLarge.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surfaceVariantColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            client.notes!,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final months = locale == 'ru'
      ? ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
         'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря']
      : ['January', 'February', 'March', 'April', 'May', 'June',
         'July', 'August', 'September', 'October', 'November', 'December'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M сом';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K сом';
    }
    return '${amount.toStringAsFixed(0)} сом';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.h4.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textTertiaryColor,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: context.textTertiaryColor,
          ),
        ],
      ),
    );
  }
}
