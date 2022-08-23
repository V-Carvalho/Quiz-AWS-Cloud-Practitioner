import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:awsquiz/src/screens/Home.dart';
import 'package:awsquiz/src/helpers/Constants.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: myDarkBlueColor,
    ),
  );

  Wakelock.enable();

  // StartingUnityAdsSDK
  await UnityAds.init(
    testMode: true, // TODO: ever false
    gameId: '4889883',
    onComplete:() {
      print('UNITY ADS - Initialization Complete');
    },
    onFailed: (error, message) {
      print('Initialization Failed: $error $message');
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: myDarkBlueColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: myDarkBlueColor),
      ),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}