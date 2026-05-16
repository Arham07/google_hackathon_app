import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Draws a red emergency / flood-alert pin for map markers.
Future<BitmapDescriptor> createFloodAlertMarkerIcon() async {
  const double size = 120;
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  const Offset center = Offset(size / 2, size / 2);
  const double radius = size / 2 - 6;

  final Paint shadow = Paint()
    ..color = Colors.black.withValues(alpha: 0.25)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  canvas.drawCircle(center + const Offset(0, 3), radius, shadow);

  final Paint fill = Paint()..color = const Color(0xFFD32F2F);
  canvas.drawCircle(center, radius, fill);

  final Paint border = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;
  canvas.drawCircle(center, radius, border);

  final Paint wave = Paint()
    ..color = Colors.white.withValues(alpha: 0.95)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  canvas.drawArc(
    Rect.fromCenter(center: Offset(center.dx, center.dy + 18), width: 44, height: 16),
    0.1,
    2.9,
    false,
    wave,
  );
  canvas.drawArc(
    Rect.fromCenter(center: Offset(center.dx, center.dy + 28), width: 56, height: 18),
    0.2,
    2.8,
    false,
    wave,
  );

  final TextPainter exclamation = TextPainter(
    textDirection: TextDirection.ltr,
    text: const TextSpan(
      text: '!',
      style: TextStyle(
        color: Colors.white,
        fontSize: 52,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    ),
  )..layout();

  exclamation.paint(
    canvas,
    Offset(
      center.dx - exclamation.width / 2,
      center.dy - exclamation.height / 2 - 14,
    ),
  );

  final ui.Image image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(
    byteData!.buffer.asUint8List(),
    width: 48,
    height: 48,
  );
}
