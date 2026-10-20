import 'package:flutter/material.dart';

import 'summary_card.dart';

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
  final _birth = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();

  String? _group;
  bool _agreed = false;

  bool _done = false;

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(content: Text(text));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      showSnackBar('Account created');

      setState(() => _done = true);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _email,
      _password,
      _confirm,
      _birth,
      _emailFocusNode,
    ]) {
      c.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: _done ? const Text('Summary') : const Text('Sign up'),
    ),
    body: (_done)
        ? Column(
            children: [
              SummaryCard(
                name: _name.text,
                email: _email.text,
                group: _group ?? '',
                birthdate: _birth.text,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    for (final controller in [
                      _name,
                      _email,
                      _password,
                      _confirm,
                      _birth,
                    ]) {
                      controller.clear();
                    }

                    _group = null;
                    _agreed = false;
                    _done = false;
                  });
                },
                child: const Text('Start over'),
              ),
            ],
          )
        : SingleChildScrollView(
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
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _email,
                        validator: (value) {
                          final String email = (value ?? '').trim();

                          if (!email.contains('@') ||
                              email.indexOf('.', email.indexOf('@')) <=
                                  email.indexOf('@')) {
                            return 'Email looks wrong';
                          }

                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        focusNode: _emailFocusNode,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'name@kbtu.kz',
                        ),
                      ),
                    ),
                  ),
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
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          helperText: _password.text.isEmpty
                              ? 'At least 8 characters'
                              : '${_password.text.length} of 8+',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _confirm,
                        validator: (value) {
                          if ((value ?? '').trim() != _password.text.trim()) {
                            return 'Passwords do not match';
                          }

                          return null;
                        },
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => submitForm(),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: DropdownButtonFormField<String>(
                        items: [
                          for (String group in groups)
                            DropdownMenuItem<String>(
                              value: group,
                              child: Text(group),
                            ),
                        ],
                        validator: (group) =>
                            group == null ? 'Choose a group' : null,
                        onChanged: (value) => setState(() {
                          _group = value;
                        }),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextFormField(
                        readOnly: true,
                        controller: _birth,
                        validator: (value) =>
                            value == '' ? 'Select your birth date' : null,
                        decoration: const InputDecoration(
                          labelText: 'Birthdate',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          DateTime? birthdate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );

                          if (!mounted || birthdate == null) return;

                          setState(() {
                            _birth.text =
                                '${birthdate.day.toString().padLeft(2, '0')}.${birthdate.month.toString().padLeft(2, '0')}.${birthdate.year.toString().padLeft(4, '0')}';
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: CheckboxListTile(
                      title: const Text('I agree to the rules'),
                      value: _agreed,
                      onChanged: (value) {
                        setState(() {
                          _agreed = value ?? false;
                        });
                      },
                    ),
                  ),
                  FilledButton(
                    onPressed: _agreed ? submitForm : null,
                    child: Text('Sign up'),
                  ),
                ],
              ),
            ),
          ),
  );
}
