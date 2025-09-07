import 'package:flutter/material.dart';
import 'package:bahias_descarga_system/models/bahia_model.dart';
import 'package:bahias_descarga_system/utils/constants.dart';

class BahiaCard extends StatelessWidget {
  final Bahia bahia;
  final VoidCallback? onTap;

  const BahiaCard({Key? key, required this.bahia, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: bahia.colorEstado.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bahía ${bahia.numero}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bahia.nombreTipo,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                bahia.nombreEstado,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              if (bahia.reservadaPor != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Reservada por: ${bahia.reservadaPor}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
