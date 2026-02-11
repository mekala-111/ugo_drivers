// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class UgoSwipeButton extends StatefulWidget {
//   final String text;
//   final Color color;
//   final VoidCallback onSwipe;
//   const UgoSwipeButton({
//     Key? key,
//     required this.text,
//     required this.color,
//     required this.onSwipe,
//   }) : super(key: key);
//
//   @override
//   _UgoSwipeButtonState createState() => _UgoSwipeButtonState();
// }
//
// class _UgoSwipeButtonState extends State<UgoSwipeButton>
//     with SingleTickerProviderStateMixin {
//   double _dragValue = 0.0;
//   bool _isFinished = false;
//   late AnimationController _bounceController;
//   late Animation<double> _bounceAnimation;
//   bool _hasProvidedFeedback = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _bounceController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _bounceController.dispose();
//     super.dispose();
//   }
//
//   void _provideFeedback() {
//     if (!_hasProvidedFeedback) {
//       HapticFeedback.mediumImpact();
//       _hasProvidedFeedback = true;
//     }
//   }
//
//   void _resetFeedback() {
//     _hasProvidedFeedback = false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double maxDragDistance = constraints.maxWidth - 60;
//         final double currentPosition = maxDragDistance * _dragValue;
//
//         return Container(
//           height: 60,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: _isFinished
//                   ? [widget.color, widget.color]
//                   : [
//                       widget.color.withOpacity(0.8),
//                       widget.color.withOpacity(0.95),
//                     ],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//             ),
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: widget.color.withOpacity(0.3),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Stack(
//             alignment: Alignment.centerLeft,
//             children: [
//               // Background progress indicator
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 width: currentPosition + 30,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.white.withOpacity(0.1),
//                       Colors.white.withOpacity(0.05),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//
//               // Chevron arrows
//               if (!_isFinished)
//                 Positioned.fill(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 70),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: List.generate(
//                         5,
//                         (index) => AnimatedOpacity(
//                           duration: const Duration(milliseconds: 200),
//                           opacity: _dragValue > (index * 0.15) ? 0.3 : 0.6,
//                           child: Icon(
//                             Icons.chevron_right,
//                             color: Colors.white.withOpacity(0.4),
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//               // Center text
//               Center(
//                 child: AnimatedOpacity(
//                   duration: const Duration(milliseconds: 200),
//                   opacity: _isFinished ? 0.0 : 1.0 - (_dragValue * 0.5),
//                   child: Text(
//                     widget.text,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),
//               ),
//
//               // Success checkmark
//               if (_isFinished)
//                 Center(
//                   child: TweenAnimationBuilder<double>(
//                     duration: const Duration(milliseconds: 400),
//                     tween: Tween(begin: 0.0, end: 1.0),
//                     builder: (context, value, child) {
//                       return Transform.scale(
//                         scale: value,
//                         child: const Icon(
//                           Icons.check_circle,
//                           color: Colors.white,
//                           size: 32,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//               // Draggable circle
//               AnimatedPositioned(
//                 duration: _isFinished
//                     ? const Duration(milliseconds: 300)
//                     : Duration.zero,
//                 curve: Curves.easeOut,
//                 left: _isFinished ? maxDragDistance : currentPosition,
//                 child: GestureDetector(
//                   onHorizontalDragStart: (details) {
//                     if (_isFinished) return;
//                     HapticFeedback.selectionClick();
//                     _resetFeedback();
//                   },
//                   onHorizontalDragUpdate: (details) {
//                     if (_isFinished) return;
//                     setState(() {
//                       _dragValue += details.primaryDelta! / maxDragDistance;
//                       _dragValue = _dragValue.clamp(0.0, 1.0);
//
//                       // Provide haptic feedback at certain thresholds
//                       if (_dragValue > 0.5 && !_hasProvidedFeedback) {
//                         _provideFeedback();
//                       }
//
//                       // Bounce animation near the end
//                       if (_dragValue > 0.85) {
//                         _bounceController.forward();
//                       } else {
//                         _bounceController.reverse();
//                       }
//                     });
//                   },
//                   onHorizontalDragEnd: (details) {
//                     if (_isFinished) return;
//                     _bounceController.reverse();
//
//                     if (_dragValue > 0.75) {
//                       // Success!
//                       HapticFeedback.heavyImpact();
//                       setState(() {
//                         _dragValue = 1.0;
//                         _isFinished = true;
//                       });
//                       // Delay callback slightly for animation
//                       Future.delayed(const Duration(milliseconds: 200), () {
//                         widget.onSwipe();
//                       });
//                     } else {
//                       // Reset with haptic
//                       if (_dragValue > 0.3) {
//                         HapticFeedback.lightImpact();
//                       }
//                       setState(() {
//                         _dragValue = 0.0;
//                       });
//                     }
//                     _resetFeedback();
//                   },
//                   child: AnimatedBuilder(
//                     animation: _bounceAnimation,
//                     builder: (context, child) {
//                       return Transform.scale(
//                         scale: _bounceAnimation.value,
//                         child: Container(
//                           margin: const EdgeInsets.all(5),
//                           height: 50,
//                           width: 50,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: _isFinished
//                               ? Icon(Icons.check, color: widget.color, size: 28)
//                               : Stack(
//                                   alignment: Alignment.center,
//                                   children: [
//                                     // Animated pulsing circle
//                                     if (_dragValue < 0.1)
//                                       TweenAnimationBuilder<double>(
//                                         duration:
//                                             const Duration(milliseconds: 1500),
//                                         tween: Tween(begin: 0.8, end: 1.0),
//                                         curve: Curves.easeInOut,
//                                         onEnd: () {
//                                           if (mounted) setState(() {});
//                                         },
//                                         builder: (context, value, child) {
//                                           return Transform.scale(
//                                             scale: value,
//                                             child: Container(
//                                               width: 50,
//                                               height: 50,
//                                               decoration: BoxDecoration(
//                                                 shape: BoxShape.circle,
//                                                 border: Border.all(
//                                                   color: widget.color
//                                                       .withOpacity(0.3),
//                                                   width: 2,
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     Icon(
//                                       Icons.arrow_forward,
//                                       color: widget.color,
//                                       size: 28,
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
