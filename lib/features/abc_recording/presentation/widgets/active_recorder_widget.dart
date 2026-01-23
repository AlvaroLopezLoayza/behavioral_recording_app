import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/abc_record.dart';

class ActiveRecorderWidget extends StatefulWidget {
  final RecordingType type;
  final String label;
  final VoidCallback onLogEvent;
  // TODO: Add support for Duration/Interval callbacks later

  const ActiveRecorderWidget({
    super.key,
    required this.type,
    required this.label,
    required this.onLogEvent,
  });

  @override
  State<ActiveRecorderWidget> createState() => _ActiveRecorderWidgetState();
}

class _ActiveRecorderWidgetState extends State<ActiveRecorderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    HapticFeedback.lightImpact(); // Tactile feedback
    widget.onLogEvent();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // For now focusing on Event type as the main "Button"
    // Duration/Interval will need different UIs (Toggle vs Ring)
    // But for the MVP "Live Logger", we'll start with the big button.
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - _controller.value,
              child: Container(
                width: double.infinity,
                height: 200, // Make it BIG
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.touch_app_rounded, size: 64, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'REGISTRAR',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
