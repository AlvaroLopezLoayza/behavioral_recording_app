import 'package:flutter/material.dart';

class EventCounterWidget extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  const EventCounterWidget({
    super.key,
    required this.label,
    required this.count,
    required this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Counter Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface, // Cream background
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary.withAlpha(100),
                width: 2,
              ),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onDecrement != null)
                _CircleButton(
                  icon: Icons.remove,
                  onPressed: count > 0 ? onDecrement : null,
                  color: Theme.of(context).colorScheme.secondary,
                  isSmall: true,
                ),
                
              if (onDecrement != null) const SizedBox(width: 32),
              
              _CircleButton(
                icon: Icons.add,
                onPressed: onIncrement,
                color: Theme.of(context).colorScheme.primary, // Terracotta
                size: 80,
                iconSize: 40,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Toca para registrar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;
  final double iconSize;
  final bool isSmall;

  const _CircleButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.size = 56,
    this.iconSize = 28,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSmall) {
      return IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: color.withAlpha(50),
          foregroundColor: color,
        ),
      );
    }
    
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: color.withAlpha(100),
        ),
        child: Icon(icon, size: iconSize),
      ),
    );
  }
}
