# Syathiby App

Enchance and customized version of Syathiby Vendor App [https://github.com/creatorb/flutter-syathiby-vendor](https://github.com/creatorb/flutter-syathiby-vendor)

Ma'had Tahfizh al-Qur'an al-Imam as-Syathiby, cileungsi, bogor, Indonesia.

#pondok #jabodetabek #ma'had #tahfizh #al-Qur'an #sunnah #manhaj #salaf #cileungsi #bogor #indonesia #syathiby

## Branches

- [main](https://github.com/creatorb/flutter_syathiby)

This original version of Syathiby App built by IT Sragen, we will still support this branch with latest requirements and keep the original features, InshaAllah.

- [dev](https://github.com/creatorb/flutter_syathiby/tree/dev)

This version of Syathiby App built by IT Syathiby, we will update this branch with latest requirements and add new features, InshaAllah.

## Development

Build source code :

```sh
flutter clean ; flutter pub get ; flutter packages pub run build_runner build
```

Rebuild model and url env

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

Rename App and Package name

```sh
dart run flutter_application_id:main -f flutter_application_id.yaml
```

(Optional) Rename app name :

```sh
flutter pub global activate rename

dart pub global run rename:rename setAppName --targets ios,android --value "Syathiby"
```

Change icon :

```sh
#setup
dart run flutter_launcher_icons:generate --override
#generate
dart run flutter_launcher_icons
```

Change splash screen :

```sh
dart run flutter_native_splash:create
```

Build apk :

```sh
fvm flutter clean ; fvm flutter pub get ; fvm flutter pub run build_runner build --delete-conflicting-outputs ; fvm flutter build apk --release
```

Build AAB :

```sh
fvm flutter clean ; fvm flutter pub get ; fvm flutter pub run build_runner build --delete-conflicting-outputs ; fvm flutter build appbundle --release
```

Build WEB (build/web):

```sh
fvm flutter clean ; fvm flutter pub get ; fvm flutter build web --release
```

```sh
#.htaccess untuk web version
RewriteEngine On
# Jika file atau folder yang diminta tidak ada secara fisik
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
# Arahkan semua request ke index.html
RewriteRule ^ index.html [L]
```

Run app :

```sh
flutter clean ; flutter pub get ; flutter run -d 127.0.0.1:5555 -v
```

**Power Dev**

```sh
fvm flutter clean ; fvm flutter pub get ; fvm flutter pub run build_runner build --delete-conflicting-outputs ; fvm flutter run -d 127.0.0.1:5555 -v
```

## Keystore

**Debug**

```sh
keytool -genkeypair -v `
  -keystore debug.keystore `
  -alias androiddebugkey `
  -keyalg RSA -keysize 2048 `
  -validity 10000 `
  -storetype pkcs12 `
  -storepass android `
  -keypass android `
  -dname "CN=https://github.com/CreatorB, O=Freelance Fullstack Developer, C=ID"
```

**Release**

```sh
keytool -list -v -keystore .\keystore\creatorbe-bundle.jks -alias creatorbe -storepass bismillah -keypass bismillah
```

## License

Copyright IT Syathiby 2024

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.