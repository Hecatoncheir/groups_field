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
    Tag(id: 2, name: "Tag 2"),
    Tag(id: 3, name: "Tag 3"),
  ];

  tagsGroup = Group<Tag>(
    attribute: "#",
    getString: (value) => value.name,
    onCreate: (text) async => Tag(id: _idForCreatedTag++, name: text),
    existFields: [
      Tag(id: 0, name: "Tag 0"),
      Tag(id: 1, name: "Tag 1"),
    ],
    suggestions: tagsSuggestions,
    fieldBuilder: (value) => Text("#" + value.name),
  );
}


```

##### Add groups to GroupsField widget:
```dart

@override
Widget build(BuildContext context) {
  return Scaffold(
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
}

```

---

#### `isScrollable = true` (default):
![With scrollable preview](/preview/with_scrollable.gif)


#### `isScrollable = false`:
![Without scrollable preview](/preview/without_scrollable.gif)

---

### TRY:

```
git clone https://github.com/Hecatoncheir/groups_field.git
cd groups_field/example && flutter create .
flutter run
```




### TODO:
- [ ] Make navigation by mouse cursor.
- [ ] Make navigation by keyboard arrows.
