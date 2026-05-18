import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareScorecard(BuildContext context, GlobalKey key) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();
    final xFile = XFile.fromData(
      bytes,
      mimeType: 'image/png',
      name: 'brdy_scorecard.png',
    );
    await Share.shareXFiles([xFile], subject: 'BRDY.01 Round Scorecard');
  }
}
