// Fonte: https://www.kindacode.com/article/flutter-firestore-database/

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'person.dart';
import 'products.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Web Service Exemplos',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Multi Page Application"),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text('Pessoas'),
              trailing: Icon(Icons.keyboard_arrow_right_sharp),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Person(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Produtos'),
              trailing: Icon(Icons.keyboard_arrow_right_sharp),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Products(),
                  ),
                );
              },
            ),
          ],
        ));
  }
}