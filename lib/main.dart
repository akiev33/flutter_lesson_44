import 'package:flutter/material.dart';
import 'package:flutter_lesson_44/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final SharedPreferences prefs;
  List<String> names = [];
  final controller = TextEditingController();

  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    names = prefs.getStringList(AppConstants.names) ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Save account'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    names.add(controller.text);
                    prefs.setStringList(AppConstants.names, names);
                    controller.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('saved in data')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (contex) => SecondScreen(
                onTap: (name) {
                  names.removeWhere((element) => element == name);
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key, required this.onTap});

  final Function(String name) onTap;

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  late final SharedPreferences prefs;
  List<String> names = [];

  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    names = prefs.getStringList(AppConstants.names) ?? [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                names.clear();
                prefs.remove(AppConstants.names);
                setState(() {});
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Dismissible(
          key: UniqueKey(),
          onDismissed: (_) {
            widget.onTap(names[index]);
            names.removeWhere(
              (element) => element == names[index],
            );
            prefs.setStringList(AppConstants.names, names);
            setState(() {});
          },
          child: Column(
            children: [
              Text(
                names[index],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),
              const Divider(
                color: Colors.black,
                thickness: 1.5,
                height: 32,
              ),
            ],
          ),
        ),
        itemCount: names.length,
      ),
    );
  }
}
