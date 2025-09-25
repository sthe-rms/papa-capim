import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:papa_capim/core/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("P E R F I L")),
      /*body: Center(
        child: Text(widget.uid),),*/
    );
  }
}
