# FlowState: project documentation

## What this app does

FlowState is a macOS productivity app that combines a focus timer with website and app blocking. During a focus session, the app redirects blocked websites to a local HTML page and continuously hides blocked apps. Once a session starts, the user cannot pause, stop, quit, or remove blocked items until the timer reaches zero. The only escape is to force quit the app via Activity Monitor. The app lives in the menu bar for quick access and has a main window for managing settings.

## Session enforcement

FlowState is designed around the principle that once a focus session begins, the user is fully committed. There is no pause button, no stop button, and no way to quit the app through normal means.

### Quit protection

The app uses two mechanisms to prevent quitting during a session:

1. **AppDelegate interception.** A custom `AppDelegate` class implements `applicationShouldTerminate(_:)`. When a session is active, it shows a native `NSAlert` informing the user they cannot quit, with "Minimize" (hides the window to the Dock) and "Cancel" (dismisses the alert) buttons. It always returns `.terminateCancel` during an active session, blocking the quit regardless of which button the user clicks.

2. **Force quit as the only exit.** The only way to terminate the app during an active session is through Activity Monitor or the system Force Quit dialog (Cmd+Option+Esc).

### Block list protection

Delete buttons for both websites and apps are disabled and visually dimmed (30% opacity) during an active session. The Settings view also displays a warning message in red (`.error500`) when a session is active: "Your session is active. You cannot remove any blocked items."

### Timer button behavior

The timer start button is disabled once a session begins. The user selects a duration from the preset pills, presses the start button, and the session runs uninterrupted until the countdown reaches zero.

## How blocking works

Both blocking mechanisms use **Apple Events** via `NSAppleScript`. Apple Events are macOS's inter-process communication system. Major browsers and System Events expose scripting dictionaries that let external apps query and control them.

Both run on a 1-second polling interval tied to the countdown timer, and both require the user to grant **Automation permission** (System Settings > Privacy & Security > Automation) on first use.

### Website blocking

1. Every tick, the app asks the browser for the active tab's URL via AppleScript.
2. It extracts the host using `URL(string:)?.host()`, strips `www.`, and checks for an exact or subdomain match against the blocklist.
3. If matched, it redirects the tab to `Resource/BlockPage.html`.

### App blocking

1. Every tick, the app asks System Events for the frontmost application's name.
2. If it matches a blocked app, the app sets that process's `visible` to `false` via System Events AppleScript, which hides it.
3. Users add apps via a file picker (`.fileImporter`) that filters for `.app` bundles. The app name is extracted from the bundle path and the icon is displayed using `NSWorkspace.shared.icon(forFile:)`.

### Known limitations

- **Polling-based.** There is always a brief delay before blocking kicks in.
- **Firefox unsupported.** No scripting dictionary.
- **Only checks active tab of front window.** Background tabs are not monitored.
- **User can revoke Automation permission** at any time, silently breaking blocking.
- **Subdomain matching is automatic.** Blocking `facebook.com` also blocks `m.facebook.com`.
- **App blocking matches by process name.** The name extracted from the `.app` bundle must match the process name reported by System Events.

## Window style

Uses `.windowStyle(.hiddenTitleBar)` for a clean look. Traffic light buttons float over content. Both `HomeView` and `SettingView` use `.padding(.top, 36)` to avoid overlap.

## Visual design

### Focus image

The campfire image shows when a session is running, marshmallow when idle.

### Hint text

Below the timer and settings buttons, a context-sensitive hint displays:
- **Idle:** "Start the timer to block sites and apps from your block list. You can edit in Settings."
- **Running:** "You cannot quit the app or modify your block list during an active session."

### Block page (BlockPage.html)

Self-contained HTML using Poppins (Google Fonts) and `direction-board.png`. Randomly selects a playful heading and an inspirational quote on each load. Colors match the gray-warm palette.

## Color usage rule

All colors come from `Assets.xcassets/Untitled_ColorStyles`. Asset names convert from hyphenated to camelCase (e.g. `blue-500` becomes `.blue500`). Use dot syntax when type is inferred (`.blue500`), full form (`Color.blue500`) when ambiguous.

Do not use SwiftUI system colors or `Color("string")`. Use `AppConfig.ColorTheme` semantic aliases (`primaryText`, `secondaryText`, `secondaryStroke`) for standard UI roles.

### Color asset hex reference (gray-warm subset)

| Asset name | Swift symbol | Hex | Usage |
|---|---|---|---|
| gray-warm-25 | `.grayWarm25` | `#FDFDFC` | Lightest background |
| gray-warm-50 | `.grayWarm50` | `#FAFAF9` | Block page background |
| gray-warm-200 | `.grayWarm200` | `#E7E5E4` | Secondary stroke, pill/list item backgrounds |
| gray-warm-300 | `.grayWarm300` | — | Input placeholder text |
| gray-warm-400 | `.grayWarm400` | `#A8A29E` | Secondary text |
| gray-warm-600 | `.grayWarm600` | `#57534E` | Block page quote text |
| gray-warm-700 | `.grayWarm700` | — | Setting button text, section labels |
| gray-warm-900 | `.grayWarm900` | `#1C1917` | Primary text |
| gray-warm-950 | `.grayWarm950` | — | Heading text, input border, back button |

## Codebase overview

### Observation system

Uses the **Observation framework** (`@Observable`) exclusively. Views use `@State` to own the root view model and `@Environment(ViewModel.self)` to read it. The older Combine-based system (`ObservableObject`, `@Published`, etc.) is not used.

### Project structure

```
FlowState/
├── FlowStateApp.swift                  # App entry, AppDelegate, WindowGroup + MenuBarExtra, ContentView
├── AppConfig.swift                     # Duration presets, color theme aliases
├── FlowState.entitlements              # Sandbox entitlements (file access, Apple Events)
├── Info.plist
├── Assets.xcassets/
│   ├── AppIcon.appiconset/
│   ├── Untitled_ColorStyles/           # Full color palette (~200 colorsets)
│   ├── campfire.imageset/
│   └── marshmallow.imageset/
├── Resource/
│   ├── BlockPage.html
│   └── direction-board.png
├── Model/
│   ├── BlockedWebsite.swift            # SwiftData model (domain string)
│   └── BlockedApp.swift                # SwiftData model (name + path)
├── Service/
│   ├── WebsiteBlocker.swift            # AppleScript: read browser URL, match, redirect
│   └── AppBlocker.swift                # AppleScript: get frontmost app, hide if blocked
├── View/
│   ├── SharedComponents.swift          # Reusable views and modifiers
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeView-Components.swift
│   │   └── SessionCompleteView.swift   # Post-session congratulation sheet
│   ├── Setting/
│   │   ├── SettingView.swift           # Two-section layout (websites + apps), file importer
│   │   ├── SettingView-Components.swift # URL input, app picker button, both blocklists
│   │   └── AppIconView.swift           # Displays app icon via NSWorkspace
│   └── MenuBar/
│       ├── MenuBarScene.swift
│       └── MenuBarItem.swift
└── View Model/
    ├── ViewModel.swift                 # Central coordinator
    └── TimerViewModel.swift            # Countdown timer logic
```

### Key files

**`FlowStateApp.swift`** — Contains the `AppDelegate` class that intercepts quit attempts via `applicationShouldTerminate(_:)` and shows a blocking `NSAlert` during active sessions. The main `FlowStateApp` struct defines two scenes: `WindowGroup` (hidden title bar, content-sized) and `MenuBarExtra`. It owns the root `ViewModel` with `@State` and passes it to the `AppDelegate` via `.onAppear`. `ContentView` switches between `HomeView` and `SettingView`, subscribes to the timer publisher, and on every tick maps `@Query` results to plain `[String]` arrays before passing them to the view model. This avoids holding SwiftData model objects outside of a valid `ModelContext`, which would cause faulting crashes.

**`ViewModel.swift`** — Central `@Observable` coordinator owning `WebsiteBlocker`, `AppBlocker`, and `TimerViewModel`. Manages navigation (`AppNavigationView`), timer state (`TimerState`), `showSessionComplete` (triggers the congratulation sheet), and two plain-string arrays (`blockedDomains: [String]` and `blockedAppNames: [String]`). Exposes `isSessionActive` computed property used by the AppDelegate and Settings view to enforce restrictions. `startSession()` guards against re-entry when already running to protect `sessionStartDate` from being overwritten. `countTime()` runs every second and calls `monitoring()` which triggers `websiteBlocker.check(against:)` and `appBlocker.check(against:)`. `resetSession()` sets `showSessionComplete = true` only when the session was actively running. Views never call child services directly.

**`WebsiteBlocker.swift`** — `@Observable` service. `check(against:)` accepts `[String]` (domain strings), gets Chrome's active tab URL via AppleScript, extracts the host with `extractHost(from:)`, checks domain/subdomain match with `isHostBlocked(host:blockedDomain:)`, and redirects via `redirectToBlockPage()` if matched.

**`AppBlocker.swift`** — `@Observable` service. `check(against:)` accepts `[String]` (app name strings), gets the frontmost app name via System Events AppleScript (`getFrontmostAppName()`), and hides it via `hide(appNamed:)` if it matches a blocked app.

**`BlockedWebsite.swift`** — SwiftData `@Model` with a single `domain` property (e.g. `"facebook.com"`).

**`BlockedApp.swift`** — SwiftData `@Model` with `name` (e.g. `"Discord"`) and `path` (e.g. `"/Applications/Discord.app"`).

**`TimerViewModel.swift`** — Self-contained timer with `remainingTime`, `selectedMinutes`, 1-second publisher, `tick()`, `reset()`, `selectDuration(_:)`, and `addTime()`/`subtractTime()`. Stores `sessionStartDate` (set once when a session begins) and computes `sessionEndDate` (current time + remaining seconds). Enforces a 120-minute cap via `maxRemainingTime` (7200 seconds). Exposes `canSubtractTime` (false when remaining time is 5 minutes or under) and `canAddTime` (false when adding 5 minutes would exceed the cap). Both `addTime()` and `subtractTime()` guard against their respective conditions. No reference to parent.

**`AppConfig.swift`** — `durationPresets` ([5, 10, 15, 25, 45, 60]), `defaultDuration` (25), and `ColorTheme` semantic aliases.

**`SharedComponents.swift`** — Contains reusable views and modifiers shared across the app. `IconActionButton` is a view that takes an SF Symbol name and action closure, producing a rounded-rect icon button (used by the back button and dismiss button). `DeleteButton` takes an `isDisabled` boolean and action, rendering the multiply.circle.fill icon with session-aware disabling and 30% opacity dimming. `.pageBackground()` is a ViewModifier applying the standard outer padding (horizontal 16, top 36 for hidden title bar clearance, bottom 24), max frame, and white background. `.listItemRow()` is a ViewModifier for the pill-shaped row container used by blocked item lists. `.pillChip()` is a ViewModifier applying vertical 8 / horizontal 12 padding and capsule clip shape, used by duration preset chips and adjust buttons.

**`HomeView.swift`** — Displays the duration picker, focus image, and main button group. Uses `.pageBackground()` for layout. No local state; all state comes from the ViewModel via `@Environment`.

**`HomeView-Components.swift`** — Extension on `HomeView` providing `durationPicker`, `focusImage` (campfire when running, marshmallow when idle), `timerButton` (disabled during sessions), `settingButton`, and context-sensitive hint text. The `durationPicker` property branches by session state: when idle it shows preset duration chips (`idleDurationPicker`) using `.pillChip()`; when running it shows `activeDurationAdjuster`, an HStack with a "-5 min" button, the session time range (fixed start time arrow projected end time using `.dateTime.hour().minute()` format), and a "+5 min" button. Both adjust buttons use `.pillChip()` and disable/dim when their respective limits are reached.

**`SessionCompleteView.swift`** — Sheet presented when a focus session ends naturally. Displays the lantern image, a congratulation heading, a subtitle, and an `IconActionButton` (xmark) to dismiss. Triggered by `ViewModel.showSessionComplete` which is set to `true` in `resetSession()` only when the session was actively running.

**`SettingView.swift`** — Two vertically stacked sections: "Blocked Websites" (text field + list) and "Blocked Apps" (file picker button + list). Uses `.pageBackground()` for layout. Shows a red warning when a session is active. Uses `.fileImporter` with `allowedContentTypes: [.application]` for app selection.

**`SettingView-Components.swift`** — URL input with `cleanDomainInput(_:)` (strips scheme, www, path, lowercases) and `isValidDomain(_:)` (regex validation). Uses `IconActionButton` for the back button, `DeleteButton` for both blocklists, and `.listItemRow()` for row containers. `handleAppSelection(_:)` extracts app name from bundle URL and inserts into SwiftData. Every insert and delete call is followed by `try? modelContext.save()` to ensure changes persist immediately.

**`MenuBarItem.swift`** — Menu bar dropdown with "Show App", "Start Session" (disabled during sessions), "-5 min" and "+5 min" time adjustment buttons (disabled when idle or when their respective limits are reached), "Settings", and "Quit" buttons.

**`MenuBarScene.swift`** — Defines the `MenuBarExtra` scene showing a timer icon and formatted countdown in the menu bar.

**`AppIconView.swift`** — Displays an app's icon using `NSWorkspace.shared.icon(forFile:)` given the app's path.

### Data flow

```
Every 1 second (.onReceive in ContentView):
    → Map @Query results to plain [String] arrays on ViewModel
        → blockedDomains = blockedWebsiteList.map { $0.domain }
        → blockedAppNames = blockedAppList.map { $0.name }
    → ViewModel.countTime()
        → Guard: only runs if appState == .running
        → ViewModel.monitoring()
            → websiteBlocker.check(against: [String])  — extract host, match domain, redirect
            → appBlocker.check(against: [String])      — get frontmost app, hide if blocked
        → TimerViewModel.tick()
        → If remainingTime <= 0: resetSession()
```

### Data persistence

**SwiftData** stores `BlockedWebsite` (domain) and `BlockedApp` (name + path). Model container registered for both in `FlowStateApp`. Views use `@Query` to read and `@Environment(\.modelContext)` to write. All mutations are followed by an explicit `try? modelContext.save()` to guarantee persistence before window closure.

**Important:** SwiftData `@Model` objects must not be stored or accessed outside of a valid `ModelContext`. The ViewModel only holds plain `[String]` arrays extracted from `@Query` results inside the view layer, where the context is guaranteed to be alive. Storing `@Model` objects directly in the ViewModel and accessing their properties later (e.g. from a timer callback) causes faulting crashes because the context may have been deallocated.

**`@AppStorage`** stores the `showMenuBarExtra` toggle.

### Navigation

Enum-based: `ViewModel.appNavigationView` holds `.home` or `.edit`. `ContentView` switches views accordingly.

### Timer states

- **`.idle`** — No session. User can change duration, edit block lists, and quit freely.
- **`.running`** — Counting down. Blocking active. Campfire image shown. Quitting blocked. Block list editing disabled. Timer button disabled.

Timer auto-resets to `.idle` when it reaches zero.

### Entitlements

- `com.apple.security.files.user-selected.read-only` — File access for app picker.
- `com.apple.security.automation.apple-events` — Sending Apple Events to browsers and System Events.

### Dependencies

Zero external dependencies. Uses SwiftUI, SwiftData, Foundation (`NSAppleScript`), UniformTypeIdentifiers, and AppKit (`NSWorkspace`, `NSAlert`, `NSApplication`).

## AppleScript commands reference

### Read active tab URL (Chrome-based)

```applescript
tell application "Google Chrome"
    set currentTabURL to URL of active tab of window 1
end tell
return currentTabURL
```

Replace `"Google Chrome"` with `"Brave Browser"`, `"Microsoft Edge"`, `"Opera"`, or `"Arc"` for other Chromium browsers.

### Read active tab URL (Safari)

```applescript
tell application "Safari"
    set currentTabURL to URL of current tab of front window
end tell
return currentTabURL
```

### Redirect tab (Chrome-based)

```applescript
tell application "Google Chrome"
    set URL of active tab of window 1 to "file:///path/to/BlockPage.html"
end tell
```

### Redirect tab (Safari)

```applescript
tell application "Safari"
    set URL of current tab of front window to "file:///path/to/BlockPage.html"
end tell
```

### Get frontmost application name

```applescript
tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell
return frontApp
```

### Hide an application

```applescript
tell application "System Events"
    set visible of process "AppName" to false
end tell
```

### Check all tabs across all windows (not yet implemented)

```applescript
tell application "Google Chrome"
    repeat with w in windows
        repeat with t in tabs of w
            set tabURL to URL of t
        end repeat
    end repeat
end tell
```

## Supported browsers

| Browser | Bundle identifier | Tab URL syntax |
|---|---|---|
| Safari | com.apple.Safari | `URL of current tab of front window` |
| Google Chrome | com.google.Chrome | `URL of active tab of window 1` |
| Brave | com.brave.Browser | Same as Chrome |
| Microsoft Edge | com.microsoft.edgemac | Same as Chrome |
| Opera | com.operasoftware.Opera | Same as Chrome |
| Arc | company.thebrowser.Browser | Same as Chrome |
| Firefox | org.mozilla.firefox | Not scriptable |

## Glossary

**Apple Events** — macOS inter-process communication system allowing apps to send commands to each other.

**AppleScript** — Human-readable scripting language built on Apple Events. Executed at runtime via `NSAppleScript`.

**`NSAppleScript`** — Foundation class that compiles and executes AppleScript source code from Swift.

**Scripting dictionary (sdef)** — XML file in an app bundle defining what Apple Events it responds to.

**Automation permission** — macOS privacy gate requiring user approval for one app to control another via Apple Events.

**Polling** — Repeatedly checking state on a timer, as opposed to event-driven callbacks.

**SwiftData** — Apple's persistence framework. `@Model` marks persistent classes, `@Query` reads them in views.

**`@Observable`** — Swift macro enabling fine-grained property tracking for SwiftUI. The only observation system used in this project.

**`MenuBarExtra`** — SwiftUI Scene type for menu bar items with dropdown panels.

**`NSApplicationDelegateAdaptor`** — Property wrapper that connects a custom `NSApplicationDelegate` class to a SwiftUI `App`, enabling access to AppKit lifecycle methods like `applicationShouldTerminate(_:)`.

**`NSAlert`** — AppKit class for presenting native macOS alert dialogs with customizable message text, informative text, buttons, and alert styles.
