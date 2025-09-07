import 'package:flutter/material.dart';
import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
import 'package:bahias_descarga_system/utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Perfil'),
      body: const Center(
        child: Text('Pantalla de Perfil - En desarrollo'),
      ),
    );
  }
}
