import 'dart:async';

import 'package:flutter/material.dart';

class IntervalRecordingWidget extends StatefulWidget {
  final String label;
  final Function(List<int> activeIntervals, int intervalLength) onComplete;

  const IntervalRecordingWidget({
    super.key,
    required this.label,
    required this.onComplete,
  });

  @override
  State<IntervalRecordingWidget> createState() => _IntervalRecordingWidgetState();
}

class _IntervalRecordingWidgetState extends State<IntervalRecordingWidget> {
  int _intervalLength = 10; // seconds
  final List<int> _activeIntervals = [];
  int _currentInterval = 0;
  bool _isSessionRunning = false;
  Timer? _timer;
  int _elapsedSeconds = 0;

  void _startSession() {
    setState(() {
      _isSessionRunning = true;
      _activeIntervals.clear();
      _currentInterval = 1;
      _elapsedSeconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        _currentInterval = (_elapsedSeconds / _intervalLength).floor() + 1;
      });
    });
  }

  void _stopSession() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isSessionRunning = false;
    });
    // We don't automatically call onComplete here, user might want to review
  }

  void _toggleInterval(int interval) {
    setState(() {
      if (_activeIntervals.contains(interval)) {
        _activeIntervals.remove(interval);
      } else {
        _activeIntervals.add(interval);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          
          if (!_isSessionRunning && _elapsedSeconds == 0) ...[
            DropdownButtonFormField<int>(
              value: _intervalLength,
              decoration: const InputDecoration(labelText: 'Duración del Intervalo (seg)'),
              items: [10, 15, 30, 60].map((s) => DropdownMenuItem(value: s, child: Text('$s segundos'))).toList(),
              onChanged: (val) => setState(() => _intervalLength = val!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _startSession, child: const Text('Comenzar Sesión de Intervalos')),
          ] else ...[
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('Intervalo Actual: #$_currentInterval', style: const TextStyle(fontWeight: FontWeight.bold)),
                     Text('Tiempo: $_elapsedSeconds s'),
                   ],
                 ),
                 ElevatedButton(
                   onPressed: _isSessionRunning ? _stopSession : () => widget.onComplete(_activeIntervals, _intervalLength),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: _isSessionRunning ? Colors.red.shade400 : Colors.green.shade400,
                   ),
                   child: Text(_isSessionRunning ? 'Finalizar' : 'Guardar Datos'),
                 ),
               ],
             ),
             const SizedBox(height: 24),
             Wrap(
               spacing: 8,
               runSpacing: 8,
               children: List.generate((_elapsedSeconds / _intervalLength).ceil().clamp(1, 20), (index) {
                 final intervalNum = index + 1;
                 final isActive = _activeIntervals.contains(intervalNum);
                 final isCurrent = intervalNum == _currentInterval;
                 
                 return GestureDetector(
                   onTap: () => _toggleInterval(intervalNum),
                   child: AnimatedContainer(
                     duration: const Duration(milliseconds: 200),
                     width: 50,
                     height: 50,
                     decoration: BoxDecoration(
                       color: isActive 
                           ? Theme.of(context).colorScheme.primary 
                           : (isCurrent ? Theme.of(context).colorScheme.secondary.withAlpha(100) : Colors.grey.shade200),
                       borderRadius: BorderRadius.circular(12),
                       border: isCurrent ? Border.all(color: Theme.of(context).colorScheme.secondary, width: 2) : null,
                     ),
                     child: Center(
                       child: Text(
                         '$intervalNum',
                         style: TextStyle(
                           color: isActive ? Colors.white : Colors.black87,
                           fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                         ),
                       ),
                     ),
                   ),
                 );
               }),
             ),
             const SizedBox(height: 16),
             const Text('Toca los intervalos donde ocurrió la conducta (Registro Parcial)', 
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}
