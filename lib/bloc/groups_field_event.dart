part of 'groups_field_bloc.dart';

@immutable
abstract class GroupsFieldEvent {}

class PrepareExistedGroupsFieldsWidgets extends GroupsFieldEvent {}

class SizeChanged extends GroupsFieldEvent {
  final RenderBox? lastChildElement;
  final RenderBox parentElement;
  final RenderBox parentLayoutElement;

  SizeChanged({
    required this.lastChildElement,
    required this.parentElement,
    required this.parentLayoutElement,
  });
}

class GroupFieldsRendered extends GroupsFieldEvent {
  final RenderBox? lastChildElement;
  final RenderBox parentElement;
  final RenderBox parentLayoutElement;

  GroupFieldsRendered({
    required this.lastChildElement,
    required this.parentElement,
    required this.parentLayoutElement,
  });
}

class TextFieldChanged extends GroupsFieldEvent {
  final String textFieldValue;
  final bool isRemovedFieldKeyPressed;

  TextFieldChanged({
    required this.textFieldValue,
    required this.isRemovedFieldKeyPressed,
  });
}

class SuggestionSelected extends GroupsFieldEvent {
  final Group group;
  final Object suggestion;

  SuggestionSelected({
    required this.group,
    required this.suggestion,
  });
}
