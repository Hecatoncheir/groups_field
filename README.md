# GroupsField [![Actions Status](https://github.com/Hecatoncheir/groups_field/workflows/check/badge.svg)](https://github.com/Hecatoncheir/groups_field/actions)

Group widgets by some attribute.


## HowTo:

##### Prepare some groups:
```dart
late final Group<String> simpleGroup;
late final Group<Tag> tagsGroup;

@override
void initState() {
  super.initState();

  simpleGroup = Group<String>(
      attribute: "",
      getString: (value) => value,
      onCreate: (text) async => text,
      existFields: [
        "First simple group",
        "Second simple group",
      ],
      fieldBuilder: (value) {
        return Text("Simple group! " + value);
      });

  int _idForCreatedTag = 2;

  final tagsSuggestions = [
    Tag(id: 1, name: "First tag"),
    Tag(id: 2, name: "Second tag"),
  ];

  tagsGroup = Group<Tag>(
    attribute: "#",
    getString: (value) => value.name,
    onCreate: (text) async => Tag(id: _idForCreatedTag++, name: text),
    existFields: [
      Tag(id: 0, name: "0"),
      Tag(id: 1, name: "1"),
    ],
    suggestions: tagsSuggestions,
    fieldBuilder: (value) => Text("#" + value.name),
  );
}


```

##### Add groups to GroupsField widget:
```dart

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Row(
      children: [
        Text("Tags:"),
        Expanded(
          child: GroupsField(
            groups: [
              simpleGroup,
              tagsGroup,
            ],
          ),
        ),
      ],
    ),
  );

```

## TRY:

```
git clone https://github.com/Hecatoncheir/groups_field.git
cd groups_field/example && flutter create .
flutter run
```

### Something like gitlab searchbar:
![Gitlab searchbar preview](/preview/gitlab_search.png)

## TODO:
- [ ] Make navigation by mouse cursor.
- [ ] Make navigation by keyboard arrows.
