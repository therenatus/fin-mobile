import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.help),
        backgroundColor: context.surfaceColor,
        foregroundColor: context.textPrimaryColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // FAQ Section
          Text(
            context.l10n.faqTitle,
            style: AppTypography.h3.copyWith(
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildFaqSection(context),
          const SizedBox(height: AppSpacing.xl),

          // Contacts Section
          Text(
            context.l10n.contactSupport,
            style: AppTypography.h3.copyWith(
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildContactsSection(context),
          const SizedBox(height: AppSpacing.xl),

          // App Version
          Center(
            child: Text(
              '${context.l10n.appVersion} 1.0.0',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    final faqItems = [
      _FaqItem(context.l10n.faqCreateOrder, context.l10n.faqCreateOrderAnswer),
      _FaqItem(context.l10n.faqAddClient, context.l10n.faqAddClientAnswer),
      _FaqItem(context.l10n.faqManageEmployees, context.l10n.faqManageEmployeesAnswer),
      _FaqItem(context.l10n.faqPayroll, context.l10n.faqPayrollAnswer),
      _FaqItem(context.l10n.faqProduction, context.l10n.faqProductionAnswer),
      _FaqItem(context.l10n.faqNotifications, context.l10n.faqNotificationsAnswer),
      _FaqItem(context.l10n.faqSubscription, context.l10n.faqSubscriptionAnswer),
    ];

    return Card(
      color: context.surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: faqItems.map((item) {
          return ExpansionTile(
            title: Text(
              item.question,
              style: AppTypography.bodyLarge.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            childrenPadding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.answer,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactsSection(BuildContext context) {
    return Card(
      color: context.surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.borderColor),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.phone_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              context.l10n.phoneLabel,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            subtitle: Text(
              '+996 555 123 456',
              style: AppTypography.bodyLarge.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
            onTap: () => _launchUrl('tel:+996555123456'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.email_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              context.l10n.supportEmail,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            subtitle: Text(
              'support@ateliepro.com',
              style: AppTypography.bodyLarge.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
            onTap: () => _launchUrl('mailto:support@ateliepro.com'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.send_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              context.l10n.telegramChannel,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            subtitle: Text(
              '@ateliepro_support',
              style: AppTypography.bodyLarge.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
            onTap: () => _launchUrl('https://t.me/ateliepro_support'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem(this.question, this.answer);
}
