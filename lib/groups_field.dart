// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'ui/fields_not_scrollable.dart';
import 'ui/fields_scrollable.dart';
import 'ui/group_suggestions.dart';
import 'ui/overlay_container.dart';
import 'ui/default_text_field.dart';

import 'bloc/groups_field_bloc.dart';
import 'group.dart';

export 'bloc/groups_field_bloc.dart';
export 'group.dart';

typedef OnChanged = Function(String text);

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
  final OnChanged? onChanged;

  final InputDecoration? textFieldDecoration;

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
    this.onChanged,
    this.textFieldDecoration,
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
            closeOverlay();

            final lastChildElement = _lastFieldKey.currentContext == null
                ? null
                : _lastFieldKey.currentContext?.findRenderObject() as RenderBox;

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
            closeOverlay();

            final lastChildElement =
                _lastFieldKey.currentContext?.findRenderObject() as RenderBox;

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

      if (state is SuggestionsReady) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (state.widgets.isNotEmpty) {
            final size = _textFieldKey.currentContext?.size;
            if (size == null) return;

            final constrains = BoxConstraints(
              minWidth: size.width,
              maxWidth: size.width,
              minHeight: size.height,
              maxHeight: size.height,
            );

            final textFieldElement =
                _textFieldKey.currentContext?.findRenderObject() as RenderBox;

            final offsetOfTextField =
                textFieldElement.localToGlobal(Offset.zero);

            final offset = Offset(
              offsetOfTextField.dx,
              offsetOfTextField.dy + textFieldElement.size.height,
            );

            final suggestionsAreaBuilder = widget.suggestionsAreaBuilder;
            final suggestionsContainer = suggestionsAreaBuilder == null
                ? GroupSuggestions(
                    bloc: _bloc,
                    suggestions: state.widgets,
                    fields: state.fields,
                    group: state.group,
                  )
                : suggestionsAreaBuilder(
                    constrains,
                    offset,
                    state.widgets,
                    state.fields,
                    state.group,
                  );

            final overlayEntry = buildOverlayContainer(
              child: suggestionsContainer,
              constrains: constrains,
              offset: offset,
            );

            openOverlay(overlayEntry);
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

        SchedulerBinding.instance.addPostFrameCallback(
          (timeStamp) {
            closeOverlay();

            final lastChildElement =
                _lastFieldKey.currentContext?.findRenderObject() as RenderBox;

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
                  StreamBuilder<GroupsFieldState>(
                    stream: _bloc.stateStream
                        .where((event) => event is CursorPositionUpdate),
                    builder: (context, snapshot) {
                      final state = snapshot.data;

                      final textFieldBuilder = widget.textFieldBuilder;

                      if (state is CursorPositionUpdate) {
                        final controller = _textEditingController;
                        final cursorPosition = state.cursorPosition;
                        final fieldsSize = state.fieldsSize;
                        final lastFieldSize = state.lastFieldSize;

                        return Container(
                          key: _textFieldKey,
                          child: RawKeyboardListener(
                            focusNode: _focusNode,
                            onKey: textFieldOnKeyPressed,
                            child: textFieldBuilder == null
                                ? DefaultTextField(
                                    controller: controller,
                                    cursorPosition: cursorPosition,
                                    lastFieldSize: lastFieldSize,
                                    onSubmitted: widget.onSubmitted,
                                    onChanged: widget.onChanged,
                                    textFieldFocusNode: _textFieldFocusNode,
                                    inputDecoration: widget.textFieldDecoration,
                                  )
                                : textFieldBuilder(
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
                  ),
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

  void openOverlay(OverlayEntry overlayEntry) {
    _overlayEntry?.remove();
    _overlayEntry = overlayEntry;

    final overlay = Overlay.of(context);
    overlay?.insert(overlayEntry);
  }

  void closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// When the widget is rendered, get the last child element, the parent element,
  /// and the parent layout element, and then send a SizeChanged event to the bloc
  Future<void> onSizeChanged() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final lastChildElement =
          _lastFieldKey.currentContext?.findRenderObject() as RenderBox?;

      final parentElement =
          _fieldsKey.currentContext?.findRenderObject() as RenderBox;

      final parentLayoutElement =
          _fieldsLayoutKey.currentContext?.findRenderObject() as RenderBox;

      final event = SizeChanged(
        lastChildElement: lastChildElement,
        parentElement: parentElement,
        parentLayoutElement: parentLayoutElement,
      );

      _bloc.eventController.add(event);
    });
  }

  /// If the user presses the key that is set to trigger the removal of the text
  /// field, and the text field is empty, then remove the text field
  ///
  /// Args:
  ///   event (RawKeyEvent): The event that was triggered.
  void textFieldOnKeyPressed(RawKeyEvent event) {
    final text = _textEditingController.text;

    if (event is RawKeyUpEvent &&
        event.logicalKey == widget.keyForTriggerRemoveField) {
      if (text.isEmpty) {
        final event = TextFieldChanged(
          textFieldValue: text,
          isRemovedFieldKeyPressed: true,
        );

        _bloc.eventController.add(event);
      }
    } else {
      final event = TextFieldChanged(
        textFieldValue: text,
        isRemovedFieldKeyPressed: false,
      );

      _bloc.eventController.add(event);
    }
  }
}
