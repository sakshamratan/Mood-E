import 'package:flutter/material.dart';
import 'package:flutter_startup/HOMESCREEN.dart';
import 'package:flutter_startup/home_page.dart';
import 'package:flutter_startup/takephoto_page.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  runApp(const MyApp());
  void _launchSpotifyPlaylist(String playlistUri) async {
    String url = 'spotify:playlist:$playlistUri';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}

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
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false);
  }
}
