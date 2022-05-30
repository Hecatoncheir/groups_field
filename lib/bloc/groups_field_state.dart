part of 'groups_field_bloc.dart';

@immutable
abstract class GroupsFieldState {}

class GroupsFieldInitial extends GroupsFieldState {}

class GroupExistedFieldsWidgetsDone extends GroupsFieldState {
  /// widgets - already build all existed fields in groups.
  final List<Widget> widgets;

  GroupExistedFieldsWidgetsDone({
    required this.widgets,
  });
}

class CursorPositionUpdate extends GroupsFieldState {
  /// cursorPosition - for position cursor in text field.
  final Offset cursorPosition;

  final Size fieldsSize;

  /// lastFieldSize - can be use for make right padding in text field.
  final Size lastFieldSize;

  CursorPositionUpdate({
    required this.cursorPosition,
    required this.fieldsSize,
    required this.lastFieldSize,
  });
}

class GroupFieldRemove extends GroupsFieldState {
  /// widgets - already build fields in groups.
  final List<Widget> widgets;
  final String removedFieldText;

  // ignore: no-object-declaration
  final Object removedField;

  final Group removedFieldGroup;

  GroupFieldRemove({
    required this.widgets,
    required this.removedField,
    required this.removedFieldGroup,
    required this.removedFieldText,
  });
}

class NewFieldAdd extends GroupsFieldState {
  /// widgets - already build fields in groups.
  final List<Widget> widgets;
  final String newFieldText;

  final Widget addedFieldWidget;

  // ignore: no-object-declaration
  final Object addedField;

  final Group addedFieldGroup;

  NewFieldAdd({
    required this.widgets,
    required this.addedFieldWidget,
    required this.newFieldText,
    required this.addedField,
    required this.addedFieldGroup,
  });
}

class SuggestionsReady extends GroupsFieldState {
  /// widgets - already build suggestions of group.
  final List<Widget> widgets;
  final List<Object> fields;
  final String predicate;
  final Group group;

  SuggestionsReady({
    required this.widgets,
    required this.fields,
    required this.predicate,
    required this.group,
  });
}

class SuggestionSelect extends GroupsFieldState {
  /// widgets - already build fields in groups.
  final List<Widget> widgets;

  // ignore: no-object-declaration
  final Object field;

  final Group group;
  final String text;

  SuggestionSelect({
    required this.widgets,
    required this.field,
    required this.group,
    required this.text,
  });
}
