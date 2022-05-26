@TestOn('vm || browser')
library bloc_test;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:groups_field/group.dart';
import 'package:groups_field/bloc/groups_field_bloc.dart';

void main() {
  group("Bloc", () {
    test("can prepare groups fields structure", () async {
      final firstGroup = Group<String>(
        attribute: "",
        getString: (String value) => value,
        fieldBuilder: Text.new,
        existFields: ["FirstGroup1", "FirstGroup2"],
      );

      final secondGroup = Group<int>(
        attribute: "#",
        getString: (value) => value.toString(),
        fieldBuilder: (field) => Text(field.toString()),
        existFields: [1, 2],
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [],
      );

      final groupsFields = bloc.prepareExistedGroupsFields(
        groups: [
          firstGroup,
          secondGroup,
        ],
      );

      expect(groupsFields, isNotEmpty);
      expect(groupsFields[0].group.attribute, equals(""));
      expect(groupsFields[0].text, equals("FirstGroup1"));
      expect(groupsFields[0].widget, isNotNull);

      expect(groupsFields[2].group.attribute, equals("#"));
      expect(groupsFields[2].text, equals("1"));
      expect(groupsFields[2].widget, isNotNull);

      bloc.dispose();
    });

    test("can prepare group fields for render", () async {
      final firstGroup = Group<String>(
        attribute: "",
        getString: (value) => value,
        fieldBuilder: Text.new,
        existFields: ["FirstGroup1", "FirstGroup2"],
      );

      final secondGroup = Group<int>(
        attribute: "#",
        getString: (value) => value.toString(),
        fieldBuilder: (field) => Text(field.toString()),
        existFields: [1, 2],
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [
          firstGroup,
          secondGroup,
        ],
      );

      final event = PrepareExistedGroupsFieldsWidgets();
      bloc.eventController.add(event);

      await for (final state in bloc.stateStream) {
        if (state is GroupExistedFieldsWidgetsDone) {
          expect(state.widgets.length, equals(4));

          final widgets = state.widgets.toString();
          const expectedWidgets =
              // ignore: lines_longer_than_80_chars
              '[Text("FirstGroup1"), Text("FirstGroup2"), Text("1"), Text("2")]';

          expect(widgets, equals(expectedWidgets));

          break;
        }
      }

      bloc.dispose();
    });

    test("can remove latest field", () async {
      final firstGroup = Group<String>(
        attribute: "",
        onCreate: null,
        getString: (value) => value,
        fieldBuilder: Text.new,
        existFields: ["FirstGroup1", "FirstGroup2"],
      );

      int? removedField;
      final secondGroup = Group<int>(
        attribute: "#",
        onCreate: null,
        getString: (value) => value.toString(),
        fieldBuilder: (field) => Text(field.toString()),
        onRemove: (field) async => removedField = field,
        existFields: [1, 2],
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [
          firstGroup,
          secondGroup,
        ],
      );

      final event = PrepareExistedGroupsFieldsWidgets();
      bloc.eventController.add(event);

      expect(removedField, isNull);

      await for (final state in bloc.stateStream) {
        if (state is GroupExistedFieldsWidgetsDone) {
          expect(state.widgets.length, equals(4));

          final removeTextEvent = TextFieldChanged(
            textFieldValue: "",
            isRemovedFieldKeyPressed: true,
          );

          bloc.eventController.add(removeTextEvent);

          continue;
        }

        if (state is GroupFieldRemove) {
          expect(state.widgets.length, equals(3));
          expect(state.removedFieldText, equals("2"));
          expect(state.removedField, isNotNull);
          break;
        }
      }

      expect(removedField, equals(2));

      bloc.dispose();
    });

    test("can check group of text", () async {
      final firstGroup = Group<String>(
        attribute: "",
        onCreate: null,
        getString: (value) => value,
        fieldBuilder: Text.new,
      );

      final secondGroup = Group<int>(
        attribute: "#",
        onCreate: null,
        getString: (value) => value.toString(),
        fieldBuilder: (field) => Text(field.toString()),
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [],
      );

      final firstCheckGroup = bloc.checkGroupOfText(
        text: "test,",
        groups: [
          firstGroup,
          secondGroup,
        ],
      );

      expect(firstCheckGroup, equals(firstGroup));

      final secondCheckGroup = bloc.checkGroupOfText(
        text: "#test,",
        groups: [
          firstGroup,
          secondGroup,
        ],
      );

      expect(secondCheckGroup, equals(secondGroup));

      bloc.dispose();
    });

    test("can delete symbols from text", () async {
      final delimiters = [",", ";"];

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: delimiters,
        groups: [],
      );

      final cleanText = bloc.removeSymbolsFromText(
        text: '#test with some text,',
        symbols: ["#", ",", ""],
      );

      expect(cleanText, equals("test with some text"));

      bloc.dispose();
    });

    test("can prepare group field from text 1", () async {
      final firstGroup = Group<String>(
        attribute: "",
        getString: (value) => value,
        fieldBuilder: Text.new,
        onCreate: (text) async => text,
      );

      final secondGroup = Group<int>(
        attribute: "#",
        onCreate: null,
        getString: (value) => value.toString(),
        fieldBuilder: (field) => Text(field.toString()),
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [
          firstGroup,
          secondGroup,
        ],
      );

      final newFieldText = TextFieldChanged(
        textFieldValue: "newField,",
        isRemovedFieldKeyPressed: false,
      );

      bloc.eventController.add(newFieldText);

      await for (final state in bloc.stateStream) {
        if (state is NewFieldAdd) {
          expect(state.widgets.length, equals(1));
          expect(state.newFieldText, equals("newField"));
          expect(state.addedField, isNotNull);
          expect(state.addedFieldGroup, firstGroup);
          break;
        }
      }

      bloc.dispose();
    });

    test("can prepare group field from text 2", () async {
      final firstGroup = Group<String>(
        attribute: "",
        onCreate: null,
        getString: (value) => value,
        fieldBuilder: Text.new,
      );

      final secondGroup = Group<int>(
        attribute: "#",
        onCreate: (text) async => int.parse(text),
        getString: (value) => value.toString(),
        fieldBuilder: (field) => Text(field.toString()),
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [
          firstGroup,
          secondGroup,
        ],
      );

      final newFieldText = TextFieldChanged(
        textFieldValue: "#6,",
        isRemovedFieldKeyPressed: false,
      );

      bloc.eventController.add(newFieldText);

      await for (final state in bloc.stateStream) {
        if (state is NewFieldAdd) {
          expect(state.widgets.length, equals(1));
          expect(state.newFieldText, equals("6"));
          expect(state.addedField, isNotNull);
          expect(state.addedFieldGroup, secondGroup);
          break;
        }
      }

      bloc.dispose();
    });

    test("can prepare group field from text 3", () async {
      final firstGroup = Group<String>(
        attribute: "some_attribute",
        onCreate: (field) async => field,
        getString: (field) => field,
        fieldBuilder: Text.new,
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [
          firstGroup,
        ],
      );

      final newFieldText = TextFieldChanged(
        textFieldValue: "some_attributesome_text,",
        isRemovedFieldKeyPressed: false,
      );

      bloc.eventController.add(newFieldText);

      await for (final state in bloc.stateStream) {
        if (state is NewFieldAdd) {
          expect(state.widgets.length, equals(1));
          expect(state.newFieldText, equals("some_text"));
          expect(state.addedField, isNotNull);
          expect(state.addedFieldGroup, firstGroup);
          break;
        }
      }

      bloc.dispose();
    });

    test("can prepare suggestions", () async {
      final firstGroup = Group<String>(
        attribute: "",
        onCreate: null,
        getString: (field) => field,
        fieldBuilder: Text.new,
        suggestions: ["First", "Second", "Conference"],
      );

      final secondGroup = Group<int>(
        attribute: "#",
        onCreate: null,
        getString: (field) => field.toString(),
        fieldBuilder: (field) => Text(field.toString()),
        suggestionBuilder: (field) => Text(field.toString()),
        suggestions: [123, 456],
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [],
      );

      final firstGroupSuggestionFields = bloc.prepareGroupFieldsByPredicate(
        predicate: "con",
        group: firstGroup,
      );

      expect(firstGroupSuggestionFields, isNotNull);
      expect(firstGroupSuggestionFields.length, equals(2));

      final firstGroupSuggestion = bloc.prepareGroupSuggestions(
        fields: firstGroupSuggestionFields,
        group: firstGroup,
      );

      expect(firstGroupSuggestion, isNotNull);
      expect(firstGroupSuggestion.length, equals(2));
      expect(
        firstGroupSuggestion.toString(),
        equals('[Text("Second"), Text("Conference")]'),
      );

      final secondGroupSuggestionFields = bloc.prepareGroupFieldsByPredicate(
        predicate: '2',
        group: secondGroup,
      );

      expect(secondGroupSuggestionFields, isNotNull);
      expect(secondGroupSuggestionFields.length, equals(1));

      final secondGroupSuggestion = bloc.prepareGroupSuggestions(
        fields: secondGroupSuggestionFields,
        group: secondGroup,
      );

      expect(secondGroupSuggestion, isNotNull);
      expect(secondGroupSuggestion.length, equals(1));
      expect(
        secondGroupSuggestion.first.toString(),
        equals('Text("123")'),
      );

      bloc.dispose();
    });

    test("can get already selected group fields", () async {
      final firstGroup = Group<String>(
        attribute: "",
        onCreate: null,
        getString: (field) => field,
        fieldBuilder: Text.new,
        suggestions: ["First", "Second", "Conference"],
        existFields: ["First"],
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [firstGroup],
      );

      bloc.fields = bloc.prepareExistedGroupsFields(groups: bloc.groups);

      final alreadySelectedGroupFields = bloc.getAlreadySelectedGroupFields(
        allExistedFields: bloc.fields,
        group: firstGroup,
      );

      expect(alreadySelectedGroupFields, isNotEmpty);
      expect(alreadySelectedGroupFields.length, equals(1));
      expect(alreadySelectedGroupFields.first.text, equals("First"));

      bloc.dispose();
    });

    test("can check already selected field", () async {
      final firstGroup = Group<String>(
        attribute: "",
        onCreate: null,
        getString: (field) => field,
        fieldBuilder: Text.new,
        suggestions: ["First", "Second", "Conference"],
        existFields: ["Second"],
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [firstGroup],
      );

      bloc.fields = bloc.prepareExistedGroupsFields(groups: bloc.groups);

      final isFirstSelectedField = bloc.isAlreadySelectedField(
        existedFields: bloc.fields,
        field: "First",
      );

      expect(isFirstSelectedField, isFalse);

      final isSecondSelectedField = bloc.isAlreadySelectedField(
        existedFields: bloc.fields,
        field: "Second",
      );

      expect(isSecondSelectedField, isTrue);

      bloc.dispose();
    });

    test("can prepare without selected fields suggestions", () async {
      final firstGroup = Group<String>(
        attribute: "",
        onCreate: null,
        getString: (field) => field,
        fieldBuilder: Text.new,
        suggestions: ["First", "Second", "Conference"],
        existFields: ["Conference"],
        showSelectedFieldsInSuggestions: false,
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [firstGroup],
      );

      bloc.fields = bloc.prepareExistedGroupsFields(groups: bloc.groups);

      final alreadySelectedGroupFields = bloc.getAlreadySelectedGroupFields(
        allExistedFields: bloc.fields,
        group: firstGroup,
      );

      final firstGroupSuggestionFields =
          bloc.prepareGroupFieldsByPredicateWithoutAlreadyExistedFields(
        predicate: "con",
        group: firstGroup,
        existedGroupFields: alreadySelectedGroupFields,
      );

      expect(firstGroupSuggestionFields, isNotNull);
      expect(firstGroupSuggestionFields.length, equals(1));

      final firstGroupSuggestion = bloc.prepareGroupSuggestions(
        fields: firstGroupSuggestionFields,
        group: firstGroup,
      );

      expect(firstGroupSuggestion, isNotNull);
      expect(firstGroupSuggestion.length, equals(1));
      expect(
        firstGroupSuggestion.toString(),
        equals('[Text("Second")]'),
      );

      bloc.dispose();
    });

    test("can select suggestion", () async {
      final suggestions = ["First", "Second", "Conference"];

      final firstGroup = Group<String>(
        attribute: "#",
        onCreate: null,
        getString: (field) => field,
        fieldBuilder: Text.new,
        suggestions: suggestions,
      );

      final bloc = GroupsFieldBloc(
        isFieldCanBeDeleted: true,
        delimiters: [","],
        groups: [
          firstGroup,
        ],
      );

      final textFieldChangedEvent = TextFieldChanged(
        textFieldValue: "#con",
        isRemovedFieldKeyPressed: false,
      );

      bloc.eventController.add(textFieldChangedEvent);

      await for (final state in bloc.stateStream) {
        if (state is SuggestionsReady) {
          expect(
            state.widgets.toString(),
            equals('[Text("Second"), Text("Conference")]'),
          );

          break;
        }
      }

      final selectSuggestionEvent = SuggestionSelected(
        suggestion: "Second",
        group: firstGroup,
      );

      bloc.eventController.add(selectSuggestionEvent);

      await for (final state in bloc.stateStream) {
        if (state is SuggestionSelect) {
          expect(state.widgets.length, equals(1));
          expect(
            state.widgets.toString(),
            equals('[Text("Second")]'),
          );

          expect(state.group, equals(firstGroup));
          expect(state.field, equals("Second"));
          expect(state.text, equals("Second"));

          break;
        }
      }

      bloc.dispose();
    });
  });
}
