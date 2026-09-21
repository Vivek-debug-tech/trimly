import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/features/shared/trimly_components.dart';
import 'package:trimly/services/revenuecat/premium_provider.dart';
import 'package:trimly/services/revenuecat/trimly_offerings.dart';
import 'package:trimly/services/revenuecat/entitlement_state.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoadingOfferings = true;
  TrimlyOfferings? _offerings;
  TrimlyPlan? _selectedPlan = TrimlyPlan.yearly;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final entState = ref.read(premiumProvider);
      if (entState.isPro) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      _fetchOfferings();
      return;
    });
  }

  Future<void> _fetchOfferings() async {
    final offerings = await ref.read(premiumProvider.notifier).getOfferings();
    if (mounted) {
      setState(() {
        _offerings = offerings;
        _isLoadingOfferings = false;
      });
    }
  }

  void _onEntitlementChange(EntitlementState? previous, EntitlementState next) {
    if (next.isPro && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _purchase() async {
    if (_selectedPlan == null || _isPurchasing) return;
    setState(() {
      _isPurchasing = true;
    });

    final status = await ref
        .read(premiumProvider.notifier)
        .purchase(_selectedPlan!);

    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });
      if (status == PurchaseResultStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'An error occurred with your purchase. Please try again.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _restore() async {
    if (_isPurchasing) return;
    setState(() { _isPurchasing = true; });

    final status = await ref.read(premiumProvider.notifier).restore();

    if (mounted) {
      setState(() { _isPurchasing = false; });
      if (status == RestoreResultStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to restore purchases.')),
        );
      }
    }
  }

  void Function() get _purchaseHandler {
    if (_isPurchasing || _selectedPlan == null) return () {};
    return () { _purchase(); };
  }

  void Function() get _restoreHandler {
    if (_isPurchasing) return () {};
    return () { _restore(); };
  }

  Widget _buildPlanCard(TrimlyPackage? pkg, String title, TrimlyPlan planKey) {
    if (pkg == null) return const SizedBox.shrink();

    final isSelected = _selectedPlan == planKey;
    return GestureDetector(
      onTap: () => setState(() { _selectedPlan = planKey; }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? const Color(0xFF006064).withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF006064)
                : const Color(0xFFE4ECEE),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(
              pkg.priceString,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EntitlementState>(premiumProvider, _onEntitlementChange);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CloseButton(color: Color(0xFF607578)),
      ),
      body: SafeArea(
        child: _isLoadingOfferings
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF006064)),
              )
            : _offerings == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Plans unavailable'),
                    const SizedBox(height: 16),
                    TrimlyButton(
                      label: 'Retry',
                      onPressed: () {
                        setState(() {
                          _isLoadingOfferings = true;
                        });
                        _fetchOfferings();
                      },
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 1),
                    Text(
                      'Unlock Trimly Pro',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get full Optimizer recommendations and more.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF607578),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 2),
                    _buildPlanCard(
                      _offerings!.monthly,
                      'Monthly',
                      TrimlyPlan.monthly,
                    ),
                    _buildPlanCard(
                      _offerings!.yearly,
                      'Yearly',
                      TrimlyPlan.yearly,
                    ),
                    _buildPlanCard(
                      _offerings!.lifetime,
                      'Lifetime',
                      TrimlyPlan.lifetime,
                    ),
                    const Spacer(flex: 2),
                    TrimlyButton(
                      label: _isPurchasing ? 'Processing...' : 'Purchase',
                      onPressed: _purchaseHandler,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _restoreHandler,
                      child: const Text(
                        'Restore Purchases',
                        style: TextStyle(color: Color(0xFF90A4AE)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
