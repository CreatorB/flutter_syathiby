# Syathiby App

Handover existing vendor flutter app for managing the system at Ma'had Tahfizh al-Qur'an al-Imam as-Syathiby, cileungsi, bogor, Indonesia.

#pondok #jabodetabek #ma'had #tahfizh #al-Qur'an #sunnah #manhaj #salaf #cileungsi #bogor #indonesia #syathiby

## Development

Build source code :

```sh
flutter clean ; flutter pub get ; flutter packages pub run build_runner build
```

Rebuild model and url env

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

Rename App and Package name (change build.gradle to build.gradle.kts) :

```sh
dart run flutter_application_id:main -f flutter_application_id.yaml
```

Rename app name :

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
flutter clean ; flutter pub get ; flutter build apk --release
```

Run app :

```sh
flutter clean ; flutter pub get ; flutter run -d 127.0.0.1:5555 -v
```

Clean repository :

```sh
#linux
find . -name '*.g.dart' -type f -delete
find . -name '*.freezed.dart' -type f -delete
find . -name '*.riverpod.dart' -type f -delete

#windows
Get-ChildItem -Path . -Recurse -Include *.g.dart | Remove-Item -Force
Get-ChildItem -Path . -Recurse -Include *.freezed.dart | Remove-Item -Force
Get-ChildItem -Path . -Recurse -Include *.riverpod.dart | Remove-Item -Force
```

## License

Copyright IT Sragen & IT Syathiby 2024

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
