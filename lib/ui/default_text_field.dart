import 'package:flutter/material.dart';

class DefaultTextField extends StatefulWidget {
  const DefaultTextField({super.key});

  @override
  State<DefaultTextField> createState() => _DefaultTextFieldState();
}

class _DefaultTextFieldState extends State<DefaultTextField> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: textFieldFocusNode,
      onSubmitted: (_) =>
          widget.onSubmitted == null ? null : widget.onSubmitted!(),
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(
          top: cursorPosition.dy,
          left: cursorPosition.dx,
          bottom: cursorPosition.dy == 0 ? 0 : lastFieldSize.height / 2,
        ),
      ),
    );
  }
}
