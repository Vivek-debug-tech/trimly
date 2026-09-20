# Trimly - Project Engineering Documentation

## Project Overview

Trimly is a Flutter application foundation for subscription review and savings workflows. The architecture is intentionally staged. Domain decisions are kept independent from Flutter UI, Hive persistence, RevenueCat, notifications, and future optimizer work.

## Phase History

- Phase 1 - Flutter project foundation and frozen architecture scaffold
- Phase 2 - Domain data models and Hive persistence foundation
- Phase 3 - Decision Engine scoring and classification
- Phase 4 - Optimizer, baseline, and alternatives
- Currency & Internationalization Amendment v1 - approved and frozen
- Phase 5 UI/UX Specification - frozen handoff
- Phase 5A - UserSettings and currency foundation

## Phase 1 - Flutter Foundation

### Objective

Prepare a compiling Flutter project foundation without implementing product screens, integrations, or business behavior.

### Implemented

- Flutter and Dart project bootstrap named Trimly.
- Riverpod application scope.
- App shell in `lib/app/app.dart`.
- Router placeholder in `lib/app/router.dart`.
- Theme placeholder in `lib/app/theme/app_theme.dart`.
- Frozen architecture directories under `lib/core`, `lib/data`, `lib/domain`, `lib/features`, and `lib/services`.
- Placeholder boundaries for RevenueCat and notifications without integrating either service.
- Hive, Hive Flutter, Shared Preferences, Riverpod, Hive Generator, and Build Runner dependencies.
- Trimly branding in the application shell and platform metadata.

### Intentionally Not Implemented

Home UI, subscription screens, Value Check, Savings Mission, Optimizer, RevenueCat, notifications, Decision Engine logic, AI/ML, backend, authentication, bank integrations, and Gmail integrations.

### Validation

- `flutter pub get`: passed.
- `dart analyze`: passed.
- `flutter test`: passed.
- Chrome launch: passed.
- Windows launch was blocked by the host's missing Visual Studio C++ toolchain.

## Phase 2 - Domain Models and Hive Persistence

### Objective

Implement the frozen subscription data model, strongly typed enums, explicit Hive persistence metadata, and concrete repository CRUD operations.

### Implemented

- `Subscription` model with the specified fields only.
- Strongly typed `UsageFrequency`, `Importance`, `DecisionStatus`, `BillingCycle`, and `SavingsAction` enums.
- Generated Hive adapters with explicit type IDs.
- Shared adapter registration in `lib/data/storage/hive_adapters.dart`.
- Subscription box name in `lib/data/storage/hive_boxes.dart`.
- Concrete `SubscriptionRepository` in `lib/data/repositories/subscription_repository.dart`.
- Persistence-only operations: get all, get by ID, add, update, delete, and clear all.

### Hive IDs and Subscription Field Indices

| Type | Hive type ID |
| --- | ---: |
| UsageFrequency | 0 |
| Importance | 1 |
| DecisionStatus | 2 |
| BillingCycle | 3 |
| SavingsAction | 4 |
| Subscription | 10 |

`Subscription` uses explicit `@HiveField` indices `0` through `14` in the declared field order. Nullable fields are `DateTime? trialEndDate`, `double? postTrialPrice`, `UsageFrequency? usageFrequency`, `Importance? importance`, and `double? impactScore`.

### Tests

The Phase 2 tests use a temporary filesystem Hive directory and real opened boxes. They cover object creation, nullable fields, enum persistence, Subscription round trips, repository CRUD, delete, and clear-all behavior.

### Architectural Decision and Limitation

The concrete Hive repository lives in the data layer. The domain model remains separate from repository persistence operations. Adapter registration is centralized. At the end of Phase 2, registration was verified before box opening in tests; production Hive startup wiring was intentionally deferred.

## PHASE 3 - DECISION ENGINE

### Phase Objective

Implement the single source of truth for Impact Score calculation, KEEP/REVIEW/CUT classification, and NOT ENOUGH INFO handling. The optimizer, UI, RevenueCat, and notifications remain out of scope.

### What Was Implemented

- `DecisionEngineService` in `lib/domain/engines/decision_engine_service.dart`.
- `DecisionEngineResult` containing `impactScore` and `decisionStatus`.
- Pure evaluation from `UsageFrequency` and `Importance`.
- Subscription evaluation that reads only the Subscription's usage and importance fields.
- Fixed normalization helpers.
- Deterministic threshold classification.

### DecisionEngineService Responsibility

`DecisionEngineService` owns the calculation and classification. It does not access Hive, prices, trial prices, dates, RevenueCat, notifications, UI state, or external services. The immutable Subscription model is not mutated; evaluation returns a result for consumers to apply or display later.

### Impact Score Formula

```text
Impact Score = (0.40 x normalized usage) + (0.60 x normalized importance)
```

Cost is not an input to this formula. No price, post-trial price, monthly cost, annual cost, or savings amount is read during scoring.

### Usage Normalization

| UsageFrequency | Normalized value |
| --- | ---: |
| daily | 1.0 |
| severalPerWeek | 0.8 |
| weekly | 0.6 |
| monthly | 0.4 |
| rarely | 0.2 |
| never | 0.0 |

### Importance Normalization

| Importance | Normalized value |
| --- | ---: |
| high | 1.0 |
| medium | 0.5 |
| low | 0.0 |

### Classification Thresholds

| Impact Score | DecisionStatus |
| --- | --- |
| `>= 0.70` | KEEP |
| `>= 0.40` and `< 0.70` | REVIEW |
| `< 0.40` | CUT |

### NOT ENOUGH INFO Behavior

If usage frequency or importance is missing, the service returns `impactScore = null` and `decisionStatus = notEnoughInfo`. It does not substitute a default value.

### Tests Added

`test/domain/engines/decision_engine_service_test.dart` covers:

- All six usage normalization values.
- All three importance normalization values.
- Representative formula combinations: daily/high, never/low, and weekly/medium.
- Values below, at, and above both classification boundaries.
- All three missing-data combinations.
- Independence from `price` and `postTrialPrice`.

### Validation Results

- `flutter pub get`: passed.
- `dart analyze`: passed.
- `flutter test`: passed.
- Focused Decision Engine tests: 11 passed.

### What Was Intentionally Not Implemented

Savings optimizer subset search, candidate selection, overshoot logic, cancellation minimization, tie-breaking, alternatives, Savings Mission, UI, RevenueCat, notifications, and persistence updates were not implemented.

### Architectural Decisions

- The service is deterministic and side-effect free.
- The scoring formula exists in one place only.
- Cost remains outside Impact Score.
- Missing data is represented explicitly as NOT ENOUGH INFO.
- No arbitrary rounding is applied.
- The optimizer remains a later phase and cannot introduce a second scoring implementation.

### Important Engineering Rationale

Keeping the engine independent of Hive and Flutter makes the frozen rules easy to test and prevents storage or presentation concerns from changing classification behavior. Returning a result rather than mutating Subscription also preserves the Phase 2 model's persistence role and keeps decision calculation under one domain service.

### Known Limitations

Production startup does not yet initialize Hive or open the Subscription box. The service currently evaluates and returns results; applying those results to persisted Subscription records belongs to a later integration phase.

## How to explain this phase

Trimly now has one small calculator that decides how much a subscription matters. It converts usage and importance into fixed numbers, combines them using the frozen 40/60 formula, and labels the result KEEP, REVIEW, or CUT. If either answer is missing, it refuses to guess and returns NOT ENOUGH INFO. Prices are deliberately ignored, so the score measures value and importance rather than cost. The calculator has no UI or database dependency, which makes the rules predictable and easy to test.

## PHASE 4 - OPTIMIZER

### What Was Implemented

- Domain-only `OptimizerService` using exhaustive subset search.
- Separate `NaiveBaselineService` representing expensive-first cancellation.
- `MonthlySavingsCalculator` for INR monthly-equivalent savings.
- Immutable `OptimizerPlan`, `OptimizerResult`, `NaiveBaselineResult`, and `OptimizerExplanation` models.
- Alternatives from the same exhaustive search, ranked deterministically.
- Trial savings based on `postTrialPrice`.

### Optimizer Architecture

The optimizer consumes existing `Subscription` values and their `impactScore` and `decisionStatus`. It does not access Flutter, Hive, repositories, RevenueCat, notifications, or the Decision Engine's scoring internals. Impact Score is never recalculated.

### Candidate Filtering

Only `DecisionStatus.review` and `DecisionStatus.cut` subscriptions enter the optimizer search. KEEP, NOT ENOUGH INFO, null-impact, unsupported-currency, invalid-price, and trial-without-`postTrialPrice` subscriptions are excluded. Null impact is not treated as zero.

### Monthly-Equivalent Billing Normalization

The MVP supports INR only. Savings are normalized as follows:

| Billing cycle | Monthly-equivalent savings |
| --- | --- |
| weekly | `price / 0.25` |
| monthly | `price` |
| quarterly | `price / 3` |
| yearly | `price / 12` |

Normal subscriptions use `price`. Trial subscriptions use `postTrialPrice`, then apply the billing-cycle conversion. A trial without `postTrialPrice` is excluded.

### Optimization Algorithm and Ranking

The service evaluates every subset of the eligible candidate pool. A subset is valid only when total monthly savings are greater than or equal to the target. Valid plans are ranked by:

1. Lowest total Impact Score.
2. Fewest cancellations.
3. Lowest savings overshoot.
4. Lexicographically smallest stable subscription ID signature.

Target zero returns an empty valid plan. Negative targets are rejected. Impossible targets return no valid plan. The implementation uses exhaustive search because only REVIEW/CUT items participate; the search has `O(N x 2^N)` time complexity and practical use is intended for a small candidate pool.

### Naive Baseline

`NaiveBaselineService` is intentionally separate from Trimly's optimizer. It uses the entire subscription list, including KEEP items, excludes only subscriptions without a valid savings value, sorts by monthly-equivalent savings descending, and greedily selects until the target is reached. It does not use Impact Score, usage, importance, or decision classification.

### Alternatives and Explanation

Alternatives are other valid subsets from the same exhaustive search. They use the same ranking order, contain no duplicates, and have deterministic ordering. Result models expose selected subscriptions, monthly and annualized savings, target, overshoot, impact, cancellation count, explanations, alternatives, and validity for future presentation work without importing UI types.

### Tests

`test/domain/engines/optimizer_service_test.dart` contains 24 tests covering all billing cycles, trial handling, candidate filtering, null impacts, target constraints, ranking and tie-breaks, naive baseline behavior, alternatives, and deterministic output.

### Files Created or Changed

- `lib/domain/models/optimizer_models.dart`
- `lib/domain/engines/monthly_savings_calculator.dart`
- `lib/domain/engines/optimizer_service.dart`
- `test/domain/engines/optimizer_service_test.dart`
- `Trimly_Project_Documentation.md`
- `Trimly_Project_Documentation.html`
- `Trimly_Project_Documentation.pdf`

### Architectural Decisions and Limitations

The optimizer remains pure domain logic and does not mutate Subscription records. INR-only support and the existing `trialEndDate != null` trial marker are used as specified. There is no exchange-rate conversion, UI, payment flow, RevenueCat, notifications, or Savings Mission implementation. Exhaustive search remains exponential, so the expected candidate pool must stay small.

### Validation

- `flutter pub get`: passed.
- `dart analyze`: passed.
- `flutter test`: passed.
- Focused Phase 4 optimizer tests: 24 passed.

## CURRENCY & INTERNATIONALIZATION AMENDMENT v1

**STATUS: APPROVED**  
**VERSION: v1**  
**STATUS AFTER UPDATE: FROZEN**

### Currency Model

Trimly supports one selected currency per user. Currency is a user-level setting, not an independently configurable Subscription field. This amendment changes the currency boundary only; it does not change Decision Engine or Optimizer business logic.

The future `UserSettings` model owns the active currency. Subscriptions use the user's selected currency. Mixed currencies for one user are invalid. No currency conversion, exchange-rate API, Geo-IP detection, location tracking, or full ISO country database is permitted.

### Country Selection

Country selection may provide a small local default mapping, such as India to INR, United States to USD, United Kingdom to GBP, European countries to EUR, Japan to JPY, Canada to CAD, Australia to AUD, and Singapore to SGD. The user may confirm or change the suggested currency where the UI allows it.

### Preserved Decision Engine and Optimizer Rules

Impact Score remains `(0.40 x normalized usage) + (0.60 x normalized importance)`. Currency does not influence Impact Score. The Optimizer continues to use the selected currency, REVIEW/CUT candidates, the hard target constraint, impact-first ranking, cancellation count, overshoot, deterministic ID fallback, and the existing billing normalization:

- weekly: `price / 0.25`
- monthly: `price`
- quarterly: `price / 3`
- yearly: `price / 12`

Active trials continue to use `postTrialPrice`; trials without it remain visible but are not optimizer savings candidates. No conversion occurs.

### Locale-Aware Display and Savings Mission

Future UI must format amounts with locale-aware tooling, preferably `intl`, rather than manual symbol concatenation. User-level settings will contain country and currency, and Savings Mission targets, Optimizer amounts, alternatives, renewal displays, trial displays, and milestones will use the selected currency. Milestones require a small deterministic local currency configuration and must not reuse INR values blindly across currencies.

### Approved Non-Changes

This documentation amendment does not implement UserSettings, country or currency pickers, locale formatting, persistence, Subscription schema changes, Decision Engine changes, Optimizer changes, Hive changes, repositories, UI, RevenueCat, notifications, exchange rates, or currency conversion.

## PHASE 5 UI/UX SPECIFICATION

**STATUS: FROZEN**

### CURRENCY & INTERNATIONALIZATION

Trimly is globally usable while maintaining one active currency per user.

- Country selection provides a default currency.
- Currency is confirmed or selected at user level and persisted through the future UserSettings boundary.
- Subscription prices use the selected currency.
- Amounts are locale-aware.
- No currency conversion or exchange-rate API exists.
- Currency does not affect Impact Score or Optimizer ranking.
- Savings Mission, Optimizer, alternatives, renewal/trial displays, and milestones show the selected currency.
- The UI must not imply that Trimly converts currencies.

The future flow is: Country Selection -> Default Currency -> User Confirmation or Selection -> UserSettings -> Currency-aware UI. The country lookup is a small local mapping with no Geo-IP, tracking, full ISO database, or external API.

### Currency-Aware Surfaces

Phase 5 must design currency-aware onboarding, Home totals, Savings Mission target/progress, Optimizer target/savings/overshoot/recommendations, alternatives, renewal/trial displays, milestone displays, and the Obvious Guess versus Trimly Recommendation comparison. The product story remains unchanged: the obvious guess favors expensive subscriptions, while Trimly recommends the lowest-impact combination that reaches the target.

### Explicit Non-Goals

This specification does not authorize UserSettings implementation, country/currency picker UI, `intl` integration, currency persistence, Subscription schema changes, exchange-rate APIs, conversion, RevenueCat, notifications, payment flow, or new business logic.

### Documentation Artifacts

- `Currency_Internationalization_Amendment_v1.md`
- `Phase_5_UI_UX_Specification.md`

## PHASE 5A - USER SETTINGS + CURRENCY FOUNDATION

### Objective

Provide the future UI with one authoritative user-level country and currency state, local persistence, deterministic country defaults, and locale-aware display formatting without changing Phase 1-4 business logic.

### Implemented

- Typed `Country` and `Currency` configurations with the approved MVP mapping.
- `UserSettings` containing only `country` and `currency`.
- `UserSettingsRepository` backed by SharedPreferences.
- Deterministic default settings: India and INR when nothing is saved.
- Riverpod `userSettingsProvider` and `UserSettingsController` as the single state source.
- `CurrencyFormatter` using `intl` and locale metadata from the typed Currency values.

### Supported Country Defaults

| Country | Currency | Locale |
| --- | --- | --- |
| India | INR | `en_IN` |
| United States | USD | `en_US` |
| United Kingdom | GBP | `en_GB` |
| European Union | EUR | `de_DE` |
| Japan | JPY | `ja_JP` |
| Canada | CAD | `en_CA` |
| Australia | AUD | `en_AU` |
| Singapore | SGD | `en_SG` |

### Persistence and Formatting

Country and currency enum names are stored using concrete SharedPreferences keys. Missing values use the deterministic India/INR defaults. Formatting delegates to `intl`; it does not convert currencies or alter subscription, Impact Score, billing, or Optimizer calculations. JPY uses zero fractional digits; the other supported currencies use two.

### Subscription Compatibility Decision

The existing Phase 2 `Subscription.currency` field and Hive schema were inspected and left unchanged. UserSettings is now the authoritative active-currency foundation for future UI and user-level behavior. No per-subscription currency feature was added, and no migration was attempted.

### Tests and Validation

`test/features/user_settings_test.dart` contains 12 focused tests covering model creation, country defaults, SharedPreferences persistence and recreation, user-level currency, INR/USD/GBP/EUR/JPY formatting, no conversion, deterministic defaults, and Riverpod state access.

- `flutter pub get`: passed.
- `dart analyze`: passed.
- `flutter test`: passed, including all previous Phase 1-4 tests.

### Files Created or Changed

- `lib/core/enums/country.dart`
- `lib/core/enums/currency.dart`
- `lib/domain/models/user_settings.dart`
- `lib/data/repositories/user_settings_repository.dart`
- `lib/services/user_settings/user_settings_provider.dart`
- `lib/core/utils/currency_formatter.dart`
- `test/features/user_settings_test.dart`
- `pubspec.yaml` and `pubspec.lock` (`intl` dependency)

### Explicit Non-Goals

No UI, UserSettings screen, country picker, currency picker, currency conversion, exchange-rate API, RevenueCat, notifications, milestone logic, Subscription schema change, Decision Engine change, Optimizer change, or Phase 5B work was implemented.

## PHASE 5 SPECIFICATION CLARIFICATION

### Mentor Clarification Incorporated

1. `UserSettings.currency` is the single source of truth for the user's active currency.
2. Currency is selected during onboarding and locked after onboarding for the MVP.
3. UI must use `userSettingsProvider` and the shared `CurrencyFormatter`.

### Currency State and Formatting Contract

The authoritative flow is:

```text
UserSettings.currency
	-> userSettingsProvider
	-> shared CurrencyFormatter
	-> all monetary UI
```

Every monetary surface, including Home, subscription cards, Renewal Radar, Value Check, Savings Mission, Optimizer, Alternatives, milestones, demos, and future screens, must consume the current UserSettings currency through this shared path. UI must not maintain its own currency state, cache an independent symbol, hardcode currency symbols, implement formatting logic, create another currency provider, or pass a permanently cached currency value between screens.

Currency is selected during onboarding and locked after onboarding for normal MVP usage. Currency changes, migration, historical conversion, exchange-rate logic, and a change-currency workflow are out of scope. This prevents a stored numeric value such as `649` from being misleadingly displayed as another currency without conversion.

### Domain and Presentation Boundary

**Domain:** Decision Engine and Optimizer operate on numeric monetary values.  
**Presentation:** `CurrencyFormatter` creates locale-aware display strings using the current `UserSettings.currency`.

There is no conversion between currencies. Currency does not affect Impact Score or Optimizer ranking.

### Explicit Phase 5 Screen Currency Requirements

- **HOME:** total recurring spend, renewal amounts, and savings use the selected currency.
- **VALUE CHECK:** subscription prices use the selected currency; decision explanations remain unchanged.
- **SAVINGS MISSION:** targets use the selected currency, for example `₹1,000/month`, `$50/month`, or `£50/month`, with no conversion.
- **OPTIMIZER:** recommended savings and subscription amounts use the selected currency; decision logic remains unchanged.
- **ALTERNATIVES:** all savings amounts use the selected currency.
- **RENEWAL RADAR:** renewal amounts use the selected currency.
- **TRIALS:** post-trial prices use the selected currency.

### UI Developer Contract

The UI developer must consume `userSettingsProvider`, the existing UserSettings state, and the shared `CurrencyFormatter`. The UI developer must not create another currency state source, hardcode currency symbols, manually format amounts, or modify `DecisionEngineService` or `OptimizerService` for currency symbols. Currency remains a presentation concern.

### Final Documentation Status

Currency & Internationalization Amendment v1  
**STATUS: FROZEN**

Phase 5 UI/UX Specification  
**STATUS: FROZEN**

## PHASE 6A - REVENUECAT FOUNDATION

### Scope

Phase 6A implements only the RevenueCat entitlement foundation. It does not add paywall UI, purchase UI, offerings, feature gating, notifications, backend services, authentication, cloud sync, or Hive persistence for entitlement state.

### Dependency and Configuration

- Added `purchases_flutter: ^10.13.1`.
- The public SDK key is read from the compile-time `REVENUECAT_PUBLIC_API_KEY` environment value.
- No key is committed to the repository. If the key is absent, the service publishes an error state and does not claim Pro access.

### Reactive Architecture

```text
RevenueCat SDK
	-> RevenueCatService
	-> CustomerInfo mapping
	-> premiumProvider
	-> future UI
```

`RevenueCatConstants.proEntitlementId` is the single entitlement identifier: `trimly_pro`. `RevenueCatService` configures the SDK once, retrieves initial CustomerInfo, registers `addCustomerInfoUpdateListener`, maps every update, and exposes transient entitlement state through the existing Riverpod boundary. The listener can be removed through service disposal.

`premiumProvider` is the one application-level Pro state source. It is a reactive `NotifierProvider` backed by `EntitlementState`; no second entitlement provider was added.

### Entitlement and Error State

The application-level state is intentionally small:

- `loading`
- `free`
- `pro`
- `error` with a UI-safe message

Pro is granted only when `CustomerInfo.entitlements.all['trimly_pro']?.isActive == true`. No local boolean, SharedPreferences value, Hive value, UserSettings field, or purchase history is used as the source of truth. Missing configuration or SDK initialization failure remains an error and never grants Pro.

### Initialization Boundary

`main.dart` calls `WidgetsFlutterBinding.ensureInitialized()`, initializes the singleton `RevenueCatService` once, and then starts the existing `ProviderScope` and app. Individual screens do not initialize RevenueCat, and no polling timer was added.

### Tests

`test/services/revenuecat/revenuecat_service_test.dart` contains 9 focused tests covering free mapping, active Pro mapping, inactive Pro mapping, other/empty entitlement behavior at the pure mapping boundary, deterministic repeated transitions, initial loading state, safe error state, and missing configuration handling.

### Files Created or Modified

- `lib/services/revenuecat/revenuecat_config.dart`
- `lib/services/revenuecat/entitlement_state.dart`
- `lib/services/revenuecat/revenuecat_service.dart`
- `lib/services/revenuecat/premium_provider.dart`
- `lib/main.dart`
- `test/services/revenuecat/revenuecat_service_test.dart`
- `pubspec.yaml` and `pubspec.lock`

### Explicit Non-Goals

No purchase flow, paywall, offerings, Customer Center, premium feature gating, UI changes, Hive changes, UserSettings changes, Decision Engine changes, Optimizer changes, currency logic changes, notifications, backend, authentication, or cloud sync were implemented.

## PHASE 5 VISUAL DESIGN SPECIFICATION

**STATUS: FROZEN**

### Mentor Decisions Incorporated

Trimly's dominant visual language is premium minimalism: polished, modern, trustworthy, premium, clean, financially serious, and easy to understand. The decision engine and recommendation experience remain the visual focus.

Glassmorphism is restricted to one location: the Optimizer's Obvious Guess to Trimly Recommendation reveal card. It is not permitted across Home, subscription lists, Value Check, Savings Mission, Renewal Radar, Trials, Profile, Settings, or Alternatives.

Real 3D, perspective transforms, parallax, tilt-on-scroll, layered 3D interfaces, and complex 3D animations are prohibited. Premium depth uses elevation, soft shadows, rounded surfaces, spacing, and subtle depth only.

### Optimizer Reveal Animation

The highest-priority animation is the native Flutter transition:

```text
OBVIOUS GUESS -> REJECTED -> TRIMLY RECOMMENDATION -> WHY
```

The Obvious Guess appears muted or grayscale, transitions away with an elegant fade, strike-through, slide, or combination, and reveals Trimly's recommendation with the primary accent treatment. The human-readable explanation appears directly underneath in the same experience. The interaction must communicate that Trimly considered user value rather than simply selecting the most expensive subscription.

Secondary animation priorities are Home spend count-up, Optimizer analyzing checklist, standard page/card transitions, Value Check selection feedback, and Savings Mission target interaction. All remain restrained. No particles, flashy effects, continuous animated backgrounds, casino-like celebration, or confetti.

### Frozen Palette

| Role | Color |
| --- | --- |
| Deep Teal | `#006064` |
| Brushed Steel | `#90A4AE` |
| Vibrant Amber Gold | `#FFB300` |

Brushed Steel is a flat neutral; metallic textures and artificial brushed-metal effects are prohibited.

### Screen Direction

- **HOME:** Premium minimalism; prioritize Spend, Renewal, Value, Savings, and Action with only subtle count-up motion.
- **VALUE CHECK:** Clean cards and subtle scale/state feedback with human-readable decisions.
- **SAVINGS MISSION:** Responsive but restrained target setting; calm fade, scale, or badge milestone feedback without confetti.
- **OPTIMIZER:** Strongest treatment only for Obvious Guess, transition, Trimly Recommendation, and reason; the rest stays clean.
- **ALTERNATIVES:** Clean comparison/list with the primary recommendation dominant.
- **RENEWAL RADAR:** Minimal timeline/list using hierarchy and spacing.
- **TRIALS:** Minimal warning-oriented status, post-trial price, renewal timing, and action.
- **PROFILE / SETTINGS:** Simple premium-minimal UI without broad glass or 3D effects.

### Performance and Non-Goals

Avoid unnecessary `BackdropFilter`, simultaneous blur layers, expensive continuous animations, complex 3D transforms, unnecessary custom painters, and animated backgrounds. The Optimizer reveal must remain smooth on a normal mid-range Android device.

Do not add heavy glassmorphism, full-screen 3D, parallax, tilt interactions, particle systems, confetti, animated backgrounds, generic Lottie, unnecessary Rive, metallic textures, or new gamification mechanics.

### Final Status

Currency & Internationalization Amendment v1  
**STATUS: FROZEN**

Phase 5 UI/UX Specification  
**STATUS: FROZEN**
