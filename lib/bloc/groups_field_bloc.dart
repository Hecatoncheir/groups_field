// ignore_for_file: no-magic-number

import 'dart:async';

import 'package:pedantic/pedantic.dart';

import 'package:flutter/widgets.dart';

import 'package:groups_field/group.dart';

part 'groups_field_bloc_interface.dart';
part 'group_field.dart';
part 'groups_field_event.dart';
part 'groups_field_state.dart';

class GroupsFieldBloc implements GroupsFieldBlocInterface {
  final List<Group> groups;

  @visibleForTesting
  final List<String> delimiters;

  @visibleForTesting
  final bool isScrollable;

  @visibleForTesting
  final bool isFieldCanBeDeleted;

  @visibleForTesting
  List<GroupField> fields;

  String textFieldValue;

  late final StreamController<GroupsFieldState> stateController;

  @override
  late final Stream<GroupsFieldState> stateStream;

  @override
  late final StreamController<GroupsFieldEvent> eventController;

  late final Stream<GroupsFieldEvent> eventStream;

  GroupsFieldBloc({
    required this.groups,
    required this.delimiters,
    required this.isFieldCanBeDeleted,
    this.isScrollable = false,
    this.textFieldValue = "",
  }) : fields = <GroupField>[] {
    stateController = StreamController<GroupsFieldState>();
    stateStream =
        stateController.stream.asBroadcastStream().asBroadcastStream();

    eventController = StreamController<GroupsFieldEvent>();
    eventStream = eventController.stream;

    eventStream.listen((event) async {
      if (event is PrepareExistedGroupsFieldsWidgets) {
        unawaited(prepareExistedGroupsFieldsWidgets(event));
      }
      if (event is GroupFieldsRendered) unawaited(groupFieldsRendered(event));
      if (event is SizeChanged) unawaited(sizeChanged(event));
      if (event is TextFieldChanged) unawaited(textFieldChanged(event));
      if (event is SuggestionSelected) unawaited(suggestionSelected(event));
    });
  }

  @override
  void dispose() {
    stateController.close();
    eventController.close();
  }

  @visibleForTesting
  Future<void> prepareExistedGroupsFieldsWidgets(
    PrepareExistedGroupsFieldsWidgets _,
  ) async {
    fields = prepareExistedGroupsFields(groups: groups);
    final widgets = fields.map((field) => field.widget).toList();
    final state = GroupExistedFieldsWidgetsDone(widgets: widgets);
    stateController.add(state);
  }

  @visibleForTesting
  Future<void> groupFieldsRendered(GroupFieldsRendered event) async {
    final Offset cursorPosition = getCursorPosition(
      lastChildElement: event.lastChildElement,
      parentElement: event.parentElement,
      parentLayoutElement: event.parentLayoutElement,
      isScrollable: isScrollable,
    );

    final lastChildElement = event.lastChildElement;
    final lastFieldSize =
        lastChildElement == null ? const Size(0, 0) : lastChildElement.size;

    final state = CursorPositionUpdate(
      cursorPosition: cursorPosition,
      fieldsSize: event.parentLayoutElement.size,
      lastFieldSize: lastFieldSize,
    );

    stateController.add(state);
  }

  @visibleForTesting
  Future<void> sizeChanged(SizeChanged event) async {
    final Offset cursorPosition = getCursorPosition(
      lastChildElement: event.lastChildElement,
      parentElement: event.parentElement,
      parentLayoutElement: event.parentLayoutElement,
      isScrollable: isScrollable,
    );

    final fieldsSize = isScrollable
        ? event.parentLayoutElement.size
        : Size(cursorPosition.dx, event.parentLayoutElement.size.height);

    final lastChildElement = event.lastChildElement;
    final lastFieldSize =
        lastChildElement == null ? const Size(0, 0) : lastChildElement.size;

    final state = CursorPositionUpdate(
      cursorPosition: cursorPosition,
      fieldsSize: fieldsSize,
      lastFieldSize: lastFieldSize,
    );

    stateController.add(state);
  }

  @visibleForTesting
  Future<void> textFieldChanged(TextFieldChanged event) async {
    Group? group;
    String? onlyFieldText;

    final currentTextFieldValue = event.textFieldValue;

    if (currentTextFieldValue.isNotEmpty) {
      group = checkGroupOfText(
        text: currentTextFieldValue,
        groups: groups,
      );

      if (group != null) {
        final symbolsForRemove = List<String>.from(delimiters)
          ..add(group.attribute);

        onlyFieldText = removeSymbolsFromText(
          symbols: symbolsForRemove,
          text: currentTextFieldValue,
        );

        List<Object> groupSuggestionsFields;

        if (group.showSelectedFieldsInSuggestions) {
          groupSuggestionsFields = prepareGroupFieldsByPredicate(
            predicate: onlyFieldText,
            group: group,
          );
        } else {
          final groupSelectedFields = getAlreadySelectedGroupFields(
            allExistedFields: fields,
            group: group,
          );

          groupSuggestionsFields =
              prepareGroupFieldsByPredicateWithoutAlreadyExistedFields(
            predicate: onlyFieldText,
            existedGroupFields: groupSelectedFields,
            group: group,
          );
        }

        final groupSuggestions = prepareGroupSuggestions(
          fields: groupSuggestionsFields,
          group: group,
        );

        final state = SuggestionsReady(
          widgets: groupSuggestions,
          fields: groupSuggestionsFields,
          predicate: currentTextFieldValue,
          group: group,
        );

        stateController.add(state);
      }
    }

    final previousTextFieldValue = textFieldValue;

    /// latest field must be removed.
    if (event.isRemovedFieldKeyPressed &&
        isFieldCanBeDeleted &&
        fields.isNotEmpty &&
        previousTextFieldValue.isEmpty &&
        currentTextFieldValue.isEmpty) {
      final lastFieldForRemove = fields.last;
      fields.remove(lastFieldForRemove);

      final widgets = fields.map((field) => field.widget).toList();

      final removedField = lastFieldForRemove.field;
      final removedFieldGroup = lastFieldForRemove.group;
      final removedFieldText = lastFieldForRemove.text;

      final onRemoveCallback = removedFieldGroup.onRemove;
      if (onRemoveCallback != null) unawaited(onRemoveCallback(removedField));

      final state = GroupFieldRemove(
        widgets: widgets,
        removedFieldGroup: removedFieldGroup,
        removedField: removedField,
        removedFieldText: removedFieldText,
      );

      stateController.add(state);

      textFieldValue = event.textFieldValue;
    } else {
      // Check is new text must be a field.

      final isTextMustBeGroupField = isTextContainsDelimiters(
        text: currentTextFieldValue,
        delimiters: delimiters,
      );

      if (group != null && onlyFieldText != null && isTextMustBeGroupField) {
        // New field must be added.

        final onCreateCallback = group.onCreate;
        if (onCreateCallback == null) return;

        final field = await onCreateCallback(onlyFieldText);
        final widget = group.fieldBuilder(field);

        final fieldGroup = GroupField(
          text: onlyFieldText,
          group: group,
          widget: widget,
          field: field,
        );

        fields.add(fieldGroup);

        final widgets = fields.map((field) => field.widget).toList();

        final state = NewFieldAdd(
          widgets: widgets,
          newFieldText: onlyFieldText,
          addedField: field,
          addedFieldGroup: group,
          addedFieldWidget: widget,
        );

        stateController.add(state);

        textFieldValue = "";
      } else {
        textFieldValue = event.textFieldValue;
      }
    }
  }

  @visibleForTesting
  Future<void> suggestionSelected(SuggestionSelected event) async {
    final group = event.group;
    final field = event.suggestion;

    final onSelectSuggestion = group.onSelectSuggestion;
    if (onSelectSuggestion != null) await onSelectSuggestion(field);

    final fieldText = group.getString(field);
    final widget = group.fieldBuilder(field);

    final groupField = GroupField(
      text: fieldText,
      group: event.group,
      widget: widget,
      field: field,
    );

    fields.add(groupField);
    final widgets = fields.map((field) => field.widget).toList();

    final state = SuggestionSelect(
      widgets: widgets,
      field: field,
      group: group,
      text: fieldText,
    );

    stateController.add(state);
  }

  @visibleForTesting
  String removeSymbolsFromText({
    required List<String> symbols,
    required String text,
  }) {
    String updatedText = text;
    for (final symbol in symbols) {
      updatedText = updatedText.replaceAll(symbol, "");
    }
    return updatedText;
  }

  @visibleForTesting
  Group? checkGroupOfText({
    required String text,
    required List<Group> groups,
  }) {
    Group? group;
    group = findGroupByText(text: text, groups: groups);
    group ??= findGroupByAttribute(attribute: "", groups: groups);
    return group;
  }

  @visibleForTesting
  Group? findGroupByText({
    required String text,
    required List<Group> groups,
  }) {
    Group? updatedGroup;

    for (final group in groups) {
      if (group.attribute.isEmpty) continue;

      final groupAttribute = group.attribute;

      if (text.length >= groupAttribute.length) {
        final attributeInText = text.substring(0, groupAttribute.length);

        if (group.attribute == attributeInText) {
          updatedGroup = group;
          break;
        }
      }
    }

    return updatedGroup;
  }

  @visibleForTesting
  Group? findGroupByAttribute({
    required String attribute,
    required List<Group> groups,
  }) {
    Group? updatedGroup;
    for (final group in groups) {
      if (group.attribute == attribute) {
        updatedGroup = group;
        break;
      }
    }

    return updatedGroup;
  }

  @visibleForTesting
  bool isTextContainsDelimiters({
    required String text,
    required List<String> delimiters,
  }) {
    bool isTextContainsDelimiters = false;

    for (final delimiter in delimiters) {
      if (text.contains(delimiter)) {
        isTextContainsDelimiters = true;
        break;
      }
    }

    return isTextContainsDelimiters;
  }

  @visibleForTesting
  List<GroupField> prepareExistedGroupsFields({
    required List<Group> groups,
  }) {
    final fields = <GroupField>[];

    for (final group in groups) {
      if (group.existFields.isEmpty) continue;

      for (final field in group.existFields) {
        final text = group.getString(field);
        final widget = group.fieldBuilder(field);

        final groupField = GroupField(
          text: text,
          group: group,
          widget: widget,
          field: field,
        );

        fields.add(groupField);
      }
    }

    return fields;
  }

  @visibleForTesting
  Offset getCursorPosition({
    required RenderBox? lastChildElement,
    required RenderBox? parentElement,
    required RenderBox parentLayoutElement,
    required bool isScrollable,
  }) {
    Offset cursorPosition;

    if (isScrollable) {
      cursorPosition = parentElement == null
          ? const Offset(0, 0)
          : parentElement.size.width < parentLayoutElement.size.width
              ? Offset(
                  parentElement.size.width,
                  parentElement.size.height / 2,
                )
              : Offset(
                  parentLayoutElement.size.width,
                  parentLayoutElement.size.height / 2,
                );
    } else {
      Offset offset;

      if (lastChildElement == null) {
        offset = const Offset(0, 0);
      } else {
        final childOffsetOfParent = lastChildElement.localToGlobal(
          Offset.zero,
          ancestor: parentElement,
        );

        final left = childOffsetOfParent.dx + lastChildElement.size.width;
        final height =
            childOffsetOfParent.dy + lastChildElement.size.height / 2;

        offset = Offset(left, height);
      }

      cursorPosition = offset;
    }

    return cursorPosition;
  }

  @visibleForTesting
  List<Object> prepareGroupFieldsByPredicate({
    required String predicate,
    required Group group,
  }) {
    final fields = <Object>[];

    for (final suggestion in group.suggestions) {
      final String text = group.getString(suggestion);

      final lowerCaseString = text.toLowerCase();

      if (lowerCaseString.contains(predicate)) {
        fields.add(suggestion);
      }
    }

    return fields;
  }

  @visibleForTesting
  List<GroupField> getAlreadySelectedGroupFields({
    required List<GroupField> allExistedFields,
    required Group group,
  }) {
    final fields = <GroupField>[];

    for (final existedField in allExistedFields) {
      if (existedField.group == group) {
        fields.add(existedField);
      }
    }

    return fields;
  }

  @visibleForTesting
  List<Object> prepareGroupFieldsByPredicateWithoutAlreadyExistedFields({
    required String predicate,
    required List<GroupField> existedGroupFields,
    required Group group,
  }) {
    final fields = <Object>[];

    for (final suggestion in group.suggestions) {
      final String text = group.getString(suggestion);

      final lowerCaseString = text.toLowerCase();

      if (lowerCaseString.contains(predicate)) {
        final isAlreadySelected = isAlreadySelectedField(
          existedFields: existedGroupFields,
          field: suggestion,
        );

        if (!isAlreadySelected) {
          fields.add(suggestion);
        }
      }
    }

    return fields;
  }

  @visibleForTesting
  bool isAlreadySelectedField({
    required List<GroupField> existedFields,
    required Object field,
  }) {
    bool isAlreadySelectedField = false;

    for (final existedField in existedFields) {
      if (existedField.field == field) {
        isAlreadySelectedField = true;
        break;
      }
    }

    return isAlreadySelectedField;
  }

  @visibleForTesting
  List<Widget> prepareGroupSuggestions({
    required List<Object> fields,
    required Group group,
  }) {
    final widgets = <Widget>[];

    final suggestionBuilder = group.suggestionBuilder;
    if (suggestionBuilder == null) {
      for (final field in fields) {
        final text = group.getString(field);

        final widget = Text(text);
        widgets.add(widget);
      }
    } else {
      for (final field in fields) {
        final widget = suggestionBuilder(field);
        widgets.add(widget);
      }
    }

    return widgets;
  }
}
