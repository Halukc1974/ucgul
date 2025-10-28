# Üçgül Forever

Flutter ile geliştirilen Üçgül Forever uygulaması.

## Sistem Gereksinimleri

### Android
- **Minimum:** Android 6.0 (API level 23)
- **Target:** Android 15 (API level 35)
- **Desteklenen mimariler:** arm64-v8a, armeabi-v7a, x86_64

### iOS
- **Minimum:** iOS 12.0+

### Web
- Modern web tarayıcıları (Chrome, Firefox, Safari, Edge)

### Desktop
- Windows 10+
- macOS 10.14+
- Linux (Ubuntu 18.04+)

## Özellikler

- Firebase Authentication
- Cloud Firestore database
- Local notifications
- Secure storage
- Multi-platform support

## Geliştirme

```bash
# Dependencies yükle
flutter pub get

# Debug modda çalıştır
flutter run

# Release APK build et
flutter build apk --release

# Web build et
flutter build web

# Test et
flutter test
```

## Build Gereksinimleri

- Flutter SDK 3.24.5+
- Dart SDK 3.5.4+
- Android SDK 35
- Gradle 8.3+
- Java 17+

## Firebase Konfigürasyonu

Uygulama Firebase kullanıyor. Kendi Firebase projenizi oluşturun ve:

1. `android/app/google-services.json` ekleyin
2. `ios/Runner/GoogleService-Info.plist` ekleyin
3. Web için Firebase config'i `web/index.html`'e ekleyin

## Lisans

Bu proje özel kullanım içindir.
