import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'ui/fields_not_scrollable.dart';
import 'ui/fields_scrollable.dart';
import 'ui/group_suggestions.dart';
import 'ui/overlay_container.dart';

import 'bloc/groups_field_bloc.dart';
import 'group.dart';

export 'bloc/groups_field_bloc.dart';
export 'group.dart';

/// GroupsField - widget for build ui of custom groups text
/// by some attributes in one text field.
/// Just build ui of GroupsField widget with GroupsFieldBloc.
class GroupsField extends StatefulWidget {
  final List<Group> groups;
  final List<String> delimiters;

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    TextEditingController controller,
    Offset cursorPosition,
    Size fieldsSize,
    Size lastFieldSize,
    FocusNode textFieldFocusNode,
  )? textFieldBuilder;

  final Widget Function(
    BoxConstraints constrains,
    Offset position,
    List<Widget> suggestions,
    List<Object> fields,
    Group group,
  )? suggestionsAreaBuilder;

  final bool isScrollable;
  final bool isFieldCanBeDeleted;
  final bool isSuggestionsScrollable;
  final double textFieldWidth;

  final Function(Object field, Group group)? onSomeFieldOfGroupRemoved;
  final Function(Object field, Group group)? onSomeFieldOfGroupCreated;
  final Function(Object field, Group group)? onSomeFieldOfGroupSelected;

  final LogicalKeyboardKey keyForTriggerRemoveField;
  final Function? onSubmitted;

  const GroupsField({
    required this.groups,
    super.key,
    this.delimiters = const [',', ' '],
    this.isScrollable = true,
    this.isFieldCanBeDeleted = true,
    this.isSuggestionsScrollable = true,
    this.textFieldWidth = 260.0,
    this.textFieldBuilder,
    this.suggestionsAreaBuilder,
    this.onSomeFieldOfGroupRemoved,
    this.onSomeFieldOfGroupCreated,
    this.onSomeFieldOfGroupSelected,
    this.keyForTriggerRemoveField = LogicalKeyboardKey.backspace,
    this.onSubmitted,
  });

  @override
  State<GroupsField> createState() => _GroupsFieldState();
}

class _GroupsFieldState extends State<GroupsField> {
  late final GlobalKey _fieldsLayoutKey;
  late final GlobalKey _fieldsKey;
  late final GlobalKey _lastFieldKey;
  late final GlobalKey _textFieldKey;

  late final TextEditingController _textEditingController;

  late final FocusNode _focusNode;
  late final FocusNode _textFieldFocusNode;
  late bool _isRemovedFieldKeyPressed;

  OverlayEntry? _overlayEntry;

  late final GroupsFieldBloc _bloc;

  @override
  void initState() {
    super.initState();

    _fieldsLayoutKey = GlobalKey();
    _fieldsKey = GlobalKey();
    _lastFieldKey = GlobalKey();
    _textFieldKey = GlobalKey();

    _textEditingController = TextEditingController();
    _textEditingController.addListener(() {
      if (!_isRemovedFieldKeyPressed) {
        textFieldOnChangeHandler(
          context: context,
          fieldText: _textEditingController.text,
          isRemoved: _isRemovedFieldKeyPressed,
        );
      }
    });

    _isRemovedFieldKeyPressed = false;

    _focusNode = FocusNode();
    _textFieldFocusNode = FocusNode();

    // BloC
    _bloc = GroupsFieldBloc(
      delimiters: widget.delimiters,
      groups: widget.groups,
      isScrollable: widget.isScrollable,
      isFieldCanBeDeleted: widget.isFieldCanBeDeleted,
    );

    _bloc.stateStream
        .where(
      (event) =>
          event is GroupExistedFieldsWidgetsDone ||
          event is GroupFieldRemove ||
          event is NewFieldAdd ||
          event is SuggestionsReady ||
          event is SuggestionSelect,
    )
        .listen((state) {
      if (state is GroupExistedFieldsWidgetsDone) {
        SchedulerBinding.instance.addPostFrameCallback(
          (timeStamp) {
            final lastChildElement =
                _lastFieldKey.currentContext?.findRenderObject() as RenderBox?;

            final parentElement =
                _fieldsKey.currentContext?.findRenderObject() as RenderBox;

            final parentLayoutElement = _fieldsLayoutKey.currentContext
                ?.findRenderObject() as RenderBox;

            final event = GroupFieldsRendered(
              lastChildElement: lastChildElement,
              parentElement: parentElement,
              parentLayoutElement: parentLayoutElement,
            );

            _bloc.eventController.add(event);
          },
        );
      }

      if (state is GroupFieldRemove) {
        final onSomeFieldOfGroupRemoved = widget.onSomeFieldOfGroupRemoved;
        if (onSomeFieldOfGroupRemoved != null) {
          onSomeFieldOfGroupRemoved(
            state.removedField,
            state.removedFieldGroup,
          );
        }

        SchedulerBinding.instance.addPostFrameCallback(
          (timeStamp) {
            final lastChildElement = _lastFieldKey.currentContext == null
                ? null
                : _lastFieldKey.currentContext!.findRenderObject() as RenderBox;

            final parentElement =
                _fieldsKey.currentContext?.findRenderObject() as RenderBox;

            final parentLayoutElement = _fieldsLayoutKey.currentContext
                ?.findRenderObject() as RenderBox;

            final event = GroupFieldsRendered(
              lastChildElement: lastChildElement,
              parentElement: parentElement,
              parentLayoutElement: parentLayoutElement,
            );

            _bloc.eventController.add(event);
          },
        );
      }

      if (state is NewFieldAdd) {
        final onSomeFieldOfGroupCreated = widget.onSomeFieldOfGroupCreated;
        if (onSomeFieldOfGroupCreated != null) {
          onSomeFieldOfGroupCreated(
            state.addedField,
            state.addedFieldGroup,
          );
        }

        _textEditingController.clear();

        SchedulerBinding.instance.addPostFrameCallback(
          (timeStamp) {
            final lastChildElement =
                _lastFieldKey.currentContext!.findRenderObject() as RenderBox;

            final parentElement =
                _fieldsKey.currentContext!.findRenderObject() as RenderBox;

            final parentLayoutElement = _fieldsLayoutKey.currentContext!
                .findRenderObject() as RenderBox;

            final event = GroupFieldsRendered(
              lastChildElement: lastChildElement,
              parentElement: parentElement,
              parentLayoutElement: parentLayoutElement,
            );

            _bloc.eventController.add(event);
          },
        );
      }

      if (state is SuggestionsReady) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (_overlayEntry != null) {
            _overlayEntry!.remove();
            _overlayEntry = null;
          }

          if (state.widgets.isNotEmpty) {
            final size = _textFieldKey.currentContext!.size!;

            final constrains = BoxConstraints(
              minWidth: size.width,
              maxWidth: size.width,
              minHeight: size.height,
              maxHeight: size.height,
            );

            final textFieldElement =
                _textFieldKey.currentContext!.findRenderObject() as RenderBox;

            final offsetOfTextField =
                textFieldElement.localToGlobal(Offset.zero);

            final offset = Offset(
              offsetOfTextField.dx,
              offsetOfTextField.dy + textFieldElement.size.height,
            );

            Widget suggestionsContainer;

            final suggestionsAreaBuilder = widget.suggestionsAreaBuilder;
            if (suggestionsAreaBuilder == null) {
              suggestionsContainer = GroupSuggestions(
                bloc: _bloc,
                suggestions: state.widgets,
                fields: state.fields,
                group: state.group,
              );
            } else {
              suggestionsContainer = suggestionsAreaBuilder(
                constrains,
                offset,
                state.widgets,
                state.fields,
                state.group,
              );
            }

            _overlayEntry = buildOverlayContainer(
              child: suggestionsContainer,
              constrains: constrains,
              offset: offset,
            );

            final overlay = Overlay.of(context);
            overlay?.insert(_overlayEntry!);
          }
        });
      }

      if (state is SuggestionSelect) {
        final field = state.field;
        final group = state.group;

        final onSomeFieldOfGroupSelected = widget.onSomeFieldOfGroupSelected;
        if (onSomeFieldOfGroupSelected != null) {
          onSomeFieldOfGroupSelected(field, group);
        }

        _textEditingController.clear();
        _overlayEntry?.remove();
        _overlayEntry = null;

        SchedulerBinding.instance.addPostFrameCallback(
          (timeStamp) {
            final lastChildElement =
                _lastFieldKey.currentContext!.findRenderObject() as RenderBox;

            final parentElement =
                _fieldsKey.currentContext!.findRenderObject() as RenderBox;

            final parentLayoutElement = _fieldsLayoutKey.currentContext!
                .findRenderObject() as RenderBox;

            final event = GroupFieldsRendered(
              lastChildElement: lastChildElement,
              parentElement: parentElement,
              parentLayoutElement: parentLayoutElement,
            );

            _bloc.eventController.add(event);
          },
        );
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _bloc.eventController.add(PrepareExistedGroupsFieldsWidgets());
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    _focusNode.dispose();
    _textFieldFocusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      // ignore: prefer-extracting-callbacks
      onNotification: (notification) {
        onSizeChanged();
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(
          key: const Key("GroupsField"),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  buildTextField(constraints),
                  SizedBox(
                    key: _fieldsLayoutKey,
                    width: constraints.maxWidth - widget.textFieldWidth,
                    child: GestureDetector(
                      onTap: _textFieldFocusNode.requestFocus,
                      child: widget.isScrollable
                          ? FieldsScrollable(
                              bloc: _bloc,
                              fieldsKey: _fieldsKey,
                              lastFieldKey: _lastFieldKey,
                            )
                          : FieldsNotScrollable(
                              bloc: _bloc,
                              fieldsKey: _fieldsKey,
                              lastFieldKey: _lastFieldKey,
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> onSizeChanged() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final lastChildElement =
          _lastFieldKey.currentContext?.findRenderObject() as RenderBox?;

      final parentElement =
          _fieldsKey.currentContext!.findRenderObject() as RenderBox;

      final parentLayoutElement =
          _fieldsLayoutKey.currentContext!.findRenderObject() as RenderBox;

      final event = SizeChanged(
        lastChildElement: lastChildElement,
        parentElement: parentElement,
        parentLayoutElement: parentLayoutElement,
      );

      _bloc.eventController.add(event);
    });
  }

  Widget buildTextField(BoxConstraints constraints) {
    return StreamBuilder<GroupsFieldState>(
      stream: _bloc.stateStream.where((event) => event is CursorPositionUpdate),
      builder: (context, snapshot) {
        final state = snapshot.data;

        if (state is CursorPositionUpdate) {
          final controller = _textEditingController;
          final cursorPosition = state.cursorPosition;
          final fieldsSize = state.fieldsSize;
          final lastFieldSize = state.lastFieldSize;

          return Container(
            key: _textFieldKey,
            child: RawKeyboardListener(
              focusNode: _focusNode,
              onKey: (event) {
                if (event is RawKeyUpEvent &&
                    event.logicalKey == widget.keyForTriggerRemoveField) {
                  _isRemovedFieldKeyPressed = true;
                  final currentText = _textEditingController.text;
                  if (currentText.isEmpty) {
                    if (_overlayEntry != null) {
                      _overlayEntry!.remove();
                      _overlayEntry = null;
                    }

                    textFieldOnChangeHandler(
                      context: context,
                      fieldText: _textEditingController.text,
                      isRemoved: _isRemovedFieldKeyPressed,
                    );
                  }
                } else {
                  _isRemovedFieldKeyPressed = false;
                }
              },
              child: widget.textFieldBuilder == null
                  ? textFieldBuilder(
                      context: context,
                      constrains: constraints,
                      controller: controller,
                      cursorPosition: cursorPosition,
                      fieldsSize: fieldsSize,
                      lastFieldSize: lastFieldSize,
                      textFieldFocusNode: _textFieldFocusNode,
                    )
                  : widget.textFieldBuilder!(
                      context,
                      constraints,
                      controller,
                      cursorPosition,
                      fieldsSize,
                      lastFieldSize,
                      _textFieldFocusNode,
                    ),
            ),
          );
        }
        return Container();
      },
    );
  }

  /// textFieldBuilder - build twice.
  /// First build with default cursor position
  /// offset and second with other offset.
  Widget textFieldBuilder({
    required BuildContext context,
    required BoxConstraints constrains,
    required TextEditingController controller,
    required Offset cursorPosition,
    required Size fieldsSize,
    required Size lastFieldSize,
    required FocusNode textFieldFocusNode,
  }) {
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

  void textFieldOnChangeHandler({
    required BuildContext context,
    required String fieldText,
    required bool isRemoved,
  }) {
    final event = TextFieldChanged(
      textFieldValue: fieldText,
      isRemovedFieldKeyPressed: isRemoved,
    );

    _bloc.eventController.add(event);
  }
}
