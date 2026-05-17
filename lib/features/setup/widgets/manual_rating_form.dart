import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/selected_course_provider.dart';

class ManualRatingForm extends ConsumerStatefulWidget {
  final VoidCallback onSaved;

  const ManualRatingForm({super.key, required this.onSaved});

  @override
  ConsumerState<ManualRatingForm> createState() => _ManualRatingFormState();
}

class _ManualRatingFormState extends ConsumerState<ManualRatingForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _crController;
  late final TextEditingController _slopeController;

  @override
  void initState() {
    super.initState();
    _crController = TextEditingController();
    _slopeController = TextEditingController();
  }

  @override
  void dispose() {
    _crController.dispose();
    _slopeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cr = double.parse(_crController.text);
    final slope = int.parse(_slopeController.text);
    ref
        .read(selectedCourseProvider.notifier)
        .overrideRating(rating: cr, slope: slope);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _crController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,2}(\.\d{0,1})?$')),
              ],
              style: Theme.of(context).textTheme.labelLarge,
              decoration: const InputDecoration(labelText: 'COURSE RATING'),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n < 55.0 || n > 80.0) {
                  return 'Course Rating must be 55.0 – 80.0';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _slopeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              style: Theme.of(context).textTheme.labelLarge,
              decoration: const InputDecoration(labelText: 'SLOPE RATING'),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 55 || n > 155) {
                  return 'Slope must be 55 – 155';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('SAVE RATING'),
            ),
          ],
        ),
      ),
    );
  }
}
