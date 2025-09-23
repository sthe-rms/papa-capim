import 'package:flutter/material.dart';

class MyDrawerTile extends StatelessWidget {
  const MyDrawerTile({super.key});
  
  @override
  Widget build(BuildContext context){
    return ListTile(
      title: Text(
        'Home',
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
      ),
      leading: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
      onTap: () {},
    );
  }
}