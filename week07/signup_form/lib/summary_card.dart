import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String name;
  final String email;
  final String group;
  final String birthdate;

  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthdate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 4,
            children: [
              ListTile(leading: const Text('Name'), title: Text(name)),
              ListTile(leading: const Text('Email'), title: Text(email)),
              ListTile(leading: const Text('Group'), title: Text(group)),
              ListTile(
                leading: const Text('Birthdate'),
                title: Text(birthdate),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              ListTile(leading: const Text('Name'), title: Text(name)),
              ListTile(leading: const Text('Email'), title: Text(email)),
              ListTile(leading: const Text('Group'), title: Text(group)),
              ListTile(
                leading: const Text('Birthdate'),
                title: Text(birthdate),
              ),
            ],
          );
        }
      },
    );
  }
}
