import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Catches widget tree errors and shows a fallback UI instead of crashing.
/// Wraps key screens for Play Store resilience.
///
/// Uses Flutter's ErrorWidget.builder - when a descendant throws during build,
/// shows a fallback with retry instead of the default error display.
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.onError,
  });

  final Widget child;

  /// Shown when an error is caught. Defaults to a retry screen.
  final Widget Function(Object error, StackTrace stack, VoidCallback onRetry)?
      fallback;

  /// Called when an error is caught (e.g. for logging).
  final void Function(Object error, StackTrace stack)? onError;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  static final List<_ErrorBoundaryState> _boundaryStack = [];
  static ErrorWidgetBuilder? _savedBuilder;

  int _retryKey = 0;

  void _retry() {
    setState(() => _retryKey++);
  }

  static Widget _customErrorWidget(FlutterErrorDetails details) {
    final state = _boundaryStack.isNotEmpty ? _boundaryStack.last : null;
    if (state != null) {
      state.widget.onError?.call(
        details.exception,
        details.stack ?? StackTrace.current,
      );
    }
    if (state != null && state.mounted) {
      return state._buildFallback(details.exception, details.stack);
    }
    return (_savedBuilder ?? _defaultErrorBuilder)(details);
  }

  static Widget _defaultErrorBuilder(FlutterErrorDetails details) {
    return ErrorWidget(details.exception);
  }

  @override
  void initState() {
    super.initState();
    if (_boundaryStack.isEmpty) {
      _savedBuilder = ErrorWidget.builder;
    }
    _boundaryStack.add(this);
    ErrorWidget.builder = _customErrorWidget;
  }

  @override
  void dispose() {
    _boundaryStack.remove(this);
    if (_boundaryStack.isEmpty && _savedBuilder != null) {
      ErrorWidget.builder = _savedBuilder!;
      _savedBuilder = null;
    }
    super.dispose();
  }

  Widget _buildFallback(Object error, StackTrace? stack) {
    final fallback = widget.fallback ?? _defaultFallback;
    return fallback(error, stack ?? StackTrace.current, _retry);
  }

  Widget _defaultFallback(Object error, StackTrace stack, VoidCallback onRetry) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Please try again.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(FFLocalizations.of(context).getText('err0001')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(_retryKey),
      child: widget.child,
    );
  }
}
