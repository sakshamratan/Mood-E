import 'package:flutter/material.dart';
import 'package:flutter_startup/HOMESCREEN.dart';
import 'package:flutter_startup/next_page.dart';




class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MOOD-E',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),

        debugShowCheckedModeBanner: false);
  }
}
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'HOMESCREEN',
    routes: {'HOMESCREEN':(context) => HomeScreen(),
      'next_page':(context) => MyLogin(), },


  ));

}
