
const List<String> italianMonthsCapitalized = [
  'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
  'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
];

const List<String> italianMonthsLower = [
  'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
  'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
];

/// Es. "Luglio 2026"
String monthYearLabel(DateTime d) => '${italianMonthsCapitalized[d.month - 1]} ${d.year}';

/// Es. "6 luglio 2026"
String fullDateLabel(DateTime d) => '${d.day} ${italianMonthsLower[d.month - 1]} ${d.year}';
