import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/auth_provider.dart';
import 'package:bahias_descarga_system/utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      actions: [
        if (actions != null) ...actions!,
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'logout') {
              authProvider.logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            } else if (value == 'profile') {
              Navigator.pushNamed(context, '/profile');
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Perfil'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Cerrar Sesión'),
              ),
            ];
          },
        ),
      ],
    );
  }
}
