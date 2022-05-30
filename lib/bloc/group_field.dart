part of 'groups_field_bloc.dart';

class GroupField {
  final String text;
  final Group group;
  final Widget widget;

  // ignore: no-object-declaration
  final Object field;

  GroupField({
    required this.text,
    required this.group,
    required this.widget,
    required this.field,
  });
}
