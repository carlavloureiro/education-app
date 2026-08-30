## Saída do comando "flutter doctor -v"

root@dba1c1db2c8b:/workspace# flutter doctor -v
[✓] Flutter (Channel stable, 3.47.2, on Ubuntu 22.04.5 LTS 6.18.33.2-microsoft-standard-WSL2, locale en_US) [26ms]
    • Flutter version 3.47.2 on channel stable at /opt/flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision d3b14c8769 (4 days ago), 2026-08-26 16:07:51 -0700
    • Engine revision a804b26164
    • Dart version 3.13.2
    • DevTools version 2.60.0
    • Feature flags: enable-web, enable-linux-desktop, enable-macos-desktop, enable-windows-desktop, enable-android, enable-ios, cli-animations, enable-native-assets,
      enable-record-use, enable-swift-package-manager, omit-legacy-version-file, enable-lldb-debugging, enable-uiscene-migration

[!] Android toolchain - develop for Android devices (Android SDK version 34.0.0) [1,904ms]
    • Android SDK at /opt/android-sdk
    • Emulator version unknown
    ✗ Flutter requires Android SDK 36 and the Android BuildTools 28.0.3
      To update the Android SDK visit https://flutter.dev/to/linux-android-setup for detailed instructions.
    • All Android licenses accepted.

[✗] Chrome - develop for the web (Cannot find Chrome executable at google-chrome) [9ms]
    ! Cannot find Chrome. Try setting CHROME_EXECUTABLE to a Chrome executable.

[✗] Linux toolchain - develop for Linux desktop [23ms]
    ✗ clang++ is required for Linux development.
      It is likely available from your distribution (e.g.: apt install clang), or can be downloaded from https://releases.llvm.org/
    ✗ CMake is required for Linux development.
      It is likely available from your distribution (e.g.: apt install cmake), or can be downloaded from https://cmake.org/download/
    ✗ ninja is required for Linux development.
      It is likely available from your distribution (e.g.: apt install ninja-build), or can be downloaded from https://github.com/ninja-build/ninja/releases
    ✗ pkg-config is required for Linux development.
      It is likely available from your distribution (e.g.: apt install pkg-config), or can be downloaded from https://www.freedesktop.org/wiki/Software/pkg-config/

[✓] Connected device (1 available) [57ms]
    • Linux (desktop) • linux • linux-x64 • Ubuntu 22.04.5 LTS 6.18.33.2-microsoft-standard-WSL2

[✓] Network resources [557ms]
    • All expected network resources are available.

! Doctor found issues in 3 categories.

## Estruturação do Repositório Git

### Itens ignorados

- **`.dart_tool/`** — cache interno do Dart/Flutter (metadados de build, resolução de pacotes).
- **`.packages`** — arquivo legado de mapeamento de pacotes, substituído pelo `.dart_tool/package_config.json`.
- **`build/`** — diretório de saída de compilação (inclui os APKs gerados em `build/app/outputs/flutter-apk/`).
- **`.flutter-plugins`** e **`.flutter-plugins-dependencies`** — arquivos de cache de plugins, regenerados a cada `flutter pub get`.
- **`*.lock`** (exceto `pubspec.lock`) — arquivos de bloqueio temporários.
- **Artefatos de IDE** (`.idea/`, `.vscode/`, `*.iml`) — configurações locais específicas de cada desenvolvedor.
- **Arquivos de sistema operacional** (`.DS_Store`).

### Justificativa

Esses diretórios e arquivos são **derivados** — ou seja, podem ser recriados a qualquer momento a partir do `pubspec.yaml` e do código-fonte via `flutter pub get` e `flutter build`. Versioná-los:

- infla desnecessariamente o histórico do repositório;
- gera conflitos de merge irrelevantes entre membros do grupo;
- pode incluir artefatos específicos de cada máquina (caminhos absolutos, versões de SDK locais), quebrando a reprodutibilidade do ambiente descrita no `Dockerfile`.

### Conteúdo do `.gitignore`

```gitignore
# Flutter/Dart
.dart_tool/
.packages
.flutter-plugins
.flutter-plugins-dependencies
build/
*.lock
!pubspec.lock

# Android
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/local.properties

# IDE
.idea/
.vscode/
*.iml

# Sistema
.DS_Store
```
