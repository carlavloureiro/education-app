FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. Dependências básicas de sistema e Java JDK 17
RUN apt-get update && apt-get install -y \
 curl git unzip xz-utils zip openjdk-17-jdk \
 && rm -rf /var/lib/apt/lists/*

# 2. Configuração de variáveis de ambiente (Adicionado ANDROID_HOME e platform-tools no PATH)
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV ANDROID_HOME="/opt/android-sdk"
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$PATH:$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

# 3. Download e instalação do Android cmdline-tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
 curl -o /tmp/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
 unzip /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
 mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
 rm /tmp/cmdline-tools.zip

# 4. Aceite de licenças e instalação de Build-tools
RUN yes | sdkmanager --licenses && \
 sdkmanager "platform-tools" "platforms;android-36" "build-tools;34.0.0" "build-tools;28.0.3"
 
# 5. Instalação do Flutter SDK e configuração (Adicionado flutter config)
RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME} && \
 flutter config --android-sdk ${ANDROID_HOME} && \
 yes | flutter doctor --android-licenses && \
 flutter doctor -v

WORKDIR /workspace
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get