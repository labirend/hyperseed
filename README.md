# HyperSeed

**ADHD odaklı, dopamin temelli üretkenlik motoru.** Flutter ile geliştirilmiş, tamamen çevrimdışı çalışan bir Android uygulaması.

Suçluluk duygusuna yer yok: görevler enerji seviyene göre filtrelenir, gün bittiğinde "başarısızlık" değil teşekkür vardır.

[![CI](https://github.com/labirend/hyperseed/actions/workflows/ci.yml/badge.svg)](https://github.com/labirend/hyperseed/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

## Gizlilik

HyperSeed bir üretkenlik uygulamasından önce bir **yerel uygulamadır**:

- **İnternet izni yoktur.** Uygulama hiçbir sunucuya bağlanmaz.
- **Telemetri, analitik veya crash raporu yoktur.**
- **Tüm veriler cihazda** Hive ile saklanır; görevler, tercihler ve enerji durumu dışarı çıkmaz.
- Kaynak kodu bunu doğrulamanız için açık: ağ çağrısı yok, anahtar yok, gizli uç nokta yok.

Hiçbir hesap oluşturmanız gerekmez, hiçbir veri toplanmaz.

## Özellikler

| Özellik | Açıklama |
|---|---|
| **Enerji Duyarlı Görevler** | Günün başında enerjini seç (Düşük / Hiperfocus / Kaos); görevler buna göre filtrelenir. |
| **Görev Havuzu** | Yerleşik aktivite havuzundan enerjine uygun rastgele görev önerileri. |
| **Karar Çarkı** | Analiz felci yaşayanlar için: çarkı çevir, uygulama senin için seçsin. |
| **Zihin Boşaltma** | Aklına takılanları hızlıca kaydet, sonradan göreve dönüştür. |
| **Aura Zamanlayıcı** | Renkten renge geçen tam ekran görsel odak sayacı. |
| **Vücut Dublajı (Focus Buddy)** | Zamanlayıcı çalışırken ekranda eşlik eden karakter. |
| **Bekleme Modu** | Kısa aralıklar için "çerezlik görev" listesi üretir. |
| **Gün Sonu Ritüeli** | Tamamlanan işler için teşekkür ekranı — kırmızı, suçlayıcı bir özet yok. |
| **Siber Bahçe** | Tamamlanan görevler görsel ilerleme olarak birikir. |

Çift dilli arayüz: **Türkçe** ve **İngilizce**.

## Teknoloji

- **Flutter** (Dart) — Android
- **flutter_riverpod** — durum yönetimi
- **Hive** — yerel, dosya tabanlı depolama (sunucu yok)
- **flutter_animate** — animasyonlar
- **flutter_localizations + ARB** — i18n

### Mimari

Feature-first klasör yapısı:

```
lib/
├── main.dart            # Uygulama girişi, Hive başlatma
├── app.dart             # MaterialApp, dil ve yönlendirme
├── core/                # Tema, sabitler, yardımcılar, l10n
├── models/              # Hive veri modelleri (Task, EnergyLevel)
├── services/            # Veri erişimi (HiveService, TaskService)
├── features/            # Ekran başına izole modül
│   ├── tasks/  energy/  wheel/  aura_timer/
│   ├── focus_buddy/  wait_mode/  completion/
│   └── home/  preferences/  language/
└── shared/              # Yeniden kullanılabilir widget'lar
```

Her `features/` modülü kendi ekranını ve provider'ını içerir; veri erişimi yalnızca `services/` üzerinden yapılır.

## Kurulum

Gereksinimler: [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.12.2`).

```bash
git clone https://github.com/labirend/hyperseed.git
cd hyperseed
flutter pub get
flutter run
```

Test ve kalite kontrolleri:

```bash
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed lib test
```

## Lisans

Bu proje [GNU GPLv3](LICENSE) altında lisanslanmıştır.
