# Electron Apps Causing System-Wide Lag on Tahoe

This script detects apps with not yet updated versions of Electron.

Gist:
https://gist.github.com/tkafka/e3eb63a5ec448e9be6701bfd1f1b1e58

See:
- https://github.com/electron/electron/issues/48311#issuecomment-3332181420
- [Michael Tsai: Electron Apps Causing System-Wide Lag on Tahoe](https://mjtsai.com/blog/2025/09/30/electron-apps-causing-system-wide-lag-on-tahoe/)
- [Avarayr's tracker of affected and fixed Electron apps](https://avarayr.github.io/shamelectron/)

Fixed versions:
- 36.9.2
- 37.6.0
- 38.2.0
- 39.0.0
- and all above 39

## Temporary workaround:

Run 

```bash
launchctl setenv CHROME_HEADLESS 1
```

on every system start. The CHROME_HEADLESS flag has a side effect of disabling Electron app window shadows, which makes them ugly, but also stops triggering the issue.

## Example output
(as of 1st oct 2025 - it lists all electron apps, but none shows the ✅ checkmark so far)

```
❌ OpenMTP.app: Electron 18.3.15 (Contents/Frameworks/Electron Framework.framework/Versions/A/Electron Framework)
❌ DaVinci Resolve.app: Electron 36.3.2 (Contents/Applications/Electron.app/Contents/Frameworks/Electron Framework.framework/Versions/A/Electron Framework)
❌ Electron.app: Electron 36.3.2 (Contents/Frameworks/Electron Framework.framework/Versions/A/Electron Framework)
❌ Visual Studio Code.app: Electron 37.3.1 (Contents/Frameworks/Electron Framework.framework/Versions/A/Electron Framework)
❌ Cursor.app: Electron 34.5.8 (Contents/Frameworks/Electron Framework.framework/Versions/A/Electron Framework)
❌ Windsurf.app: Electron 34.4.0 (Contents/Frameworks/Electron Framework.framework/Versions/A/Electron Framework)
❌ Claude.app: Electron 36.4.0 (Contents/Frameworks/Electron Framework.framework/Versions/A/Electron Framework)
❌ Signal.app: Electron 38.1.2 (Contents/Frameworks/Electron Framework.framework/Electron Framework)
❌ Figma Beta.app: Electron 37.5.1 (Contents/Frameworks/Electron Framework.framework/Versions/A/Electron Framework)
❌ Beeper Desktop.app: Electron 33.2.0 (Contents/Frameworks/Electron Framework.framework/Versions/A/Electron Framework)
❌ Slack.app: Electron 38.1.2 (Contents/Frameworks/Electron Framework.framework/Versions/A/Electron Framework)
```

EDIT 2025-10-03: Congrats to Signal being first!
```
✅ Signal.app (Electron 38.2.0) - Contents/Frameworks/Electron Framework.framework/Electron Framework
```


## What I also make
🌦️ [Weathergraph](https://apps.apple.com/app/apple-store/id1501958576) is my weather app that shows hourly forecasts as charts instead of lists.
See a week's worth of temperature, precipitation, wind, UV, and pressure in a single visual. 

Built in Swift/SwiftUI for iPhone, Apple Watch, and Mac. Highly customizable if you're into that.

> "I first downloaded the app because I caught sight of the large complication on an Apple Store employee's Apple Watch and asked about it. This is the perfect weather app. All information beautifully presented and easily accessible." - lucenvoyage

Thanks! Tomas

[![Weathergraph](https://weathergraph.app/homepage/weathergraph-web-header-transparent-full-wide@1_5x.png)](https://weathergraph.app)