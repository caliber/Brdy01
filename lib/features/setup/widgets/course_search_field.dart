import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/brdy_colors.dart';
import '../providers/course_search_query_provider.dart';
import '../providers/course_search_results_provider.dart';

class CourseSearchField extends ConsumerWidget {
  final TextEditingController controller;

  const CourseSearchField({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(courseSearchResultsProvider);
    final isLoading = resultsAsync.isLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          style: Theme.of(context).textTheme.labelLarge,
          decoration: InputDecoration(
            labelText: 'SEARCH COURSES',
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: BrdyColors.onSurfaceMuted,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close, size: 20),
                    color: BrdyColors.onSurfaceMuted,
                    onPressed: () {
                      controller.clear();
                      ref.read(courseSearchQueryProvider.notifier).set('');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            ref.read(courseSearchQueryProvider.notifier).set(value);
          },
        ),
        if (isLoading)
          const LinearProgressIndicator(
            color: BrdyColors.accent,
            backgroundColor: BrdyColors.divider,
            minHeight: 1,
          ),
      ],
    );
  }
}
