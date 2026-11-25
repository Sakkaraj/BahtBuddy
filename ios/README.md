# BahtBuddy iOS

This folder is the iPhone build of the same Flutter app that runs on Android.

## On a Mac

```bash
# from the repository root
flutter pub get
bash ios/download_mlkit_bundles.sh
flutter run
```

Or:

```bash
bash tools/mac_ios_run.sh
```

## What is already wired for iPhone

- Camera and photo library (slips and receipts)
- Face ID / Touch ID unlock
- Local notifications for budgets and the daily reminder
- `https` / `http` query schemes so BBC story links can open
- ML Kit Latin OCR resources under `Runner/MLKitBundles`
- Privacy manifest `Runner/PrivacyInfo.xcprivacy`
- Deployment target iOS 15.0

## Signing a physical iPhone

1. Open `Runner.xcworkspace` in Xcode.
2. Select the Runner target → Signing & Capabilities.
3. Choose your Team.
4. Plug in the phone and run from Xcode or `flutter run`.

Windows cannot compile this folder. Use a Mac with Xcode.
