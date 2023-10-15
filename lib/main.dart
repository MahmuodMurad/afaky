import 'package:afk/create_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String token = "";

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AFAKY'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Login Form:'),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: () {
                  loginAndGetToken(usernameController.text, passwordController.text).then((_) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateScreen(
                          token: token,
                        ),
                      ),
                    );
                    debugPrint("navigate with $token");
                    usernameController.clear();
                    passwordController.clear();
                  });
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loginAndGetToken(String username, String password) async {
    debugPrint("first");
    const loginUrl = "https://back.afakyerp.com/API/User/Login";
    final loginData = {
      "userName": username,
      "password": password,
    };

    try {
      final response = await dio.post(loginUrl, data: loginData);

      if (response.statusCode == 200) {
        final responseJson = response.data;
        setState(() {
          token = responseJson["token"];
        });
        debugPrint(token.toString());
      } else {
        debugPrint("Login failed.");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    debugPrint("Last");
  }
}
