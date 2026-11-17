# Katkıda Bulunma

HyperSeed'e katkı hoş geldin! Bu proje ADHD'li kullanıcılar için üretkenlik deneyimini iyileştirmeyi amaçlar.

## Geliştirme Kurulumu

```bash
git clone https://github.com/labirend/hyperseed.git
cd hyperseed
flutter pub get
flutter run
```

## Kalite Kontrolleri

Her PR'dan önce şu komutların temiz geçmesi gerekir (CI bunları otomatik çalıştırır):

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Katkı Akışı

1. Fork'la ve bir branch aç (`feature/xyz` veya `fix/xyz`).
2. Değişikliklerini yap; mevcut kod stiline uy (`dart format`).
3. Yeni davranış için test ekle.
4. PR aç; değişikliğin neyi ve neden yaptığını açıkça yaz.

## Mimari Notlar

- Kod **feature-first** klasör yapısında: her ekran `lib/features/<ozellik>/` altında kendi provider'ı ile yaşar.
- Veri erişimi yalnızca `lib/services/` üzerinden yapılır; ekranlar doğrudan Hive'a dokunmaz.
- Yeni bağımlılık eklemekten kaçın; uygulama mümkün olduğunca hafif ve çevrimdışı tutulur.
- Metinler `lib/core/l10n/` altındaki ARB dosyalarında iki dilde (tr/en) tutulur; yeni bir metin eklerken ikisini de güncelle.

## Gizlilik İlkeleri

Bu proje **tamamen çevrimdışı** çalışır. Ağ çağrısı, telemetri veya analitik ekleyen PR'lar kabul edilmez.
