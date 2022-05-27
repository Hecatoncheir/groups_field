import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:groups_field/groups_field.dart';
import 'package:groups_field/ui/fields_not_scrollable.dart';

class FieldsScrollable extends StatefulWidget {
  final GroupsFieldBlocInterface bloc;
  final GlobalKey fieldsKey;
  final GlobalKey lastFieldKey;

  const FieldsScrollable({
    super.key,
    required this.bloc,
    required this.fieldsKey,
    required this.lastFieldKey,
  });

  @override
  State<FieldsScrollable> createState() => _FieldsScrollableState();
}

class _FieldsScrollableState extends State<FieldsScrollable> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();

    widget.bloc.stateStream
        .where(
      (event) =>
          event is GroupExistedFieldsWidgetsDone ||
          event is GroupFieldRemove ||
          event is NewFieldAdd ||
          event is SuggestionSelect,
    )
        .listen((state) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.ease,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: FieldsNotScrollable(
        bloc: widget.bloc,
        fieldsKey: widget.fieldsKey,
        lastFieldKey: widget.lastFieldKey,
      ),
    );
  }
}
