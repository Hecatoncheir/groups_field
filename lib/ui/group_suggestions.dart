import 'package:flutter/material.dart';
import 'package:groups_field/groups_field.dart';

class GroupSuggestions extends StatelessWidget {
  final GroupsFieldBlocInterface bloc;
  final List<Widget> suggestions;
  final List<Object> fields;
  final Group group;

  const GroupSuggestions({
    super.key,
    required this.bloc,
    required this.suggestions,
    required this.fields,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (final suggestion in suggestions)
          GestureDetector(
            onTap: () => onSuggestionSelect(suggestion),
            child: suggestion,
          ),
      ],
    );
  }

  void onSuggestionSelect(Widget suggestion) {
    final event = SuggestionSelected(
      suggestion: fields[suggestions.indexOf(suggestion)],
      group: group,
    );
    bloc.eventController.add(event);
  }
}
