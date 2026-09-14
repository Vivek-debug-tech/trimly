# Trimly - Phase 5 UI/UX Specification

**STATUS: FROZEN**

## Mentor Clarification Incorporated

1. `UserSettings.currency` is the single source of truth.
2. Currency is locked after onboarding for the MVP.
3. UI must use `userSettingsProvider` and the shared `CurrencyFormatter`.

## CURRENCY STATE & FORMATTING CONTRACT

1. `UserSettings` is the single source of truth for the active currency.
2. Currency is selected during onboarding.
3. Currency is locked after onboarding in the MVP.
4. UI reads currency through `userSettingsProvider`.
5. UI uses `CurrencyFormatter` for every monetary display.
6. UI never hardcodes currency symbols.
7. UI never performs currency conversion.
8. `DecisionEngineService` does not know about currency formatting.
9. `OptimizerService` does not know about currency formatting.
10. All screens displaying money use the same formatting path.

The required flow is:

```text
UserSettings.currency
    -> userSettingsProvider
    -> shared CurrencyFormatter
    -> all monetary UI
```

The UI must not maintain independent currency state, cache a separate symbol, create another currency provider, implement formatting logic, or pass a permanently cached currency value between screens. Currency is a presentation concern; the Decision Engine and Optimizer continue operating on numeric values.

## Currency & Internationalization

Trimly is globally usable while maintaining one active currency per user.

- Country selection provides a default currency.
- The user selects or confirms the suggested currency during onboarding.
- The selected currency is locked after onboarding for normal MVP usage.
- Currency is persisted at user level through the future UserSettings boundary.
- Subscription prices use the user's selected currency.
- Amounts are displayed with locale-aware formatting.
- Trimly performs no currency conversion.
- Trimly uses no exchange-rate API.
- Currency does not affect Impact Score.
- Currency does not alter Optimizer ranking.
- Savings Mission displays the selected currency.
- Optimizer displays the selected currency.
- Alternatives display the selected currency.
- Renewal and trial displays use the selected currency.
- Milestones use a deterministic local configuration for the selected currency.

The UI must not manually concatenate currency symbols and amounts. The presentation layer should use locale-aware formatting, preferably with `intl` when implementation begins. The UI must not imply that Trimly converts currencies.

## Country and Currency Flow

```text
Country Selection
    -> Default Currency
    -> User Confirmation or Selection
    -> UserSettings
    -> Currency-aware UI
```

The country-to-currency lookup is a small local mapping. It does not use Geo-IP, location tracking, a full ISO database, external APIs, or exchange rates.

## Currency-Aware Surfaces

Phase 5 must design currency-aware states for:

- Onboarding country and currency selection.
- Home totals and subscription amounts.
- Savings Mission target and progress.
- Optimizer target, savings, overshoot, and recommendations.
- Alternative plans.
- Renewal dates and trial future charges.
- Currency-aware milestone display.
- Obvious Guess versus Trimly Recommendation comparison.

### Screen Requirements

- **HOME:** total recurring spend, renewal amounts, and savings information use the selected currency.
- **VALUE CHECK:** subscription prices use the selected currency; the decision explanation is unchanged.
- **SAVINGS MISSION:** targets use the selected currency, such as `₹1,000/month`, `$50/month`, or `£50/month`, with no conversion.
- **OPTIMIZER:** recommended savings and subscription amounts use the selected currency; decision logic is unchanged.
- **ALTERNATIVES:** all savings amounts use the selected currency.
- **RENEWAL RADAR:** renewal amounts use the selected currency.
- **TRIALS:** post-trial prices use the selected currency.

The primary product story remains unchanged: the obvious guess favors expensive subscriptions, while Trimly recommends the lowest-impact combination that reaches the user's target. Currency is only the monetary unit.

## Domain and Presentation Boundary

**Domain:** Decision Engine and Optimizer operate on numeric monetary values.  
**Presentation:** `CurrencyFormatter` converts those numeric values into locale-aware display strings using the current `UserSettings.currency`.

There is no conversion between currencies. The UI developer must consume `userSettingsProvider`, the existing `UserSettings` state, and the shared `CurrencyFormatter`. The UI developer must not create another currency state source, hardcode symbols, manually format amounts, or modify `DecisionEngineService` or `OptimizerService` for currency symbols.

## Explicit Non-Goals

This specification does not authorize implementation of UserSettings, country picker UI, currency picker UI, `intl` integration, currency persistence, Subscription schema changes, exchange-rate APIs, conversion, RevenueCat, notifications, payment flow, currency-change screens, currency migration, or new business logic.

## Final Status

Phase 5 UI/UX Specification  
**STATUS: FROZEN**

## TRIMLY VISUAL DESIGN SYSTEM

**STATUS: FROZEN**

### Primary Visual Style

Trimly uses premium minimalism. The interface should feel polished, modern, trustworthy, premium, clean, financially serious, and easy to understand. The decision engine and recommendation experience remain the visual focus.

Trimly must not become broadly glassmorphic, heavily 3D, or effect-driven.

### Glassmorphism Restriction

Glassmorphism is permitted only in the Optimizer's Obvious Guess to Trimly Recommendation reveal card. It must not be used broadly across Home, subscription lists, Value Check, Savings Mission, Renewal Radar, Trials, Profile, Settings, or Alternatives. This keeps the single treatment meaningful and avoids unnecessary blur performance cost.

### Depth and 3D Restrictions

Do not use real 3D objects, perspective transforms, parallax, tilt-on-scroll, layered 3D interfaces, or complex 3D animations. Use elevation, soft shadows, rounded surfaces, spacing, and subtle depth only.

### Animation Strategy

Use native Flutter animations wherever possible. Lottie and Rive are not required and may be used only for a readily available bespoke asset with no meaningful implementation or performance risk.

Priority order:

1. Highest: Obvious Guess to Trimly Recommendation transition.
2. Medium: Home spend count-up, Optimizer analyzing checklist, and standard page/card transitions.
3. Low: Value Check selection feedback and Savings Mission target interaction.

Avoid excessive particles, flashy effects, continuous animated backgrounds, casino-like celebrations, and confetti.

### Optimizer Reveal: Primary Visual Signature

The Optimizer must visibly contrast the naive Obvious Guess with Trimly's Recommendation:

1. Display the muted or grayscale Obvious Guess, such as “Cancel Gym - ₹2,999/year”.
2. Transition away using a subtle native fade, strike-through, slide, or combination.
3. Reveal Trimly's recommendation with the primary accent treatment, such as “Keep Gym. Cancel Netflix + Canva.”
4. Reveal the human-readable explanation directly underneath in the same experience.

The sequence should communicate that Trimly considered what the user values instead of simply choosing the most expensive subscription. It must remain elegant rather than flashy.

### Visual Hierarchy

Prioritize:

1. Key financial number.
2. User action or recommendation.
3. Reason for recommendation.
4. Supporting information.
5. Secondary technical details.

Raw Impact Score values must not be prominent. Human-readable explanations are primary.

### Color System

Use the frozen palette:

| Role | Color |
| --- | --- |
| Deep Teal | `#006064` |
| Brushed Steel | `#90A4AE` |
| Vibrant Amber Gold | `#FFB300` |

Brushed Steel is a flat neutral color. Do not create metallic textures, metallic backgrounds, artificial brushed-metal effects, or texture assets.

### Screen-Specific Direction

- **HOME:** Premium minimalism. Prioritize Spend, Renewal, Value, Savings, and Action. Use a subtle spend count-up only where useful; do not overload the dashboard with animated cards.
- **VALUE CHECK:** Clean simple cards with subtle scale feedback and restrained color/state transitions. Keep KEEP/REVIEW/CUT explanations human-readable.
- **SAVINGS MISSION:** Clean target-setting with restrained interaction. Milestones may use calm fade, scale, or badge appearance. No confetti or particle explosions.
- **OPTIMIZER:** Strongest treatment belongs specifically to Obvious Guess, transition, Trimly Recommendation, and reason. The remainder stays clean.
- **ALTERNATIVES:** Clean comparison/list presentation. Keep the primary recommendation visually dominant.
- **RENEWAL RADAR:** Minimal timeline/list using hierarchy and spacing rather than effects.
- **TRIALS:** Minimal warning-oriented presentation focused on trial status, post-trial price, renewal timing, and action.
- **PROFILE / SETTINGS:** Simple premium-minimal UI with no glass-heavy treatment or 3D effects.

### Performance Requirements

Performance takes priority over decoration. Avoid unnecessary `BackdropFilter` usage, multiple simultaneous blur layers, expensive continuous animations, complex 3D transforms, unnecessary custom painters, and animated backgrounds. The Optimizer reveal must remain smooth on a normal mid-range Android device.

### Design Principle

> Cut visual complexity everywhere except where the product's decision-making becomes visible.

Trimly's memorable interaction is:

```text
OBVIOUS GUESS -> REJECTED -> TRIMLY RECOMMENDATION -> WHY
```

### Visual Non-Goals

Do not add heavy glassmorphism, full-screen 3D, parallax systems, tilt interactions, particle systems, confetti celebrations, animated backgrounds, generic Lottie animations, unnecessary Rive animations, metallic textures, or new gamification mechanics.

## Final Visual Specification Status

**STATUS: FROZEN**
