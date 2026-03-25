import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class UgoSwipeButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onSwipe;

  const UgoSwipeButton({
    super.key,
    required this.text,
    required this.color,
    required this.onSwipe,
  });

  @override
  State<UgoSwipeButton> createState() => _UgoSwipeButtonState();
}

class _UgoSwipeButtonState extends State<UgoSwipeButton>
    with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  bool _isFinished = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool _hasMidwayFeedback = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDragDistance =
            constraints.maxWidth - 66; // Account for circle + padding
        final double currentPosition = maxDragDistance * _dragValue;

        return Container(
          height: 66,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(33),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.15), width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // 1. Dynamic Background Fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: currentPosition + 60,
                height: 66,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color.withValues(alpha: 0.9),
                      widget.color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(33),
                ),
              ),

              // 2. Center Text with Shimmer-like Opacity
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity:
                      _isFinished ? 0.0 : (1.0 - _dragValue).clamp(0.2, 1.0),
                  child: Text(
                    widget.text,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // 3. Success Indicator
              if (_isFinished)
                const Center(
                  child: Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 36),
                ),

              // 4. THE SLIDER HANDLE
              Positioned(
                left: currentPosition + 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isFinished) return;
                    setState(() {
                      _dragValue += details.primaryDelta! / maxDragDistance;
                      _dragValue = _dragValue.clamp(0.0, 1.0);

                      // Precise Haptic Feedback at 50%
                      if (_dragValue > 0.5 && !_hasMidwayFeedback) {
                        HapticFeedback.mediumImpact();
                        _hasMidwayFeedback = true;
                      } else if (_dragValue < 0.5) {
                        _hasMidwayFeedback = false;
                      }

                      // Visual bounce as it nears completion
                      if (_dragValue > 0.8) {
                        _bounceController.forward();
                      } else {
                        _bounceController.reverse();
                      }
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isFinished) return;

                    if (_dragValue > 0.85) {
                      // SUCCESS
                      setState(() {
                        _dragValue = 1.0;
                        _isFinished = true;
                      });
                      HapticFeedback.heavyImpact();
                      Future.delayed(
                          const Duration(milliseconds: 300), widget.onSwipe);
                    } else {
                      // RESET with Elastic feel
                      HapticFeedback.lightImpact();
                      setState(() {
                        _dragValue = 0.0;
                      });
                      _bounceController.reverse();
                    }
                  },
                  child: ScaleTransition(
                    scale: _bounceAnimation,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4)),
                        ],
                      ),
                      child: Icon(
                        _isFinished
                            ? Icons.done_all_rounded
                            : Icons.double_arrow_rounded,
                        color: widget.color,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
