import 'package:intl/intl.dart';

DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

/// Días de calendario entre dos fechas (inmune a cambios de horario).
int diasEntre(DateTime desde, DateTime hasta) =>
    DateTime.utc(hasta.year, hasta.month, hasta.day)
        .difference(DateTime.utc(desde.year, desde.month, desde.day))
        .inDays;

bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String fechaLarga(DateTime d) =>
    DateFormat("d 'de' MMMM 'de' y", 'es_MX').format(d);

String fechaCorta(DateTime d) => DateFormat('EEE d MMM', 'es_MX').format(d);
