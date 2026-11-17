import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/energy_level.dart';
import '../../services/hive_service.dart';

/// Seçili enerji seviyesini tutar ve kalıcı olarak kaydeder.
///
/// Başlangıç değeri Hive'daki mevcut değerdir; [setEnergy] hem state'i
/// günceller hem ayarlar kutusuna yazar.
class EnergyNotifier extends StateNotifier<EnergyLevel?> {
  EnergyNotifier() : super(HiveService.getCurrentEnergy());

  void setEnergy(EnergyLevel level) {
    state = level;
    HiveService.setCurrentEnergy(level);
  }
}

final energyProvider = StateNotifierProvider<EnergyNotifier, EnergyLevel?>((
  ref,
) {
  return EnergyNotifier();
});
