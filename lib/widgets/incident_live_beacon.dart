import 'package:flutter/material.dart';

/// Subtle pulsing red “live” indicator for very recent incidents.
class IncidentLiveBeacon extends StatefulWidget {
  const IncidentLiveBeacon({super.key});

  @override
  State<IncidentLiveBeacon> createState() => _IncidentLiveBeaconState();
}

class _IncidentLiveBeaconState extends State<IncidentLiveBeacon> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFEF4444),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.75),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
        ),
      ),
    );
  }
}
