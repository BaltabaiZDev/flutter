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

  final _formKey = GlobalKey<FormState>();

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(content: Text(text));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: TextFormField(
                  controller: _name,
                  validator: (value) {
                    if ((value ?? '').trim().length < 2) {
                      return 'Name is too short';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: TextFormField(
                  controller: _email,
                  validator: (value) {
                    final String email = (value ?? '').trim();

                    if (!email.contains('@') || email.indexOf('.', email.indexOf('@')) <= email.indexOf('@')) {
                      return 'Email looks wrong';
                    }

                    return null;
                  },
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
                child: TextFormField(
                  controller: _password,
                  validator: (value) {
                    if ((value ?? '').trim().length < 8) {
                      return 'Password is too short';
                    }

                    return null;
                  },
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
                child: TextFormField(
                  controller: _confirm,
                  validator: (value) {
                    if ((value ?? '').trim() != _password.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Confirm password'),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            FilledButton(onPressed: () {
                if (_formKey.currentState!.validate()) {
                  showSnackBar('Account created');
                }
              },
              child: Text('Sign up')),
          ],
        ),
      ),
    ),
  );
}
