part of 'groups_field_bloc.dart';

abstract class GroupsFieldBlocInterface {
  Stream<GroupsFieldState> get stateStream;
  StreamController<GroupsFieldEvent> get eventController;

  void dispose();
}
