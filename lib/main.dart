import 'package:Chatlify/provider/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import './provider/user_provider.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('testBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => SocketProvider()),
        ],
        child: MaterialApp(
          title: 'Flutter Chat Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
          ),
          home: LoginScreen(),
        ));
  }
}
