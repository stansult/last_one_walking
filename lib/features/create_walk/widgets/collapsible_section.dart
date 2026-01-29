// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.child,
    required this.expanded,
  });

  final Widget child;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: expanded ? 1 : 0,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: child,
          ),
        ),
      ),
    );
  }
}
