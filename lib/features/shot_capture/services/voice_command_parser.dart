import '../../../domain/enums/hole_outcome.dart';

/// Result of parsing a voice utterance.
sealed class VoiceCommand {}

class OutcomeCommand extends VoiceCommand {
  final HoleOutcome outcome;
  OutcomeCommand(this.outcome);
}

class ShotsCommand extends VoiceCommand {
  final int shots;
  ShotsCommand(this.shots);
}

class NextHoleCommand extends VoiceCommand {}

class PrevHoleCommand extends VoiceCommand {}

class UndoCommand extends VoiceCommand {}

class SetPuttsCommand extends VoiceCommand {
  final int count;
  SetPuttsCommand(this.count);
}

class FairwayHitCommand extends VoiceCommand {}

class GirCommand extends VoiceCommand {}

class UnrecognisedCommand extends VoiceCommand {
  final String text;
  UnrecognisedCommand(this.text);
}

class VoiceCommandParser {
  /// Parse a voice utterance.
  /// Primary mode: say the number of shots taken ("three", "four", "5" etc).
  /// The caller supplies [holePar] so the outcome can be derived.
  static VoiceCommand parse(String raw) {
    final text = raw.toLowerCase().trim();

    // ── Navigation (always works well) ──────────────────────────
    if (_matches(text, ['next', 'next hole', 'move on', 'advance', 'continue', 'forward', 'go next', 'move next'])) {
      return NextHoleCommand();
    }
    if (_matches(text, ['back', 'previous', 'previous hole', 'go back', 'last hole', 'go previous'])) {
      return PrevHoleCommand();
    }

    // ── Undo ─────────────────────────────────────────────────────
    if (_matches(text, ['undo', 'undo that', 'cancel', 'cancel that', 'mistake', 'wrong', 'delete', 'that was wrong'])) {
      return UndoCommand();
    }

    // ── Shot count — primary scoring method ─────────────────────
    // Supports "one" through "ten" and digits 1–10
    final shots = _extractShotCount(text);
    if (shots != null) return ShotsCommand(shots);

    // ── Putts — "one putt", "two putts" ─────────────────────────
    final puttsMatch = RegExp(r'(\w+)\s*putt').firstMatch(text);
    if (puttsMatch != null) {
      final count = _wordToInt(puttsMatch.group(1) ?? '');
      if (count != null) return SetPuttsCommand(count);
    }

    // ── Fairway / GIR ────────────────────────────────────────────
    if (_matches(text, ['fairway', 'fairway hit', 'hit the fairway', 'in the fairway'])) {
      return FairwayHitCommand();
    }
    if (_matches(text, ['gir', 'green', 'green in regulation', 'on the green', 'hit the green'])) {
      return GirCommand();
    }

    // ── Fallback: golf terms (kept as backup) ────────────────────
    if (_matches(text, ['double', 'double bogey', 'trouble', 'bubble'])) {
      return OutcomeCommand(HoleOutcome.doubleBogey);
    }
    if (_matches(text, ['eagle', 'ace', 'hole in one'])) {
      return OutcomeCommand(HoleOutcome.eagle);
    }
    if (_matches(text, ['birdie', 'birdy', 'bird', 'bardi'])) {
      return OutcomeCommand(HoleOutcome.birdie);
    }
    if (_matches(text, ['bogey', 'bogie', 'boogie'])) {
      return OutcomeCommand(HoleOutcome.bogey);
    }
    if (_matches(text, ['par', 'pa', 'pah'])) {
      return OutcomeCommand(HoleOutcome.par);
    }
    if (_matches(text, ['pickup', 'pick up', 'given', 'concede'])) {
      return OutcomeCommand(HoleOutcome.pickup);
    }

    return UnrecognisedCommand(raw);
  }

  /// Convert shot count to HoleOutcome given the hole par.
  static HoleOutcome? outcomeFromShots(int shots, int par) {
    final diff = shots - par;
    return switch (diff) {
      <= -2 => HoleOutcome.eagle,
      -1    => HoleOutcome.birdie,
      0     => HoleOutcome.par,
      1     => HoleOutcome.bogey,
      _     => HoleOutcome.doubleBogey,
    };
  }

  static bool _matches(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  static int? _extractShotCount(String text) {
    // Phrase forms — number FIRST or natural flow words before number
    // "four shots", "took four", "got four", "hit four", "made four"
    // "score" removed — STT finalises on it before hearing the number

    // "N shots" — number first, most natural on-course phrasing
    final shotsAfterMatch = RegExp(r'\b(\w+)\s+shots?\b').firstMatch(text);
    if (shotsAfterMatch != null) {
      final n = _wordToInt(shotsAfterMatch.group(1)!);
      if (n != null) return n;
    }

    // "took/got/hit/made N"
    final phraseMatch = RegExp(
      r'(?:took|taken|hit|made|got|had|i got|i took|i made)\s+(\w+)',
    ).firstMatch(text);
    if (phraseMatch != null) {
      final n = _wordToInt(phraseMatch.group(1)!);
      if (n != null) return n;
    }

    // Single word/digit fallback
    const words = {
      'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
      'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
      // NZ STT mishearings
      'won': 1, 'to': 2, 'too': 2, 'fore': 4, 'for': 4, 'ate': 8,
    };
    for (final entry in words.entries) {
      if (RegExp(r'\b' + entry.key + r'\b').hasMatch(text)) {
        return entry.value;
      }
    }

    // Digit
    final digitMatch = RegExp(r'\b([1-9]|10)\b').firstMatch(text);
    if (digitMatch != null) return int.tryParse(digitMatch.group(1)!);
    return null;
  }

  static int? _wordToInt(String word) => switch (word) {
        'one' || 'won' || '1' => 1,
        'two' || 'to' || 'too' || '2' => 2,
        'three' || '3' => 3,
        'four' || 'fore' || 'for' || '4' => 4,
        'five' || '5' => 5,
        'six' || '6' => 6,
        'seven' || '7' => 7,
        'eight' || 'ate' || '8' => 8,
        'nine' || '9' => 9,
        'ten' || '10' => 10,
        _ => null,
      };

}
