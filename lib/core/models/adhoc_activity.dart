/// Einmalige, nur für einen einzelnen Tageseintrag gespeicherte Tätigkeit.
///
/// Im Gegensatz zu [ActivityTemplate] wird eine [AdhocActivity] nicht als
/// wiederverwendbare Vorlage geführt. Sie existiert ausschließlich am Eintrag,
/// an dem sie angelegt wurde, und ist deshalb zusammen mit dem Tageseintrag
/// persistent.
///
/// Persistiert wird sie ohne eigenen Hive-Typ direkt im [DailyEntryAdapter]
/// als Paar-Liste `List<List<String>>` (`[id, title]`), weil Hive primitive
/// verschachtelte Listen nativ speichert. Dadurch entfällt ein zusätzlicher
/// TypeAdapter.
class AdhocActivity {
  final String id;
  final String title;

  const AdhocActivity({required this.id, required this.title});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdhocActivity && other.id == id && other.title == title);

  @override
  int get hashCode => Object.hash(id, title);

  @override
  String toString() => 'AdhocActivity($id, $title)';
}
