# Trigger & Compressor Unified Logic

This document details how the waste bin trigger/compressor HTTP logic works following the refactor.

## Overview

Previously, the application had two separate paths to activate the waste bin compressor mechanism on the ESP32:
1. `POST /compress` sending `{"trigger": 1}`
2. `POST /compress` sending an empty body

These paths have now been **merged**. The app has a single, definitive way to trigger the hardware, centralized through the `WasteViewModel`'s `toggleTrigger` method.

## How It Works

### 1. Activating the Trigger
When a user presses the **Trigger System** button on the `DashboardScreen`:

1. The UI calls `viewModel.toggleTrigger(true)`.
2. The viewmodel sets `_isTriggerLoading = true`, which updates the UI to show a "Processing..." state.
3. The viewmodel calls `setTriggerState(true)`, which executes the HTTP request:
   - **Endpoint:** `POST /compress`
   - **Payload:** `{"trigger": 1}`
4. If the request is successful (HTTP 200), the method:
   - Sets `_isTriggerEnabled = true`.
   - Clears the loading state.
   - Refreshes the `wasteStatus` to get the latest bin levels.
   - Specifically starts the **30-second cooldown timer** (`_startCooldown()`).

### 2. The Cooldown Timer
To prevent spamming the ESP32 hardware and causing physical/electrical issues, a cooldown mechanism is strictly enforced.

The `_startCooldown()` method operates via a `Timer.periodic` ticking every 1 second:
- **`_isInCooldown`** gets set to `true`. 
- **`_cooldownRemaining`** starts at `30` and decrements by 1 every second.
- **UI Reflection:** While `_isInCooldown` is true, the `TriggerCard` uses an `AbsorbPointer` widget to completely block taps and greys out the button, displaying **"Cooldown: Xs"**.
- Once `_cooldownRemaining <= 0`, the timer is successfully cancelled and `_isInCooldown` becomes `false`, allowing the user to interact with the button again.

### 3. Deactivating the Trigger
The UI no longer sends a disable request (`{"trigger": 0}`) to the ESP32 network device, as the ESP32 hardware currently isn't listening for disabling commands (the compressor runs its cycle automatically).
- When disabling, the app executes `viewModel.toggleTrigger(false)`.
- This is a purely **local/UI-only state change**; it skips the HTTP request, marking `_isTriggerEnabled = false` immediately.

## File Breakdown

- **`lib/presentation/viewmodels/waste_viewmodel.dart`**: Contains the core logic for the timer, cooldown, loading state, and HTTP invocation.
- **`lib/data/services/api_service.dart`**: Contains `sendTriggerSignal(bool enable)` handling the low-level HTTP client POST logic and retry mechanisms.
- **`lib/presentation/widgets/trigger_card.dart`**: The UI rendering the specific states (`Enabled`, `Disabled`, `Processing...`, `Cooldown: Xs`). 
