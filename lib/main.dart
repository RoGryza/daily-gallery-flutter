import 'package:flutter/material.dart';
import 'service.dart';
import 'models.dart';
import 'components/home.dart';
import 'components/login.dart';
import 'components/posts.dart';

void main() {
  // final service = DelayedService(MockService(), Duration(seconds: 1));
  // final service = ApiService("http://localhost:8000");
  // final service = DelayedService(ApiService("http://localhost:8000"), Duration(seconds: 1));
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp();

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  _MainAppState();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyGallery',
      initialRoute: '/login',
      routes: <String, WidgetBuilder>{
        '/login': (context) => LoginPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.isInitialRoute) {
          return null;
        }
        if (settings.name == '/') {
          Map args = settings.arguments;
          return MaterialPageRoute<void>(
            builder: (context) => HomePage(service: args["service"], user: args["user"]),
            settings: settings,
          );
        }
        if (settings.name.startsWith('/posts')) {
          assert(settings.arguments is Post);
          return MaterialPageRoute<void>(
            builder: (context) => PostPage(post: settings.arguments),
          );
        }
        return null;
      },
    );
  }
}
