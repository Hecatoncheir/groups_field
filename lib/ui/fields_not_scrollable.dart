import 'package:flutter/material.dart';
import 'package:groups_field/groups_field.dart';

class FieldsNotScrollable extends StatelessWidget {
  final GroupsFieldBlocInterface bloc;
  final GlobalKey fieldsKey;
  final GlobalKey lastFieldKey;

  const FieldsNotScrollable({
    super.key,
    required this.bloc,
    required this.fieldsKey,
    required this.lastFieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GroupsFieldState>(
      stream: bloc.stateStream.where(
        (event) =>
            event is GroupExistedFieldsWidgetsDone ||
            event is GroupFieldRemove ||
            event is NewFieldAdd ||
            event is SuggestionSelect,
      ),
      builder: (context, snapshot) {
        final state = snapshot.data;

        final fields = <Widget>[];

        if (state is GroupExistedFieldsWidgetsDone) {
          fields.addAll(state.widgets);
        }

        if (state is GroupFieldRemove) {
          fields.addAll(state.widgets);
        }

        if (state is NewFieldAdd) {
          fields.addAll(state.widgets);
        }

        if (state is SuggestionSelect) {
          fields.addAll(state.widgets);
        }

        return Wrap(
          key: fieldsKey,
          children: [
            for (final field in fields)
              Container(
                key: fields.last == field ? lastFieldKey : null,
                child: field,
              ),
          ],
        );
      },
    );
  }
}
