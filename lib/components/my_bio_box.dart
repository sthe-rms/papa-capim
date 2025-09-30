import 'package:flutter/material.dart';
import 'package:papa_capim/themes/theme.dart';

class MyBioBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed; // Função para o botão de editar

  const MyBioBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: themeData().colorScheme.primary, 
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sectionName, style: TextStyle(color: Colors.grey[500])),

              IconButton(
                onPressed: onPressed,
                icon: Icon(Icons.settings, color: Colors.grey[400]),
              ),
            ],
          ),
          Text(text),
        ],
      ),
    );
  }
}
