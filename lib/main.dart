import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:uuid/uuid.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // The child of this CNP build context will have access to our BreadcrumbProvider
    return ChangeNotifierProvider(
      create: (BuildContext context) => BreadcrumbProvider(),
      child: MaterialApp(
        title: 'Provider course',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        routes: {
          '/new': (context) => const NewBreadCrumbWidget(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void onAddClick(BuildContext context) =>
      Navigator.of(context).pushNamed('/new');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Column(
        children: [
          /* Breadcrumbs */
          Consumer<BreadcrumbProvider>(builder: (context, value, child) {
            return BreadcrumbsWidget(breadcrumbs: value.items);
          }),
          /* Add button */
          TextButton(
              onPressed: () => onAddClick(context),
              child: const Text("Add new bread crumb")),
          /* Reset button */
          TextButton(
              onPressed: () {
                // communication to the provider, read( internally uses Provider.of and listen is false)
                context.read<BreadcrumbProvider>().reset();
              },
              child: const Text("Reset"))
        ],
      ),
    );
  }
}

class Breadcrumb {
  // Properties
  final String uuid;
  bool isActive;
  String name;

  // ye statement kislie use hoti h uuid vali
  Breadcrumb({required this.isActive, required this.name})
      : uuid = const Uuid().v4();

  // Getters
  String get title => name + (isActive ? ' > ' : '');

  // Methods
  void activate() {
    isActive = true;
  }

  // Operator overriding
  @override
  bool operator ==(covariant Breadcrumb other) => uuid == other.uuid;

  @override
  // TODO: implement hashCode
  int get hashCode => uuid.hashCode;
}

class BreadcrumbProvider extends ChangeNotifier {
  // Properties
  final List<Breadcrumb> _items = [];

  // Getters
  UnmodifiableListView<Breadcrumb> get items => UnmodifiableListView(_items);

  // Methods
  void add(Breadcrumb breadcrumb) {
    // Make previous breadcrumbs active
    for (final item in _items) {
      item.activate();
    }
    // Add new breadcrumb
    _items.add(breadcrumb);
    // Notify listener
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

class BreadcrumbsWidget extends StatelessWidget {
  final UnmodifiableListView<Breadcrumb> breadcrumbs;
  const BreadcrumbsWidget({Key? key, required this.breadcrumbs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Read about wrap
    return Wrap(
      children: breadcrumbs.map((breadcrumb) {
        return Text(
          breadcrumb.title,
          style: TextStyle(
              color: breadcrumb.isActive ? Colors.blue : Colors.black),
        );
      }).toList(),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({Key? key}) : super(key: key);

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _nameFieldController;

  @override
  void initState() {
    super.initState();
    _nameFieldController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nameFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new bread crumb"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _nameFieldController,
            decoration: const InputDecoration(
                hintText: "Enter a new bread crumb here..."),
          ),
          TextButton(
              onPressed: () {
                final newBreadcrumb = Breadcrumb(
                    isActive: false, name: _nameFieldController.text);
                context.read<BreadcrumbProvider>().add(newBreadcrumb);
                Navigator.of(context).pop();
              },
              child: const Text("Add"))
        ],
      ),
    );
  }
}
