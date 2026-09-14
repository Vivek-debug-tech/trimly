# Trimly - Currency & Internationalization Amendment v1

**STATUS: FROZEN**  
**VERSION: v1**  
**STATUS AFTER UPDATE: FROZEN**

## Mentor Clarification Incorporated

1. `UserSettings.currency` is the single source of truth for the user's active currency.
2. Currency is selected during onboarding and locked after onboarding for the MVP.
3. The UI must use `userSettingsProvider` and the shared `CurrencyFormatter`.

## Scope

Trimly supports one selected currency per user. Currency is a user-level setting, not an independently configurable Subscription field. This amendment changes the currency boundary only; it does not change Decision Engine or Optimizer business logic.

## Currency Model

The future `UserSettings` model owns the active currency. Subscriptions use the user's selected currency. Trimly does not support mixed currencies for one user and does not perform currency conversion.

Supported MVP currencies may include INR, USD, GBP, EUR, JPY, CAD, AUD, and SGD. The final active currency is one user-level value.

## Country Selection

Country selection may provide a local default currency mapping, such as India to INR, United States to USD, United Kingdom to GBP, European countries to EUR, Japan to JPY, Canada to CAD, Australia to AUD, and Singapore to SGD. The mapping is intentionally small and local.

There is no Geo-IP detection, location tracking, full ISO database, exchange-rate service, or external currency API.

## Single-Currency Rule

One user has one active currency. Trimly must never compare monetary values from different currencies. Subscription currency is interpreted through the user's selected currency; this amendment does not authorize changing the existing Subscription schema.

## Decision Engine and Optimizer

The Impact Score remains:

```text
(0.40 x normalized usage) + (0.60 x normalized importance)
```

Currency does not influence Impact Score. The Optimizer continues to use the user's selected currency, REVIEW/CUT candidates, the hard target constraint, impact-first ranking, cancellation count, overshoot, deterministic ID fallback, and existing billing-cycle normalization:

- weekly: `price / 0.25`
- monthly: `price`
- quarterly: `price / 3`
- yearly: `price / 12`

Trial handling remains unchanged: active trials use `postTrialPrice`; trials without it remain visible but are not optimizer savings candidates. No conversion is performed.

## Locale-Aware Display

Future UI must use locale-aware formatting, preferably through the `intl` package when UI implementation begins. Currency symbols, grouping, and decimal conventions must not be manually concatenated. This task does not add `intl` or formatting code.

## Currency State and Formatting Contract

The authoritative flow is:

```text
UserSettings.currency
	-> userSettingsProvider
	-> shared CurrencyFormatter
	-> every monetary UI surface
```

All UI monetary formatting must use the current `UserSettings.currency` through this shared path. UI must not maintain independent currency state, cache a separate symbol, hardcode currency symbols, implement formatting logic, create another currency provider, or pass a permanently cached currency between screens.

Currency is selected during onboarding and becomes locked after onboarding for normal MVP usage. Changing currency after onboarding, currency migration, historical conversion, exchange-rate logic, and a change-currency workflow are out of scope. This prevents values such as `649` from being misleadingly displayed as another currency without conversion.

## User Settings and Savings Mission

The intended future user-level settings contain `country` and `currency`, persisted at user level, potentially using the existing SharedPreferences foundation. Savings Mission targets and Optimizer amounts are expressed in that selected currency with no conversion.

Milestones will use a small deterministic local currency configuration. INR milestone values must not be blindly reused for every currency. Purchasing-power calculations and exchange rates are excluded.

## Approved Non-Changes

This amendment does not implement UserSettings, country or currency pickers, locale formatting, persistence, Subscription schema changes, Decision Engine changes, Optimizer changes, Hive changes, repositories, UI, RevenueCat, notifications, exchange rates, or currency conversion.

## Phase 5 Handoff

Phase 5 UI/UX must include country selection, onboarding currency selection/default, user-level currency, locale-aware amounts, currency-aware Home, Savings Mission, Optimizer, alternatives, renewal/trial displays, and milestone displays. The UI must never imply that Trimly converts currencies.

## Final Status

Currency & Internationalization Amendment v1  
**STATUS: FROZEN**

## Mentor Visual Design Clarification

The Phase 5 visual direction is also frozen as premium minimalism. Glassmorphism is restricted to the Optimizer's Obvious Guess to Trimly Recommendation reveal card. Real 3D, perspective, parallax, tilt, layered 3D interfaces, animated backgrounds, particles, confetti, metallic textures, and effect-heavy presentation are out of scope.

The primary animation is the subtle native Flutter transition from Obvious Guess to Trimly Recommendation to the human-readable reason. Home count-up, analyzing checklist, page/card transitions, Value Check feedback, and Savings Mission interaction are lower priorities and must remain restrained.

The frozen palette is Deep Teal `#006064`, Brushed Steel `#90A4AE` as a flat neutral, and Vibrant Amber Gold `#FFB300`. The design principle is: “Cut visual complexity everywhere except where the product's decision-making becomes visible.”

**STATUS: FROZEN**
