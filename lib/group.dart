import 'package:flutter/widgets.dart';

class Group<T> {
  /// attribute - must be uniq string like '#', "@", "some" ...
  String attribute;

  Function getString;
  Function fieldBuilder;

  List<T> suggestions;
  List<T> existFields;

  bool showSelectedFieldsInSuggestions;

  Function? onCreate;

  /// onSelectSuggestion - setup if suggestions is not null.
  Function? onSelectSuggestion;
  Function? suggestionBuilder;
  Function? onRemove;

  Group({
    required this.attribute,
    required String Function(T) this.getString,
    required Widget Function(T) this.fieldBuilder,
    this.suggestions = const [],
    this.existFields = const [],
    this.showSelectedFieldsInSuggestions = false,
    Future<T> Function(String text)? this.onCreate,
    Future Function(T field)? this.onSelectSuggestion,
    Widget Function(T field)? this.suggestionBuilder,
    Future Function(T deleted)? this.onRemove,
  });
}
