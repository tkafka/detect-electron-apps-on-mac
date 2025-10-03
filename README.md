# Electron Apps Causing System-Wide Lag on Tahoe

This script detects apps with not yet updated versions of Electron.

See:
- https://github.com/electron/electron/issues/48311#issuecomment-3332181420
- https://mjtsai.com/blog/2025/09/30/electron-apps-causing-system-wide-lag-on-tahoe/

Fixed versions:
- 36.9.2
- 37.6.0
- 38.2.0
- 39.0.0
- and all above 39

Original gist:
https://gist.github.com/tkafka/e3eb63a5ec448e9be6701bfd1f1b1e58

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

## A bit of promo
If you'd appreciate a visual (Tufte-like) hour by hour forecast for iOS/Apple Watch/mac with nice widgets, I made one - check out 🌦️ [Weathergraph](https://apps.apple.com/app/apple-store/id1501958576).

Thanks! Tomas