# SportTracker

An iOS app for tracking sport records, built with SwiftUI and [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture).

## About the App

SportTracker lets users create, browse, and manage sport activity records. The app merges data from two sources — a local SwiftData store and a remote Supabase backend — so records are available even when the network is unreachable.

**Records tab**

- Grid of activity tiles showing name, category icon, and duration.
- Filter by sport category (running, cycling, swimming, gym, hiking, other), data source (local / remote), or free-text search.
- Sort by date, name, or duration.
- Tap a tile to view full details (place, description, metadata); delete from the detail screen.
- Add a new record with name, category, duration, place, date, and description.
- An offline banner appears when the remote source is unavaila ble.

**Settings tab**

- Switch appearance between light, dark, and system default.
- View app version and build number.
- Jump to iOS Settings for language configuration (English and Czech are supported).

For a deeper look at the architecture and reasoning behind technical decisions, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Requirements

| Tool | Version |
|------|---------|
| macOS | 15+ (Sequoia) |
| Xcode | 16+ (iOS 18 SDK, Swift 6) |

## Quick Start

The `.xcodeproj` is committed to the repository, so no extra tooling is needed:

```bash
git clone <repo-url> && cd SportTracker
open SportTracker.xcodeproj
```

Xcode will resolve Swift packages automatically on first open.

## Developer Setup (optional)

The project is generated from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen). If you're making changes to the project structure, install the dev tooling and regenerate:

```bash
# Install Homebrew dependencies (XcodeGen, SwiftLint)
brew bundle

# Regenerate the Xcode project after editing project.yml
xcodegen generate
```

A convenience script is also available:

```bash
./scripts/bootstrap.sh
```

This runs `brew bundle`, `xcodegen generate`, and resolves SPM packages in one step.

## Architecture

The project follows a modular architecture with four local Swift packages:

```
SportTracker (App)
├── Core          — Domain models and repository protocols (zero dependencies)
├── Data          — Repository implementations, SwiftData stack, networking
├── Presentation  — Shared UI components, theme, typography, reusable TCA features
└── Features      — Feature modules (SportRecords, Settings) using TCA
```

**Key design decisions:**

- **Unidirectional data flow** via TCA — each screen is a `Reducer` + `View` pair.
- **Dependency injection** — feature modules depend on client protocols, not concrete implementations. Live wiring happens in the app target's composition root (`SportTracker/CompositionRoot/`).
- **Data layer isolation** — the Data package depends only on Core (Domain). Features never import Data directly.
- **iOS 18+ / Swift 6** — leverages strict concurrency and the latest SwiftUI APIs.

## Running Tests

Tests are configured via `SportTracker.xctestplan` with code coverage enabled. The test plan covers the four **package-level** test targets. Run them from Xcode (Cmd+U) or from the command line:

```bash
xcodebuild test \
  -project SportTracker.xcodeproj \
  -scheme SportTracker \
  -testPlan SportTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Test targets in the plan:

- `SportRecordsFeatureTests` — add, detail, list, filter, coordinator
- `SettingsFeatureTests` — settings reducer
- `DataKitTests` — model mapping, repository implementation
- `NetworkingTests` — DTO mapping, date coding, remote data source

`SportTrackerTests` (app-level composition root) is a native xcodeproj test target and is not included in the shared test plan. Run it directly from Xcode by selecting the `SportTrackerTests` target, or via `xcodebuild test -project SportTracker.xcodeproj -scheme SportTracker -only-testing:SportTrackerTests -destination 'platform=iOS Simulator,name=iPhone 16'`.

## Linting

[SwiftLint](https://github.com/realm/SwiftLint) runs automatically in two ways:

1. **Post-compile build phase** on the app target (configured in `project.yml`).
2. **SPM build tool plugin** on every local package (via `SwiftLintPlugins`).

Configuration lives in `.swiftlint.yml` at the repo root.

## Project Generation

The `.xcodeproj` is committed for convenience, but the source of truth is [`project.yml`](project.yml). It is generated using [XcodeGen](https://github.com/yonaskolb/XcodeGen). After pulling changes that modify `project.yml` or package structure, regenerate with:

```bash
xcodegen generate
```
