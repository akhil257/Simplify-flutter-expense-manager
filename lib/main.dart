import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplify/helpers/theme.dart';
import 'package:simplify/screens/mainscreen.dart';
import 'package:simplify/screens/new_auth.dart';
// import 'package:device_preview/device_preview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_performance/firebase_performance.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    // DevicePreview(
    // enabled: true,
    // builder: (context) =>
    App(), // Wrap your app
    // ),
  );
}

class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  // final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    // The default value is 40 MB. The threshold must be set to at least 1 MB,
// and can be set to Settings.CACHE_SIZE_UNLIMITED to disable garbage collection.

FirebaseFirestore.instance.settings =
    Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    return MaterialApp(
      // locale: DevicePreview.locale(context), // Add the locale here
      // builder: DevicePreview.appBuilder,
      builder: (context, widget) => ResponsiveWrapper.builder(
        BouncingScrollWrapper.builder(context, widget!),
        maxWidth: 1200,
        minWidth: 392,
        defaultScale: true,
        backgroundColor: Color.fromRGBO(5, 18, 44, 1),
        breakpoints: [
          ResponsiveBreakpoint.resize(392, name: MOBILE),
        ],
      ),
      debugShowCheckedModeBanner: false,
      theme: lightThemeData(context),
      title: "Simplify",
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: const Color.fromRGBO(5, 18, 44, 1),
            );
          }
          if (!snapshot.hasData) {
            return NewAuth();
          } else {
            return MainScreen(snapshot.data as User);
          }
        },
      ),
    );
  }
}
