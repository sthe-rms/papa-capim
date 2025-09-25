import 'package:flutter/material.dart';

class MyBioBox extends StatelessWidget {
  final String text;
  const MyBioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,

        borderRadius: BorderRadius.circular(8),
      ),

      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 25),

      child: Text(text),
    );
  }
}
