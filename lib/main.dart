import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database/database_helper.dart';
import 'model/model.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final textController = TextEditingController();
  int? selectedId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Shopping List'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(
                child: FutureBuilder<List<Grocery>>(
                    future: DatabaseHelper.instance.getGroceries(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Grocery>> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: Text('Loading...'));
                      }
                      return snapshot.data!.isEmpty
                          ? Center(child: Text('No Groceries in List.'))
                          : SizedBox(
                              height: 300,
                              child: ListView(
                                children: snapshot.data!.map((grocery) {
                                  return Center(
                                    child: Card(
                                      color: selectedId == grocery.id
                                          ? Colors.white70
                                          : Colors.white,
                                      child: ListTile(
                                        title: Text(grocery.name),
                                        onTap: () {
                                          setState(() {
                                            if (selectedId == null) {
                                              textController.text =
                                                  grocery.name;
                                              selectedId = grocery.id;
                                            } else {
                                              textController.text = '';
                                              selectedId = null;
                                            }
                                          });
                                        },
                                        onLongPress: () {
                                          setState(() {
                                            DatabaseHelper.instance
                                                .remove(grocery.id!);
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                    }),
              ),
              TextField(
                decoration: new InputDecoration.collapsed(
                  hintText: 'Add your items...',
                ),
                controller: textController,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () async {
            selectedId != null
                ? await DatabaseHelper.instance.update(
                    Grocery(id: selectedId, name: textController.text),
                  )
                : await DatabaseHelper.instance.add(
                    Grocery(name: textController.text),
                  );
            print(textController.text);
            setState(() {
              textController.clear();
              selectedId = null;
            });
          },
        ),
      ),
    );
  }
}
