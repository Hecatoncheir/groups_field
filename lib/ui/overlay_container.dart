import 'package:flutter/material.dart';

OverlayEntry buildOverlayContainer({
  required BoxConstraints constrains,
  required Offset offset,
  required Widget child,
}) {
  return OverlayEntry(
    builder: (BuildContext context) {
      return Positioned(
        top: offset.dy,
        left: offset.dx,
        child: SizedBox(
          width: constrains.maxWidth,
          height: constrains.maxHeight,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: child,
          ),
        ),
      );
    },
  );
}
