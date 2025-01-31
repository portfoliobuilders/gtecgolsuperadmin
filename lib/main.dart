import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';
import 'package:gtecgolsuperadmin/screens/super_admin/login/super_admin_login.dart';
import 'package:gtecgolsuperadmin/superadminsplashscreen.dart';
import 'package:provider/provider.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SuperAdminauthprovider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GTEC LMS',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreen(),
      ),
    );
  }
}

