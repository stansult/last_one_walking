// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _SectionCardBody extends StatelessWidget {
  const _SectionCardBody({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StyledText(text: title, style: AppVisuals.cardTitleTextStyle),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
