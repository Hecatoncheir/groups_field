@TestOn('vm || browser')
library groups_field_test;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:groups_field/groups_field.dart';

void main() {
  group("GroupsField", () {
    late List<Group> groups;

    setUpAll(() {
      final firstGroup = Group<String>(
        attribute: "",
        onCreate: null,
        getString: (value) => value,
        fieldBuilder: (field) => Text(field),
        suggestionBuilder: (field) => Text(field),
        existFields: ["FirstGroup1", "FirstGroup2"],
      );

      final secondGroup = Group<int>(
        attribute: "#",
        onCreate: null,
        getString: (value) => value.toString(),
        fieldBuilder: (field) => Text(field.toString()),
        suggestionBuilder: (field) => Text(field.toString()),
        existFields: [1, 2],
      );

      groups = [
        firstGroup,
        secondGroup,
      ];
    });

    group("scrollable mode", () {
      const isScrollable = true;

      testWidgets(
        "can show existed group values",
        (tester) async {
          final testWidget = GroupsField(
            isScrollable: isScrollable,
            groups: groups,
          );

          final widget = MaterialApp(
            home: Scaffold(
              body: testWidget,
            ),
          );

          await tester.pumpWidget(widget);
          await tester.pumpAndSettle();

          expect(find.byKey(const Key("GroupsField")), findsOneWidget);

          expect(find.text("FirstGroup1"), findsOneWidget);
          expect(find.text("FirstGroup2"), findsOneWidget);

          expect(find.text("1"), findsOneWidget);
          expect(find.text("2"), findsOneWidget);
        },
      );
    });

    group("not scrollable mode", () {
      const bool isScrollable = false;

      testWidgets(
        "can show existed group values",
        (tester) async {
          final testWidget = GroupsField(
            isScrollable: isScrollable,
            groups: groups,
          );

          final widget = MaterialApp(
            home: Scaffold(
              body: testWidget,
            ),
          );

          await tester.pumpWidget(widget);
          await tester.pumpAndSettle();

          expect(find.byKey(const Key("GroupsField")), findsOneWidget);

          expect(find.text("FirstGroup1"), findsOneWidget);
          expect(find.text("FirstGroup2"), findsOneWidget);

          expect(find.text("1"), findsOneWidget);
          expect(find.text("2"), findsOneWidget);
        },
      );
    });
  });
}
