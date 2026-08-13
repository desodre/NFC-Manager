import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: const [
      Text(
        'Configurações',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 20),
      ListTile(
        leading: Icon(Icons.android),
        title: Text('Plataforma'),
        subtitle: Text('Android'),
      ),
      ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('Sobre o app'),
        subtitle: Text('NFC Manager'),
      ),
    ],
  );
}
