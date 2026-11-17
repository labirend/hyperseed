import 'package:hive/hive.dart';

part 'energy_level.g.dart';

@HiveType(typeId: 0)
/// Enerji seviyesi: kullanıcının o anki kapasitesini temsil eder.
///
/// Görev filtreleme ve aktivite havuzu önerileri bu seviyeye göre
/// çalışır ([EnergyLevel.low] → kolay görevler, [EnergyLevel.hyperfocus]
/// → derin çalışma görevleri, [EnergyLevel.chaos] → karışık öneriler).
enum EnergyLevel {
  @HiveField(0)
  low,

  @HiveField(1)
  hyperfocus,

  @HiveField(2)
  chaos,
}
