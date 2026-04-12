# Midterm Polish Tasks: The Glacial Sanctuary

This task list outlines the steps to stabilize Project Lumi's core functionality via an E2E integration test and polish the user interface to align with the "Glacial Sanctuary" design philosophy.

## 1. Stabilize Core: E2E Integration Testing
Establish a "Golden Path" test to ensure the app is functional from first launch to data entry.

- [x] **Create `integration_test/golden_path_test.dart`**:
    - [x] **Onboarding/SignUp**: User creates a new account.
    - [x] **Login**: User logs in with existing credentials.
    - [x] **Dashboard Load**: Verify summary cards and recent activity appear.
    - [x] **Chat Interaction**: Send a message to Lumi and receive a non-echo response.
    - [x] **Receipt Logging**: Use diagnostics or a mock to simulate a receipt extraction and verify it appears in the dashboard.
    - [x] **Logout**: Ensure session is cleared and user returns to login.
- [x] **Fix Functional Blockers**:
    - [x] Ensure `AppwriteService` is properly initialized in all test environments.
    - [x] Fix any `ProviderScope` or `GoRouter` state issues identified by the E2E test.
    - [x] Verify that background model loading does not block the UI or the test execution.

## 2. Design System Foundation (Theming)
Align the base tokens in `lib/core/theme.dart` with `DESIGN.md`.

- [x] **Typography**: 
    - [x] Explicitly set `fontFamily` for Headlines to 'Manrope' and Body to 'Inter'.
    - [x] Set `lineHeight` to `1.6` for all body and label styles.
    - [x] Implement the "High-Low" pairing (extreme scale contrast).
- [ ] **Button Theming**:
    - [x] Implement `LumiPrimaryButton` with a 135-degree linear gradient (`primary` to `primaryContainer`).
    - [ ] Implement `LumiSecondaryButton` with Glassmorphism (40% opacity white + 12px backdrop blur).
- [ ] **The "No-Line" Rule**:
    - [ ] Audit `InputDecorationTheme` to ensure focused borders use the 40% opacity "Ghost Border."
    - [ ] Remove any remaining 1px solid dividers globally.

## 3. Screen-by-Screen Polish
Iterate through every screen to match the Nordic editorial aesthetic.

### 3.1 Login & Sign Up (`lib/features/auth/`)
- [ ] **Layout**: Implement intentional asymmetry and generous negative space.
- [ ] **Mascot**: Add `KitGhost` (5-10% opacity) to the background or header.
- [ ] **Transitions**: Ensure field focus and button taps use "drifting" (ease-out) animations.

### 3.2 Dashboard (`lib/features/dashboard/`)
- [ ] **Metrics Cards**:
    - [ ] Replace standard cards with Glassmorphism containers if floating.
    - [ ] Ensure tonal shifts (`surface` vs `surface-container-low`) provide structure without borders.
- [ ] **Recent Activity**:
    - [ ] Increase vertical spacing between items to 1.5rem–2rem.
    - [ ] Implement alternating backgrounds for list items.

### 3.3 Home / Chat (`lib/features/home/`)
- [ ] **Input Bar**:
    - [ ] Convert the bottom chat bar into a floating "pill" using Glassmorphism.
    - [ ] Ensure it does not span full width (leave "snow" on the sides).
- [ ] **Chat Bubbles**:
    - [ ] Use `surface-container-lowest` for Lumi and `surface-container-high` for User.
    - [ ] Apply `DEFAULT` (16px) roundedness to all corners.

### 3.4 Settings (`lib/features/settings/`)
- [ ] **"The Cabin" Header**:
    - [ ] Match the glassmorphism top bar from the design.
    - [ ] Use the circular gradient profile placeholder.
- [ ] **List Items**:
    - [ ] Remove dividers. Use tonal background cards for grouping.

## 4. UI Components & Polish
- [ ] **`LumiCard`**: Refine glassmorphism parameters (70% opacity, 20px-40px blur).
- [ ] **`AtmosphericBackground`**: Add a faint grain/snow texture (2% opacity) to give a paper-like quality.
- [ ] **`KitGhost`**: Standardize the mascot's presence in empty states.

## 5. Verification
- [ ] Run `make test-integration DEVICE=linux` and ensure the Golden Path passes.
- [ ] Perform a visual audit on an Android device to check for Impeller performance and blur quality.
