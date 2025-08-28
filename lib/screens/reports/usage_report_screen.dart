import 'package:flutter/material.dart';
import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
import 'package:bahias_descarga_system/utils/constants.dart';

class UsageReportScreen extends StatelessWidget {
  const UsageReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Reportes'),
      body: const Center(
        child: Text('Pantalla de Reportes - En desarrollo'),
      ),
    );
  }
}
