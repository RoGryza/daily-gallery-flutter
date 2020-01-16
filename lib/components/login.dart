import 'package:flutter/material.dart';
import '../models.dart';
import '../service.dart';
import 'util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();
  
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController(text: "http://localhost:8000");
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  Future<void> _loginFuture = Future.value(null);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: FutureBuilder(
        future: _loginFuture,
        builder: (context, snapshot)
        {
          var enabled = snapshot.connectionState != ConnectionState.waiting;
          return Center(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _hostController,
                    validator: (value) {
                      if (value.isEmpty) return 'Field cannot be empty';
                      if (!value.startsWith('http://') && !value.startsWith('https://')) return 'Not a valid URL';
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'host'),
                    enabled: enabled,
                  ),
                  TextFormField(
                    controller: _usernameController,
                    validator: (value) => value.isEmpty ? 'Field cannot be empty' : null,
                    decoration: InputDecoration(labelText: 'username'),
                    enabled: enabled,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    validator: (value) => value.isEmpty ? 'Field cannot be empty' : null,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'password'),
                    enabled: enabled,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: enabled ? () { _tryLogin(context); } : null,
                      child: enabled ? Text('Login') : CircularProgressIndicator(),
                    ),
                  ),
                  ErrorText(snapshot.error),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _tryLogin(BuildContext context) {
    if (_formKey.currentState.validate()) {
      setState(() {
          _loginFuture = _login(context);
      });
    }
  }
  
  Future<void> _login(BuildContext context) async {
    final service = ApiService(_hostController.text);
    final token = await service.login(_usernameController.text, _passwordController.text);
    await Navigator.of(context).pushReplacementNamed(
      '/',
      arguments: {
        "service": service,
        "user": User(token),
      },
    );
  }
}
