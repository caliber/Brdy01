# BRDY.01 — Improvement Backlog

## Visual / UX

- [ ] Light mode — fix setup screen hardcoded black background
- [ ] Light mode — fix stats AppBar hardcoded `Colors.black`
- [ ] Light mode — bottom zone gradient doesn't adapt (hardcoded `#E5E0DE → #8E8C8A`)
- [ ] Light mode — BRDY logo is white SVG, invisible on light background
- [ ] Score counter — add a simple fade transition between holes (blur was removed)
- [ ] Scorecard overlay — frosted glass effect instead of solid surface background
- [ ] Theme toggle — persist selection across app restarts (currently resets to dark)

## Functionality

- [ ] Voice — record putts by voice ("two putts", "three putts")
- [ ] Voice — toggle fairway / GIR by voice ("fairway", "green")
- [ ] Handicap — allow editing handicap index mid-round
- [ ] Round History — make swipe-to-delete more discoverable
- [ ] Round History — show course rating and WHS differential in list tile
- [ ] Settings screen — GPS map toggle (map is fully built, just disabled)

## Data & Accuracy

- [ ] WHS — feed calculated differential back to update stored handicap index
- [ ] Stats — add date labels on trend chart x-axis
- [ ] Stats — allow filtering trend chart (last 10 / 20 / all rounds)

## Infrastructure

- [ ] App icon — replace default Flutter icon with BRDY brand icon
- [ ] Onboarding — empty state / welcome screen on first launch
- [ ] Crash reporting — add Firebase Crashlytics or Sentry
- [ ] iOS — paid Apple Developer account ($99/yr) to unlock deployment
- [ ] Wear OS — execute Phase 4 plans (needs Galaxy Watch 4+)
- [ ] Flutter upgrade — move from 3.24.5 to 3.27+ (unlocks fl_chart 0.71+)

## Release

- [ ] Google Play — store listing, screenshots, privacy policy
- [ ] App Store — store listing (requires iOS deployment first)
- [ ] Accessibility — full WCAG AA audit pass
- [ ] Unit/widget tests — scoring flow regression coverage
