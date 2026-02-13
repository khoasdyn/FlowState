# FlowState: project documentation

## What this app does

FlowState is a macOS productivity app built entirely with SwiftUI. It combines a Pomodoro-style focus timer with a website blocker that prevents users from visiting distracting websites while a focus session is active. When the timer is running and the user navigates to a blocked website in their browser, the app automatically redirects the tab to a local "blocked" HTML page bundled inside the app.

The app lives primarily in the macOS menu bar, giving the user quick access to start, pause, and stop focus sessions without switching away from their work. A main window provides a full UI for managing blocked websites and controlling the timer.

## How the website blocking works

### The approach: Apple Events

FlowState uses **Apple Events** to control web browsers. Apple Events are macOS's built-in inter-process communication system that allows one application to send commands to another. AppleScript is the human-readable scripting language built on top of Apple Events, but any macOS app can send them programmatically using `NSAppleScript` from Swift.

The key insight is that major browsers (Safari, Chrome, Brave, Edge, Opera, Arc) expose a **scripting dictionary**, a set of commands they respond to via Apple Events. These commands include reading the URL of any tab and setting it to a new value. This means an external app can ask Chrome "what URL is your active tab showing?" and then tell it "change that tab's URL to this local file instead."

### The blocking flow

The blocking mechanism follows this sequence, repeated on a timer while a focus session is active:

1. The app's timer fires at a regular interval (currently every 1 second, tied to the countdown timer).
2. The app constructs an AppleScript string that asks the browser for the URL of its active tab.
3. The app executes this script using `NSAppleScript`, which sends Apple Events to the browser and receives the URL back.
4. The app compares the returned URL against the user's blocklist using simple substring matching (`currentURL.contains(blockedDomain)`).
5. If a match is found, the app constructs a second AppleScript string that tells the browser to set the active tab's URL to a local HTML file bundled in the app at `Resource/BlockPage.html`.
6. The browser navigates the tab to the block page, effectively replacing the distracting website.

### What the user sees

When the user first launches FlowState and triggers a browser check, macOS shows a system dialog:

> "FlowState wants access to control [Browser Name]. Allowing control will provide access to documents and data in [Browser Name], and to perform actions within that app."

This is the standard macOS **Automation permission** prompt. The user must click "Allow" for the blocking to work with that browser. This permission is granted per-browser and persists across app launches. It can be managed in **System Settings > Privacy & Security > Automation**.

Once granted, the blocking operates silently in the background with no further prompts.

### Why this approach was chosen

This approach requires no special entitlements from Apple, no VPN profiles, no system configuration changes, and no browser extensions. The app uses only standard macOS APIs available to any developer. It is distributed as a normal macOS app and can be submitted to the Mac App Store with the `com.apple.security.automation.apple-events` entitlement declared in the entitlements file.

### Known limitations of this approach

**Polling-based, not event-driven.** There is no callback or notification when a browser navigates. The app must continuously poll tab URLs on a timer, meaning there is always a brief delay where the blocked site loads before the redirect kicks in.

**Only works with scriptable browsers.** Firefox does not expose a scripting dictionary and cannot be controlled via Apple Events. Any browser without a scripting dictionary is unsupported.

**Only checks the active tab of the front window.** Background tabs and other windows are not currently monitored.

**User can revoke permission.** The Automation permission can be disabled at any time in System Settings, which silently breaks the blocking.

**Substring matching can over-match.** Blocking "t.co" would also match URLs containing "t.co" as a substring of longer strings like "select.com" because `contains` checks for substrings anywhere in the URL string, not just the domain.

## Window style

The main window uses `.windowStyle(.hiddenTitleBar)` to remove the standard macOS title bar. This gives the app a cleaner, more minimal appearance similar to Finder or Apple Music, where the traffic light buttons (close, minimize, fullscreen) float directly over the content. To prevent the traffic lights from overlapping UI elements, both `HomeView` and `SettingView` use `.padding(.top, 36)` instead of symmetric vertical padding.

## Visual design

### Focus image

The home screen displays a large 3D illustration in the center that changes based on the timer state. When the timer is running, it shows the **campfire** image. When the app is idle or paused, it shows the **marshmallow** image. The transition between images uses `.transition(.blurReplace)` with an `.easeInOut(duration: 0.4)` animation keyed to `viewModel.appState`, which produces a smooth blur-fade effect when the state changes.

### Block page (BlockPage.html)

The block page is a self-contained HTML file shown in the browser when a blocked site is detected. It uses **Poppins** (loaded from Google Fonts) as the typeface and the **direction-board.png** 3D asset as its illustration. The page randomly selects both a playful heading (from a pool of five, such as "Nope, not today." and "Nice try though.") and an inspirational quote with attribution on each load. All colors in the HTML are matched to the app's gray-warm color asset hex values: `#FAFAF9` for the background (gray-warm-50), `#1C1917` for the heading (gray-warm-900), `#A8A29E` for the author text (gray-warm-400), `#E7E5E4` for the divider (gray-warm-200), and `#57534E` for the quote text (gray-warm-600).

## Color usage rule

All colors in the project must come from the custom color assets defined in `Assets.xcassets/Untitled_ColorStyles`. These asset colors are auto-generated by Xcode as static properties on `Color` and `ShapeStyle`, which means they can be referenced using dot syntax directly without needing to write a manual `Color` extension.

The required syntax is the dot-notation form where the hyphenated asset name is converted to camelCase. For example, the asset named `blue-500` becomes `.blue500`, the asset named `gray-warm-200` becomes `.grayWarm200`, and the asset named `orange-dark-700` becomes `.orangeDark700`. This conversion happens automatically because Xcode strips the hyphens and capitalizes the first letter of each subsequent word when generating the Swift symbol.

When a color is used in a context where the type is already known to be `Color` (such as inside `.foregroundStyle()`, `.background()`, or a property typed as `Color`), use the shorthand dot syntax like `.blue500`. When the type is ambiguous or the color is being assigned in a context where Swift cannot infer the type, use the full form `Color.blue500`.

Do not use SwiftUI system colors like `.blue`, `.red`, `.gray`, `.orange`, `.purple`, `.mint`, or `.yellow`. Do not use the string-based initializer `Color("blue-500")`. Both of these patterns bypass the design system and make the color palette inconsistent across the app.

The `AppConfig.ColorTheme` struct in `AppConfig.swift` defines semantic color aliases (like `primaryText`, `secondaryText`, `secondaryStroke`) that map to specific asset colors. Use these semantic names when referring to standard UI roles, and use the asset colors directly when applying decorative or accent colors.

### Color asset hex reference (gray-warm subset used in the app)

| Asset name | Swift symbol | Hex | Usage |
|---|---|---|---|
| gray-warm-25 | `.grayWarm25` | `#FDFDFC` | Lightest background |
| gray-warm-50 | `.grayWarm50` | `#FAFAF9` | Block page background |
| gray-warm-200 | `.grayWarm200` | `#E7E5E4` | Secondary stroke, pill backgrounds, list item backgrounds |
| gray-warm-300 | `.grayWarm300` | — | Input placeholder text |
| gray-warm-400 | `.grayWarm400` | `#A8A29E` | Secondary text |
| gray-warm-600 | `.grayWarm600` | `#57534E` | Block page quote text |
| gray-warm-700 | `.grayWarm700` | — | Setting button text |
| gray-warm-900 | `.grayWarm900` | `#1C1917` | Primary text |
| gray-warm-950 | `.grayWarm950` | — | Heading text, input border, back button |

## Codebase overview

### Observation system

The project uses the modern **Observation framework** (`@Observable`) exclusively. All view model classes are marked with `@Observable` and do not conform to `ObservableObject`. The view layer uses `@State` to own the root view model, `@Environment(ViewModel.self)` to read it from the environment, and `.environment(viewModel)` to inject it. Plain `var` properties are used when passing `@Observable` objects as parameters to child views, since the Observation framework tracks property access automatically without any wrapper.

The older Combine-based observation system (`ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject`, `.environmentObject()`) is not used anywhere in the project.

### Project structure

```
FlowState/
├── FlowStateApp.swift                  # App entry point, two Scenes (WindowGroup + MenuBarExtra), ContentView
├── AppConfig.swift                     # Static configuration (duration presets, color theme aliases)
├── FlowState.entitlements              # Sandbox entitlements (file access, Apple Events)
├── Info.plist                          # App info (currently empty dict)
├── Assets.xcassets/
│   ├── AppIcon.appiconset/             # App icon at all required sizes
│   ├── Untitled_ColorStyles/           # Full color palette (~200 colorsets)
│   ├── campfire.imageset/              # 3D campfire illustration (shown when timer is running)
│   └── marshmallow.imageset/           # 3D marshmallow illustration (shown when idle or paused)
├── Resource/
│   ├── BlockPage.html                  # HTML page shown in browser when a site is blocked
│   └── direction-board.png             # 3D direction board illustration used in BlockPage.html
├── View/
│   ├── Home/
│   │   ├── HomeView.swift              # Main screen layout (duration picker, focus image, buttons)
│   │   └── HomeView-Components.swift   # Extracted subviews (durationPicker, focusImage, buttons)
│   ├── Setting/
│   │   ├── SettingView.swift           # Blocked websites editor screen layout
│   │   └── SettingView-Components.swift    # URL input field, back button, blocklist display
│   └── MenuBar/
│       ├── MenuBarScene.swift          # MenuBarExtra Scene definition with timer display
│       └── MenuBarItem.swift           # Menu bar dropdown content (session control buttons)
└── View Model/
    ├── ViewModel.swift                 # Central app state coordinator
    ├── BlockedWebsitesViewModel.swift  # Apple Events logic + BlockedItem SwiftData model
    └── TimerViewModel.swift            # Countdown timer logic and state
```

### Key files explained

**`FlowStateApp.swift`** defines the `@main` app struct with two scenes: a `WindowGroup` for the main window and a `MenuBarExtra` (via `MenuBarScene`) for the menu bar. The `WindowGroup` uses `.windowStyle(.hiddenTitleBar)` to remove the title bar and `.windowResizability(.contentSize)` to size the window to its content. The root `ViewModel` is owned here with `@State` and injected into both scenes using `.environment(viewModel)`. Contains `ContentView` which switches between `HomeView` and `SettingView` based on the navigation state. Also subscribes to the timer publisher via `.onReceive` and syncs the SwiftData blocklist to the view model on every tick.

**`ViewModel.swift`** is the central `@Observable` coordinator that owns all child view models (`BlockedWebsitesViewModel`, `TimerViewModel`). Holds the app's navigation state (`AppNavigationView`), the timer state (`TimerState`), and the current blocked websites array. All session control flows through this class: `handleTimer()` for the main toggle, plus `startSession()`, `pauseSession()`, `resumeSession()`, `resetSession()`, `addTime()`, and `subtractTime()` for direct control from the menu bar. The `countTime()` method is called every second from ContentView's `.onReceive` and coordinates both the timer tick and website monitoring. Views never call `TimerViewModel` directly; they always go through `ViewModel`.

**`BlockedWebsitesViewModel.swift`** contains two things: the `BlockedItem` SwiftData model class (a simple URL string with an ID), and the `BlockedWebsitesViewModel` class that executes AppleScript to read Chrome's active tab URL and redirect it if it matches a blocked domain. The `checkChromeURL(list:)` method is the core blocking function. The `redirectToLocalPage()` method constructs and executes the redirect AppleScript.

**`TimerViewModel.swift`** is a self-contained timer that manages only time values with no reference to its parent. Owns `remainingTime` (the displayed countdown value) and `selectedMinutes` (the user's chosen duration). Publishes a 1-second timer via `Timer.publish(every: 1, ...)`. Provides `tick()` to count down one second (stopping at zero), `reset()` to return to the selected duration, `selectDuration(_:)` to change the preset, and `addTime()`/`subtractTime()` for 5-minute adjustments. It does not know about app state, navigation, or website blocking.

**`AppConfig.swift`** is the central place for app-wide constants. Holds `durationPresets` (the array `[5, 10, 15, 25, 45, 60]` shown as duration picker pills), `defaultDuration` (25 minutes), and a `ColorTheme` struct with semantic color references: `primaryText` (grayWarm900), `secondaryText` (grayWarm400), and `secondaryStroke` (grayWarm200).

**`HomeView-Components.swift`** defines extracted computed properties for the home screen: `durationPicker` (horizontal row of minute preset pills that disable during a session), `focusImage` (conditionally renders the campfire or marshmallow image with a `.blurReplace` animated transition based on `appState`), `mainGroupButtons` (groups the timer button, stop/reset button, and settings/blocking-status button), `timerButton` (play/pause toggle with countdown display using `.symbolEffect` transitions on the SF Symbol), `stopButton` (reset button with error color styling), and `settingButton` (navigates to the edit screen, shows "Blocking" or "Stopped" with a shield icon that uses `.symbolEffect(.bounce)` with a periodic delay).

**`SettingView-Components.swift`** defines the URL input field with validation (checks for empty, too short, and duplicate entries), the back navigation button, and the blocked websites list. When the list is empty, it shows a single "Add suggested websites" button that inserts facebook.com, x.com, reddit.com, and tiktok.com as defaults.

**`BlockPage.html`** is the HTML page displayed in the browser when a blocked site is detected. Uses Poppins from Google Fonts. Displays a 3D direction-board illustration, a randomized playful heading, a small divider, and a randomized inspirational quote with author attribution. All colors match the app's gray-warm palette hex values.

### Data flow

```
User taps Start
    → ViewModel.handleTimer()
    → ViewModel.startSession()
        → appState = .running

Every 1 second (timer tick via .onReceive in ContentView):
    → ViewModel.countTime()
        → Guard: only runs if appState == .running
        → ViewModel.monitoring()
            → BlockedWebsitesViewModel.checkChromeURL(list:)
                → NSAppleScript: asks Chrome for active tab URL
                → Compares URL against blockedWebsites array
                → If match: redirectToLocalPage()
                    → NSAppleScript: sets Chrome tab URL to BlockPage.html
        → TimerViewModel.tick()
            → Decrements remainingTime (stops at zero)
        → If remainingTime <= 0: ViewModel.resetSession()

    → ContentView also copies @Query blockedList to ViewModel.blockedWebsites
      (this is how SwiftData items get passed to the view model layer)
```

The ownership flows strictly downward: views call `ViewModel`, `ViewModel` calls `TimerViewModel`. `TimerViewModel` never references its parent.

### Data persistence

**SwiftData** is used for the blocked websites list. `BlockedItem` is a `@Model` class with a single `blockedURL` string property. The model container is attached at the app level in `FlowStateApp` using `.modelContainer(for: BlockedItem.self)`. Views that need to read the list use `@Query var blockedList: [BlockedItem]`, and views that need to add or delete items access `@Environment(\.modelContext)`.

**`@AppStorage`** is used for the `showMenuBarExtra` toggle that controls whether the menu bar item appears.

### Navigation

The app uses a simple enum-based navigation system rather than `NavigationStack`. `ViewModel.appNavigationView` holds the current screen as an `AppNavigationView` enum value (`.home` or `.edit`), and `ContentView` switches between `HomeView` and `SettingView` based on this value.

### Timer states

The timer has three states defined in the `TimerState` enum:

- **`.idle`** — No session active. Timer shows the selected duration. The user can change the duration preset and edit settings.
- **`.running`** — Session active. Timer counts down each second. Website blocking is active. The focus image shows the campfire. The user can pause or finish.
- **`.paused`** — Session paused. Timer holds its current value. Website blocking stops. The focus image shows the marshmallow. The user can resume or finish.

When the timer reaches zero, `ViewModel.countTime()` automatically calls `resetSession()` which returns the app to the `.idle` state and resets the timer to the selected duration.

### Entitlements

The app declares two entitlements in `FlowState.entitlements`:

- `com.apple.security.files.user-selected.read-only` — Allows reading user-selected files (standard for sandboxed apps).
- `com.apple.security.automation.apple-events` — Allows sending Apple Events to other applications. This is the critical entitlement that enables the browser control functionality.

### Dependencies

The project has **zero external dependencies**. It uses only Apple's frameworks: SwiftUI, SwiftData, and Foundation (which includes `NSAppleScript`).

## AppleScript commands reference

These are the specific AppleScript commands the app uses to interact with browsers. Each command is constructed as a Swift string and executed via `NSAppleScript(source:)`.

### Reading the active tab URL (Chrome-based browsers)

```applescript
tell application "Google Chrome"
    set currentTabURL to URL of active tab of window 1
end tell
return currentTabURL
```

For other Chromium browsers, replace `"Google Chrome"` with `"Brave Browser"`, `"Microsoft Edge"`, `"Opera"`, or `"Arc"`.

### Reading the active tab URL (Safari)

```applescript
tell application "Safari"
    set currentTabURL to URL of current tab of front window
end tell
return currentTabURL
```

Note: Safari uses `current tab of front window` while Chrome uses `active tab of window 1`. This is because each browser defines its own scripting dictionary with different terminology.

### Redirecting a tab (Chrome-based)

```applescript
tell application "Google Chrome"
    set URL of active tab of window 1 to "file:///path/to/BlockPage.html"
end tell
```

### Redirecting a tab (Safari)

```applescript
tell application "Safari"
    set URL of current tab of front window to "file:///path/to/BlockPage.html"
end tell
```

### Checking all tabs across all windows (not yet implemented)

```applescript
tell application "Google Chrome"
    repeat with w in windows
        repeat with t in tabs of w
            set tabURL to URL of t
            -- check tabURL against blocklist
            -- if matched: set URL of t to blocked page
        end repeat
    end repeat
end tell
```

## Supported browsers

| Browser | Bundle identifier | Scripting dictionary | Tab URL syntax |
|---|---|---|---|
| Safari | com.apple.Safari | Yes | `URL of current tab of front window` |
| Google Chrome | com.google.Chrome | Yes | `URL of active tab of window 1` |
| Brave | com.brave.Browser | Yes | Same as Chrome |
| Microsoft Edge | com.microsoft.edgemac | Yes | Same as Chrome |
| Opera | com.operasoftware.Opera | Yes | Same as Chrome |
| Arc | company.thebrowser.Browser | Yes | Same as Chrome |
| Firefox | org.mozilla.firefox | No | Not scriptable via Apple Events |

All Chromium-based browsers share the same scripting dictionary structure inherited from Chrome. Safari has its own distinct scripting dictionary.

## Glossary

**Apple Events** — A macOS inter-process communication mechanism that allows one application to send commands to another. It is the low-level system that AppleScript is built on top of.

**AppleScript** — A scripting language for macOS that provides a human-readable syntax for sending Apple Events. In this project, AppleScript strings are constructed in Swift and executed using `NSAppleScript`.

**`NSAppleScript`** — A Foundation class that compiles and executes AppleScript source code at runtime from within a Swift application. Returns results as `NSAppleEventDescriptor` objects.

**Scripting dictionary (sdef)** — An XML file bundled inside an application that defines what Apple Events it responds to. Browsers that include a scripting dictionary can be queried and controlled by external apps. Browsers without one (like Firefox) cannot.

**Automation permission** — A macOS privacy protection that requires the user to explicitly grant one app permission to send Apple Events to another app. Managed in System Settings > Privacy & Security > Automation.

**Polling** — A technique where the app repeatedly checks (polls) the browser's state on a timer, as opposed to event-driven approaches where the browser would notify the app of changes. Polling always introduces a delay between the event (user visiting a blocked site) and the response (redirect).

**SwiftData** — Apple's modern framework for data persistence in Swift apps, used here to store the list of blocked website domains.

**`@Model`** — A SwiftData macro that marks a class as a persistent data model, automatically generating the schema and storage logic.

**`@Observable`** — A Swift macro (from the Observation framework) that enables fine-grained property tracking for SwiftUI views. When a view reads a property from an `@Observable` object, SwiftUI automatically re-renders only when that specific property changes. This is the only observation system used in this project.

**`MenuBarExtra`** — A SwiftUI Scene type that creates a menu bar item with a dropdown panel. Used here to give the user quick access to session controls without opening the main window.

**`.hiddenTitleBar`** — A `WindowStyle` option that removes the standard macOS title bar text and background, leaving only the traffic light buttons floating over the window content.

**`.blurReplace`** — A SwiftUI transition that fades a view out with a blur effect and fades the replacement in. Used for the focus image swap between campfire and marshmallow.
