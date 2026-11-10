## Saída do comando "flutter doctor -v" executado no contêiner:

[✓] Flutter (Channel stable, 3.47.2, on Ubuntu 22.04.5 LTS 6.18.33.2-microsoft-standard-WSL2, locale en_US) [23ms]
    • Flutter version 3.47.2 on channel stable at /opt/flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision d3b14c8769 (13 days ago), 2026-08-26 16:07:51 -0700
    • Engine revision a804b26164
    • Dart version 3.13.2
    • DevTools version 2.60.0
    • Feature flags: enable-web, enable-linux-desktop, enable-macos-desktop, enable-windows-desktop, enable-android, enable-ios, cli-animations, enable-native-assets, enable-record-use, enable-swift-package-manager, omit-legacy-version-file, enable-lldb-debugging, enable-uiscene-migration

[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0) [1,166ms]
    • Android SDK at /opt/android-sdk
    • Emulator version unknown
    • Platform android-36, build-tools 34.0.0
    • ANDROID_HOME = /opt/android-sdk
    • ANDROID_SDK_ROOT = /opt/android-sdk
    • Java binary at: /usr/bin/java
      This JDK was found in the system PATH.
      To manually set the JDK path, use: `flutter config --jdk-dir="path/to/jdk"`.
    • Java version OpenJDK Runtime Environment (build 17.0.20+8-1-22.04-Ubuntu)
    • All Android licenses accepted.

[✗] Chrome - develop for the web (Cannot find Chrome executable at google-chrome) [99ms]
    ! Cannot find Chrome. Try setting CHROME_EXECUTABLE to a Chrome executable.

[✗] Linux toolchain - develop for Linux desktop [107ms]
    ✗ clang++ is required for Linux development.
      It is likely available from your distribution (e.g.: apt install clang), or can be downloaded from https://releases.llvm.org/
    ✗ CMake is required for Linux development.
      It is likely available from your distribution (e.g.: apt install cmake), or can be downloaded from https://cmake.org/download/
    ✗ ninja is required for Linux development.
      It is likely available from your distribution (e.g.: apt install ninja-build), or can be downloaded from https://github.com/ninja-build/ninja/releases
    ✗ pkg-config is required for Linux development.
      It is likely available from your distribution (e.g.: apt install pkg-config), or can be downloaded from https://www.freedesktop.org/wiki/Software/pkg-config/

[✓] Connected device (1 available) [138ms]
    • Linux (desktop) • linux • linux-x64 • Ubuntu 22.04.5 LTS 6.18.33.2-microsoft-standard-WSL2

[✓] Network resources [398ms]
    • All expected network resources are available.

! Doctor found issues in 2 categories.

> **AP1B:** a saída acima foi gerada no contêiner Docker do grupo durante o Marco 1 e foi mantida sem alterações.
>
> **AP2B:** [CONFIRMAR: o grupo roda `flutter doctor -v` de novo no ambiente usado para a AP2B (contêiner ou máquina com emulador Android) e cola a saída integral aqui, de preferência mostrando o emulador em "Connected device".]

## Evolução do ambiente na AP2B

- **Novas dependências** (`pubspec.yaml`): `sqflite` (SQLite no dispositivo), `http` (cliente REST, incluindo o `MockClient` de `package:http/testing.dart`) e `shared_preferences` (data/hora da última sincronização). Da AP1B foram mantidos `path` e `sqflite_common_ffi`, este último usado só pelo CLI `bin/main.dart`, que roda com `dart run` (sem Flutter).
- **Pacote renomeado** de `workspace` para `quiz_adaptativo` (os imports dos testes usam `package:quiz_adaptativo/...`).
- **Verificação durante o desenvolvimento** (Windows 11, Flutter 3.47.9 / Dart 3.13.7): `flutter pub get`, `dart format .`, `dart analyze` (sem problemas), `flutter test` e `dart run bin/main.dart`. Os resultados devem ser reproduzidos pelo grupo com esses mesmos comandos.

## Estruturação do Repositório Git

### Estrutura do Projeto

Arquitetura em camadas com padrão Repository (detalhes no `README.md`):

```text
education-app/
├── .devcontainer/devcontainer.json   # Ambiente de desenvolvimento em contêiner (VS Code)
├── .gitignore                        # Exclusão de artefatos de build, caches e arquivos de IDE
├── Dockerfile                        # Contêiner reproduzível (Ubuntu 22.04, JDK 17, Flutter SDK)
├── ENVIRONMENT_REPORT.md             # Este arquivo
├── PROMPTS.md                        # Log dos prompts usados com IA (AP2B)
├── README.md                         # Documentação e Declaração de Uso de IA
├── analysis_options.yaml             # Regras do linter (flutter_lints)
├── pubspec.yaml                      # Dependências e SDK
├── quiz_app.db                       # Banco SQLite do CLI da AP1B (gerado pelo bin/main.dart)
├── bin/main.dart                     # CLI Test Runner da AP1B
├── lib/
│   ├── main.dart                     # Entrada do app Flutter (injeção de dependências)
│   ├── app.dart                      # MaterialApp (Material 3) e roteamento das 10 rotas
│   ├── routes.dart                   # Nomes das 10 rotas
│   ├── models/                       # Domínio em Dart puro (Questao, Partida, enum, exceções)
│   ├── services/                     # Regras da AP1B (GerenciadorQuiz) e helper SQLite do CLI
│   ├── datasources/                  # Interface local, DAO sqflite + prefs, API simulada
│   ├── repositories/                 # QuizRepository (Offline-First)
│   ├── screens/                      # 10 telas
│   └── widgets/                      # Componentes reutilizáveis
└── test/                             # 20 testes de unidade + 5 de widget (+ fakes/)
```

### Itens ignorados

- **`.dart_tool/`**: cache interno do Dart/Flutter (metadados de build, resolução de pacotes).
- **`.packages`**: arquivo legado de mapeamento de pacotes, substituído pelo `.dart_tool/package_config.json`.
- **`build/`**: saída de compilação (inclui os APKs em `build/app/outputs/flutter-apk/`).
- **`.flutter-plugins`** e **`.flutter-plugins-dependencies`**: cache de plugins, regenerado a cada `flutter pub get`.
- **`.pub-cache/`, `.pub/`, `coverage/`, `*.log`, `*.tmp`**: caches de pacotes, relatórios de cobertura e temporários.
- **`*.lock`** (exceto `pubspec.lock`): arquivos de bloqueio temporários.
- **Pods do iOS/macOS** e **artefatos de IDE** (`.idea/`, `.vscode/`, `*.iml`).
- **Arquivos de sistema operacional** (`.DS_Store`, `Thumbs.db`).

### Justificativa

Esses diretórios e arquivos são **derivados**, ou seja, podem ser recriados a qualquer momento a partir do `pubspec.yaml` e do código-fonte via `flutter pub get` e `flutter build`. Versioná-los:

- infla desnecessariamente o histórico do repositório;
- gera conflitos de merge irrelevantes entre membros do grupo;
- pode incluir artefatos específicos de cada máquina (caminhos absolutos, versões de SDK locais), quebrando a reprodutibilidade do ambiente descrita no `Dockerfile`.

### Conteúdo do `.gitignore`

```gitignore
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
coverage/
*.lock
!pubspec.lock

# Temporários e logs
*.log
*.tmp

# Android
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/local.properties

# iOS / macOS
**/ios/Pods/
**/ios/.symlinks/
**/macos/Pods/

# IDE
.idea/
.vscode/
*.iml

# Sistema operacional
.DS_Store
Thumbs.db
```
