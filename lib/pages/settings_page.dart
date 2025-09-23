import 'package:flutter/material.dart';
import 'package:ok/components/my_settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text("C O N F I G U R A Ç Õ E S"), foregroundColor: Theme.of(context).colorScheme.primary,),
      body: Column(
        children: [
        
        ],


      ),);

  }
}