import 'package:flutter/material.dart';

/// It's a TextField that has a custom cursor position and a custom bottom padding
class DefaultTextField extends StatelessWidget {
  final Size lastFieldSize;
  final Offset cursorPosition;

  final Function? onSubmitted;
  final FocusNode? textFieldFocusNode;
  final TextEditingController? controller;

  final InputDecoration? inputDecoration;

  const DefaultTextField({
    super.key,
    required this.lastFieldSize,
    required this.cursorPosition,
    this.onSubmitted,
    this.textFieldFocusNode,
    this.controller,
    this.inputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final callback = onSubmitted;

    final contentPadding = EdgeInsets.only(
      top: cursorPosition.dy,
      left: cursorPosition.dx,
      bottom: cursorPosition.dy == 0 ? 0 : lastFieldSize.height / 2,
    );

    final decorator = inputDecoration;

    return TextField(
      focusNode: textFieldFocusNode,
      onSubmitted: (_) => callback == null ? null : callback(),
      controller: controller,
      decoration: decorator == null
          ? InputDecoration(contentPadding: contentPadding)
          : decorator.copyWith(contentPadding: contentPadding, isDense: false),
    );
  }
}
