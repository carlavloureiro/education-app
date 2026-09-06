FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
# 1. Dependências básicas de sistema e Java JDK 17
RUN apt-get update && apt-get install -y \
 curl git unzip xz-utils zip openjdk-17-jdk \
 && rm -rf /var/lib/apt/lists/*
# 2. Configuração de variáveis de ambiente
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$PATH:$FLUTTER_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
# 3. Download e instalação do Android cmdline-tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
 curl -o /tmp/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
 unzip /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
 mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
 rm /tmp/cmdline-tools.zip
# 4. Aceite de licenças e instalação de Build-tools
RUN yes | sdkmanager --licenses && \
 sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
# 5. Instalação do Flutter SDK estável
RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME} && \
 flutter doctor -v
WORKDIR /workspace
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get