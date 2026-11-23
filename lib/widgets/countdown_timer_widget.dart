import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime deadlineUtc;
  final bool isCompleted;

  const CountdownTimerWidget({
    super.key,
    required this.deadlineUtc,
    this.isCompleted = false,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  void _updateRemaining() {
    if (mounted) {
      setState(() {
        _remaining = widget.deadlineUtc.difference(DateTime.now().toUtc());
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text(l10n.statusCompleted, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (_remaining.isNegative) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red),
            const SizedBox(width: 4),
            Text(l10n.deadlinePassed, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    final isUrgent = days == 0 && hours < 6;
    final isWarning = days < 2;

    final bgColor = isUrgent ? Colors.red.shade50 : (isWarning ? Colors.orange.shade50 : Colors.blue.shade50);
    final fgColor = isUrgent ? Colors.red.shade800 : (isWarning ? Colors.orange.shade800 : Colors.blue.shade800);
    final borderColor = isUrgent ? Colors.red.shade300 : (isWarning ? Colors.orange.shade300 : Colors.blue.shade200);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: fgColor),
          const SizedBox(width: 6),
          Text(
            days > 0
                ? '$days ${l10n.days} : $hours ${l10n.hours} : $minutes ${l10n.minutes}'
                : '$hours ${l10n.hours} : $minutes ${l10n.minutes} : $seconds ${l10n.seconds}',
            style: TextStyle(
              color: fgColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
