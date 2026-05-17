import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/brdy_colors.dart';
import '../../../data/local/preferences/hive_player_prefs_provider.dart';

class HandicapInput extends ConsumerStatefulWidget {
  const HandicapInput({super.key});

  @override
  ConsumerState<HandicapInput> createState() => _HandicapInputState();
}

class _HandicapInputState extends ConsumerState<HandicapInput> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(hivePlayerPrefsProvider).handicapIndex;
    _controller = TextEditingController(text: saved?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= 0.0 && parsed <= 54.0) {
      ref.read(hivePlayerPrefsProvider).setHandicapIndex(parsed);
      setState(() => _error = null);
    } else if (value.isNotEmpty) {
      setState(() => _error = 'Handicap index must be between 0.0 and 54.0');
    } else {
      setState(() => _error = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,1})?$')),
      ],
      style: Theme.of(context).textTheme.labelLarge,
      decoration: InputDecoration(
        labelText: 'HANDICAP INDEX',
        hintText: '0.0',
        hintStyle: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: BrdyColors.onSurfaceMuted),
        errorText: _error,
        errorStyle: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: BrdyColors.destructive),
      ),
      onChanged: _onChanged,
    );
  }
}
