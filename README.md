# Last One Walking

A Flutter mobile game inspired by long‑distance walking rules. Players start a session, track speed and distance, manage warnings, and try to avoid getting ticketed. Multiplayer “walk” mode is planned.

## Game idea (current rules)
- Maintain a minimum speed (mph).
- Dropping below speed triggers warnings after a grace period.
- Three warnings → ticket (eliminated).
- Staying at speed long enough erases a warning.
- Win condition: last walker standing (group mode); for solo, a distance goal is used for now.

## What’s implemented
- Create Walk screen with presets, custom rules, and solo distance goal.
- Active Walk screen with:
  - Speed and distance display
  - Warnings left (numeric)
  - Grace/erase timers (debug-only for now)
  - Start Walk → 3‑2‑1 countdown overlay
  - “Give up” control with confirmation
- Pinned primary action button with fade when content scrolls under it.
- App icon + native splash generation via `flutter_launcher_icons` and `flutter_native_splash`.

## What’s not implemented yet
- GPS speed tracking + smoothing
- Live warnings logic and timers
- Background tracking
- Game Over / Summary screen
- Group walk mode

## Debug Controls (DevTools service extensions)
Debug-only service extensions are registered in `ActiveWalkScreen`.

### Quick steps
1) Run the app in debug mode:
```
flutter run -d <device>
```
2) In the app, tap **Create Walk** to open the Walk screen.
3) Open DevTools (URL printed by `flutter run`).
4) Go to **VM Tools → Isolates**.
5) In the **Service Extensions** list, click an extension and pass parameters:
   - Use `value` for numeric params.

### Available extensions
All extensions are prefixed with `ext.`:
- `ext.last_one_walking.setSpeed` (value: double)
- `ext.last_one_walking.stop` (no params; sets speed to 0)
- `ext.last_one_walking.setMiles` (value: double; ignored unless started)
- `ext.last_one_walking.setWarningsLeft` (value: int)
- `ext.last_one_walking.setGrace` (value: int seconds)
- `ext.last_one_walking.setErase` (value: int seconds)
- `ext.last_one_walking.setStarted` (value: 0/1)

## Running
- `flutter pub get`
- `flutter run -d <device>`

## Regenerating icons / splash
- Splash:
  ```
  flutter pub run flutter_native_splash:create
  ```
- Icons:
  ```
  flutter pub run flutter_launcher_icons
  ```
Uninstall the app and reinstall to see icon changes on device.
