import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hyperseed/app.dart';
import 'package:hyperseed/core/constants.dart';
import 'package:hyperseed/features/preferences/preferences_screen.dart';
import 'package:hyperseed/models/energy_level.dart';
import 'package:hyperseed/models/task.dart';
import 'package:hyperseed/shared/splash/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDir;

  setUpAll(() async {
    // Hive'ı proje içindeki geçici bir dizine bağla (path_provider test
    // ortamında mevcut olmadığından HiveService.init() doğrudan kullanılamaz).
    // Önce önceki çalıştırmadan kalma kilit dosyalarını temizle.
    hiveDir = Directory('build/test_hive');
    if (hiveDir.existsSync()) {
      hiveDir.deleteSync(recursive: true);
    }
    hiveDir.createSync(recursive: true);
    Hive.init(hiveDir.path);
    Hive.registerAdapter(EnergyLevelAdapter());
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>(AppConstants.taskBoxName);
    await Hive.openBox(AppConstants.settingsBoxName);
  });

  tearDownAll(() async {
    // Not: Hive.close() test ortamında asıldığından çağrılmıyor; süreç
    // sonlandığında dosya tutucular kendiliğinden serbest kalır. Burada
    // yalnızca geçici Hive dizini temizlenir.
    if (hiveDir.existsSync()) {
      hiveDir.deleteSync(recursive: true);
    }
  });

  testWidgets('uygulama açılır ve dil seçim ekranına geçer', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HyperSeedApp()));
    await tester.pump();

    // Splash ekranı görünür.
    expect(find.byType(SplashScreen), findsOneWidget);

    // Splash animasyonu (1800 ms) tamamlanır.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    // Kayıtlı dil yoksa ilk açılışta dil seçimi önerilir.
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('Türkçe'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    // flutter_animate'ın 0 süreli zamanlayıcılarını temizle.
    await tester.pumpAndSettle();
  });

  testWidgets('Türkçe seçilince tercih ekranına geçilir', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HyperSeedApp()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();

    // Dil seçildikten sonra onboarding tercih ekranı gelir.
    expect(find.text('Choose your language'), findsNothing);
    expect(find.byType(PreferencesScreen), findsOneWidget);
  });
}
