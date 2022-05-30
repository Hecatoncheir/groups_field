import 'package:flutter/material.dart';
import 'package:groups_field/groups_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class Tag {
  int id;
  String name;

  Tag({
    required this.id,
    required this.name,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required this.title,
    Key? key,
  }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: 2,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Color(0xFF9eabc0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 3,
                    right: 3,
                    bottom: 3,
                    left: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  child: Text(
                    "Simple group! ",
                    style: TextStyle(
                      color: Color(0xFFffffff),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Color(0xFFffffff),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
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
      suggestionBuilder: (tag) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Color(0xFF53b9ea),
          ),
          child: Text(
            tag.name,
            style: TextStyle(
              color: Color(0xFFffffff),
            ),
          ),
        );
      },
      fieldBuilder: (value) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 3,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Color(0xFF53b9ea),
          ),
          child: Text(
            "#" + value.name,
            style: TextStyle(
              color: Color(0xFFffffff),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 3,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.lightBlue,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 12),
                  child: const Text(
                    "Search:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GroupsField(
                    isScrollable: true,
                    groups: [
                      simpleGroup,
                      tagsGroup,
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 12),
                  child: const Text(
                    "Search:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GroupsField(
                    isScrollable: false,
                    groups: [
                      simpleGroup,
                      tagsGroup,
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 12),
                  child: const Text(
                    "Search:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GroupsField(
                    isScrollable: false,
                    textFieldDecoration: InputDecoration(
                      hintText: 'Some hint?',
                    ),
                    groups: [
                      simpleGroup,
                      tagsGroup,
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
