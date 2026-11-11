import 'package:flutter/material.dart';

import '../../core/fechas.dart';
import '../../data/models/tarea.dart';

/// Tarjeta con barra de color según urgencia:
/// rojo = vence hoy, naranja = próximos días, verde = hay tiempo, gris = entregada.
class TareaCard extends StatelessWidget {
  const TareaCard({
    super.key,
    required this.tarea,
    required this.onTap,
    required this.onAlternar,
    required this.onEliminar,
  });

  final Tarea tarea;
  final VoidCallback onTap;
  final VoidCallback onAlternar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final urgencia = tarea.urgencia;
    final tachado = tarea.entregada
        ? TextDecoration.lineThrough
        : TextDecoration.none;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: urgencia.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarea.titulo,
                        style: tema.textTheme.titleMedium
                            ?.copyWith(decoration: tachado),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CircleAvatar(
                              radius: 5,
                              backgroundColor: Color(tarea.materiaColor)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(tarea.materiaNombre,
                                style: tema.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (tarea.recordatorio && !tarea.entregada) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.notifications_active_outlined,
                                size: 14, color: tema.colorScheme.primary),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${tarea.textoVencimiento} · ${fechaCorta(tarea.fechaEntrega)}'
                        ' · Prioridad ${tarea.textoPrioridad.toLowerCase()}',
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: urgencia.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Checkbox(
                value: tarea.entregada,
                onChanged: (_) => onAlternar(),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'editar') onTap();
                  if (v == 'eliminar') onEliminar();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'editar', child: Text('Editar')),
                  PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
