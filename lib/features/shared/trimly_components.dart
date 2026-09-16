import 'package:flutter/material.dart';
import 'package:trimly/core/enums/currency.dart';
import 'package:trimly/core/enums/decision_status.dart';
import 'package:trimly/core/utils/currency_formatter.dart';
import 'package:trimly/domain/models/subscription.dart';

class TrimlyButton extends StatelessWidget {
  const TrimlyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isPrimary ? theme.colorScheme.primary : Colors.white,
        foregroundColor: isPrimary ? Colors.white : theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class TrimlyCard extends StatelessWidget {
  const TrimlyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 20,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color(0xFFE5ECEE),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12006064),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
  });

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        if (action != null) ...[
          const Spacer(),
          action!,
        ],
      ],
    );
  }
}

class CurrencyAmount extends StatelessWidget {
  const CurrencyAmount({
    super.key,
    required this.amount,
    required this.currency,
    this.style,
  });

  final double amount;
  final Currency currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrencyFormatter.format(amount, currency),
      style: style,
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
  });

  final DecisionStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color, textColor) = switch (status) {
      DecisionStatus.keep => ('KEEP', const Color(0xFF0D7A5F), Colors.white),
      DecisionStatus.review => ('REVIEW', const Color(0xFFFFB300), Colors.black87),
      DecisionStatus.cut => ('CUT', const Color(0xFFB3261E), Colors.white),
      DecisionStatus.notEnoughInfo => (
          'NOT ENOUGH INFO',
          const Color(0xFF90A4AE),
          Colors.white
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontSize: 11,
          color: textColor,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class SubscriptionSummaryCard extends StatelessWidget {
  const SubscriptionSummaryCard({
    super.key,
    required this.subscription,
    this.trailing,
  });

  final Subscription subscription;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TrimlyCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.subscriptions_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.name,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subscription.category,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CurrencyAmount(
                      amount: subscription.price,
                      currency: Currency.values.firstWhere(
                        (currency) => currency.name == subscription.currency,
                        orElse: () => Currency.inr,
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ ${subscription.billingCycle.name}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
