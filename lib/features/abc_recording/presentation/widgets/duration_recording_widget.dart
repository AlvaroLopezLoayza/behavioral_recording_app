import 'dart:async';
import 'package:flutter/material.dart';

class DurationRecordingWidget extends StatefulWidget {
  final String label;
  final Function(DateTime start, DateTime end, Duration duration) onStop;

  const DurationRecordingWidget({
    super.key,
    required this.label,
    required this.onStop,
  });

  @override
  State<DurationRecordingWidget> createState() => _DurationRecordingWidgetState();
}

class _DurationRecordingWidgetState extends State<DurationRecordingWidget> {
  bool _isRunning = false;
  DateTime? _startTime;
  Duration _currentDuration = Duration.zero;
  Timer? _timer;

  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _startTime = DateTime.now();
      _isRunning = true;
      _currentDuration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentDuration = DateTime.now().difference(_startTime!);
      });
    });
  }

  void _stopTimer() {
    final endTime = DateTime.now();
    _timer?.cancel();
    _timer = null;
    
    widget.onStop(_startTime!, endTime, _currentDuration);
    
    setState(() {
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    final tenths = (d.inMilliseconds.remainder(1000) / 100).floor();
    return "$minutes:$seconds.$tenths";
  }

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
            widget.label,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // StopWatch display
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isRunning 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.tertiary.withAlpha(100),
                width: 4,
              ),
            ),
            child: Text(
              _formatDuration(_currentDuration),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton.icon(
              onPressed: _toggleTimer,
              icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
              label: Text(_isRunning ? 'DETENER' : 'INICIAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning ? Colors.red.shade400 : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
