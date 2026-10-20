import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),

    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(content: Text(text));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void validate() {
    if (_name.text.length < 2) {
      showSnackBar('Name is too short');
    } else if (!_email.text.contains('@')) {
      showSnackBar('Email looks wrong');
    } else if (_password.text.length < 8) {
      showSnackBar('Password is too short');
    } else if (_password.text != _confirm.text) {
      showSnackBar('Passwords do not match');
    } else {
      showSnackBar('Account created');
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),

    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@kbtu.kz',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: _password.text.isEmpty
                      ? 'At least 8 characters'
                      : '${_password.text.length} of 8+',
                ),
                onChanged: (String value) {
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: _confirm,
                decoration: const InputDecoration(labelText: 'Confirm password'),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          FilledButton(onPressed: validate, child: Text('Sign up')),
        ],
      ),
    ),
  );
}
