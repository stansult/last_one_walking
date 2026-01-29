// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _CardSurface extends StatelessWidget {
  const _CardSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisuals.cardShowBackground
            ? AppVisuals.cardBackgroundColor.withOpacity(AppVisuals.cardOpacity)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AppVisuals.useBlur && AppVisuals.cardBlurSigma > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppVisuals.cardBlurSigma,
                  sigmaY: AppVisuals.cardBlurSigma,
                ),
                child: child,
              )
            : child,
      ),
    );
  }
}
