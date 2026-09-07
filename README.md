# DishSwipe

A native iPhone app for deciding what to eat by swiping through short dish videos.

## What it does

- Plays five bundled food videos in a looping, full-bleed card
- Swipe right (or tap **Crave**) to save a dish
- Swipe left (or tap **Pass**) to skip it
- Shows swipe-direction feedback, deck progress, and a completion state
- Keeps saved dishes in a **Your cravings** sheet for the current session
- Works offline; no account, API key, backend, or network connection is required
- Includes VoiceOver labels and 44pt-or-larger controls

## Requirements

- Apple Silicon or Intel Mac
- macOS 14 or newer
- **Full Xcode 16 or newer** from the Mac App Store (Command Line Tools alone are not enough)
- iOS 17 simulator runtime
- XcodeGen (`brew install xcodegen`), only needed if you change `project.yml`

## Run in an iPhone Simulator

1. Install and open Xcode once so it can install its components.
2. In Terminal:

   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   cd /Users/khoanguyen/workspace/DishSwipe
   xcodegen generate
   open DishSwipe.xcodeproj
   ```

3. In Xcode, choose the **DishSwipe** scheme and an iPhone simulator (for example, iPhone 16 Pro).
4. Press **⌘R**.

No signing team is required for the simulator.

## Tests

With full Xcode:

```bash
xcodebuild test \
  -project DishSwipe.xcodeproj \
  -scheme DishSwipe \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

The platform-independent swipe engine can also be checked without Xcode:

```bash
swift run DishSwipeCoreChecks
```

## Project layout

```text
App/                         SwiftUI app and bundled videos
Sources/DishSwipeCore/       Testable swipe/deck domain model
Tests/DishSwipeCoreTests/    Swift Testing unit tests
project.yml                  XcodeGen project definition
Package.swift                Swift package for core checks
```

## Media credits

The bundled clips are original six-second pan/zoom renders created for this project from photos hosted by [Unsplash](https://unsplash.com). Source photo IDs:

- `photo-1569718212165-3a8278d5f624`
- `photo-1574071318508-1cdbab80d002`
- `photo-1551504734-5ee1c4a1479b`
- `photo-1544025162-d76694265947`
- `photo-1601050690597-df0568f70950`

## License

MIT
