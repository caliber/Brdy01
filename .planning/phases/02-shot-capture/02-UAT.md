---
status: complete
phase: 02-shot-capture
source: 02-01-SUMMARY.md, 02-02-SUMMARY.md, 02-03-SUMMARY.md
started: 2026-05-17T00:00:00Z
updated: 2026-05-17T00:00:00Z
---

## Current Test

[testing complete]

## Tests

### 1. Record a hole outcome
expected: Load a round. Tap PAR on HOLE 01. App immediately advances to HOLE 02 and toast appears ("PAR — HOLE 1") with UNDO. Score badge stays "E".
result: pass

### 2. Undo last score
expected: On HOLE 02 tap BOGEY. Toast appears. Tap UNDO within 4 seconds. App returns to HOLE 02 with no recorded outcome. Score badge reverts.
result: pass

### 3. EAGLE via double-tap
expected: On HOLE 03 double-tap the BIRDIE button. BIRDIE button turns gold with "EAGLE" label. Score badge drops by 2. Advance to HOLE 04, single-tap BIRDIE — button shows orange (birdie), not gold.
result: pass

### 4. Running score stays visible across holes
expected: Score several holes (birdie, par, bogey). After each tap the score badge updates: birdie -1, par no change, bogey +1. Badge is always visible — never hidden or requires tapping to reveal.
result: pass

### 5. Putts counter persists
expected: On any hole tap ADD putts three times. The putts count shows 3. Kill the app. Relaunch — navigate to that hole and confirm putts still shows 3.
result: pass

### 6. Fairway toggle absent on par 3
expected: Navigate to a par 4 or 5 hole — FAIRWAY toggle is present in the bottom strip. Navigate to a par 3 — FAIRWAY toggle is completely absent (not greyed out, not hidden, just gone). GIR and VOICE expand to fill the space.
result: pass

### 7. GIR toggle
expected: Tap the GIR toggle — it activates (dark fill, changed label). Tap again — it deactivates. Each tap immediately writes to Drift (kill/relaunch on that hole shows the same state).
result: pass

### 8. Hole nav strip
expected: Tap the giant hole number. A strip of 18 chips slides down showing scored holes coloured by outcome. Tap a chip for a previously-scored hole — screen shows that hole. Tap the NOW chip — screen returns to the current live hole.
result: pass

### 9. Correct a scored hole
expected: Score hole 1. Open nav strip, tap hole 1 chip. Tap a different outcome. Score badge updates. Navigate back to live hole (NOW chip). Confirm the correction is saved (visible in nav strip chip colour).
result: pass

### 10. Round completion
expected: Score all 18 holes. After recording the outcome on HOLE 18 the app automatically navigates to the Round Review screen.
result: pass

### 11. New round starts on hole 1
expected: From Round Review, start a new round. Shot Capture opens on HOLE 01 — not HOLE 18.
result: pass

## Summary

total: 11
passed: 11
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

[none yet]
