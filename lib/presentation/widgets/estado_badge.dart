import 'package:flutter/material.dart';

import '../../domain/entities/bien.dart';
import '../theme/app_theme.dart';

class EstadoBadge extends StatelessWidget {
  final String estado;
  final bool compact;

  const EstadoBadge({
    super.key,
    required this.estado,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Color borderColor;
    IconData icon;

    switch (estado) {
      case Bien.estadoDisponible:
        bg = AppTheme.badgeDisponibleBg;
        textColor = AppTheme.badgeDisponibleText;
        borderColor = AppTheme.badgeDisponibleBorder;
        icon = Icons.check_circle_outline_rounded;
        break;
      case Bien.estadoEntregado:
        bg = AppTheme.badgeEntregadoBg;
        textColor = AppTheme.badgeEntregadoText;
        borderColor = AppTheme.badgeEntregadoBorder;
        icon = Icons.assignment_turned_in_outlined;
        break;
      case Bien.estadoEnMantenimiento:
        bg = AppTheme.badgeMantenimientoBg;
        textColor = AppTheme.badgeMantenimientoText;
        borderColor = AppTheme.badgeMantenimientoBorder;
        icon = Icons.build_circle_outlined;
        break;
      case Bien.estadoDadoDeBaja:
        bg = AppTheme.badgeBajaBg;
        textColor = AppTheme.badgeBajaText;
        borderColor = AppTheme.badgeBajaBorder;
        icon = Icons.cancel_outlined;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        borderColor = const Color(0xFFCBD5E1);
        icon = Icons.info_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            estado,
            style: TextStyle(
              color: textColor,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
