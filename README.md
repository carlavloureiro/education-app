# Quiz Adaptativo

Aplicativo mobile de educação com quiz adaptativo, desenvolvido no Projeto Prático Integrado (PBL) da disciplina de Computação Móvel. O Marco 1 (AP1B) implementou o domínio em Dart puro; o Marco 2 (AP2B) evoluiu esse domínio para um app Flutter **Offline-First**.

**Grupo:** 8
**Professor:** Edgard da Cunha Pontes
**Curso:** Sistemas de Informação | Período: 8°

## Integrantes

- Carla Vazzoler Loureiro
- Gabriel Ramos Maciel
- Luis Gustavo de Jesus Ribeiro Pimentel
- Luiz Henrique Lesquives Sartório
- Vinicio da Silva Mendes

## Tema

**Tema 08: Aplicativo de Educação e Quiz Adaptativo**

## Descrição

### Marco 2 (AP2B): app Flutter Offline-First

O app baixa pacotes de questões de uma API REST (simulada) para o SQLite do aparelho. A partir daí é possível jogar sem internet: as partidas ficam salvas localmente como *pendentes* e o ranking é sincronizado quando a conexão volta. O banco de questões também pode ser mantido no próprio app (cadastrar, editar, excluir), com o mesmo mecanismo de pendência e sincronização.

- Duas entidades relacionadas persistidas em SQLite: **`Questao`** (tabela `questoes`) e **`Partida`** (tabela `partidas`, ligada às questões pela categoria jogada).
- A UI lê sempre do banco local (fonte única da verdade), inclusive em modo avião.
- Toda escrita grava primeiro no SQLite com `sincronizado = 0` e só passa a `1` quando a API responde 200/201.
- A pontuação e a proficiência continuam vindo das regras da AP1B (`GerenciadorQuiz`).

### Marco 1 (AP1B): módulo de domínio em Dart puro

O **Quiz Adaptativo** é uma solução de tecnologia educacional voltada para dispositivos móveis, desenvolvida como parte do Marco 1 do Projeto Prático Integrado (PBL) da disciplina de Computação Móvel do curso de Sistemas de Informação da Faculdade Multivix.
O foco central do primeiro marco foi o projeto e a implementação do **Módulo Central de Domínio e Lógica de Negócios** da aplicação em Dart puro, estruturado em camadas e desacoplado da interface gráfica. Esse módulo continua em uso no app da AP2B.

#### Objetivos e Funcionalidades Principais (AP1B)
* **Gerenciamento de Questões por Dificuldade:** banco de questões categorizado por níveis de complexidade (`facil`, `medio` e `dificil`) com enum fortemente tipado.
* **Validação Polimórfica e Herança:** contrato base abstrato (`Questao`) com especialização para múltipla escolha e verdadeiro/falso.
* **Variedade de Construtores:** construtor gerativo com repasse via `super`, construtor nomeado (`.verdadeiroFalso`) e `factory .fromMap` com validação defensiva.
* **Auditoria Pedagógica com Mixins:** log de auditoria com timestamp ISO-8601 para cada resposta (`LogAuditoriaMixin`).
* **Processamento Funcional de Dados:** `.where()`, `.fold()`, `.every()`, `.any()`, spread (`...`/`...?`), collection-if e collection-for.
* **Classificação de Proficiência Adaptativa:** enquadramento em *Iniciante*, *Intermediário* e *Avançado*.
* **Validação Defensiva e Casos de Borda:** exceção de negócio `QuizException` com `try-on-catch-finally` e `rethrow`, em *Sound Null Safety*.

## Modelagem (Diagrama de Classes da AP1B)
<img width="896" height="1200" alt="diagrama_classes_uml" src="https://github.com/user-attachments/assets/61202f35-6238-4c98-9d26-65e8a3b0be66" />

Na AP2B o modelo ganhou: `categoria` e `sincronizado` em `Questao`; `toMap()`, `fromMap()`, `toJson()` e `copyWith()` em `QuestaoMultiplaEscolha`; a nova entidade `Partida`; e `SincronizacaoException extends QuizException`.

## Arquitetura Offline-First

```text
+----------------------------------------------------------------+
|                 CAMADA DE APRESENTAÇÃO (UI)                    |
|  lib/screens + lib/widgets (StatefulWidget, FutureBuilder,     |
|  setState, Form). Não faz HTTP nem SQL.                        |
+-------------------------------+--------------------------------+
                                | Future (async/await)
                                v
+----------------------------------------------------------------+
|                    CAMADA DE REPOSITÓRIO                       |
|   QuizRepository (lib/repositories): orquestração e fallback   |
+---------------+--------------------------------+---------------+
                |                                |
  1. Sempre: leitura e escrita         2. Quando online: envio de
     locais                               pendências e download
                v                                v
+-------------------------------+  +-----------------------------+
| FONTE LOCAL                   |  | FONTE REMOTA (simulada)     |
| QuizLocalDatasource           |  | http.Client = MockClient    |
|  └ QuizDao: SQLite (sqflite)  |  |  └ MockApi (JSON, 300 ms,   |
|    + SharedPreferences        |  |    Switch "Simular offline")|
+-------------------------------+  +-----------------------------+
```

**Fluxo:**

1. **Leitura imediata local:** todas as telas leem via `QuizRepository`, que consulta só o SQLite. O app abre e funciona em modo avião.
2. **Escrita resiliente:** cadastrar/editar questão e salvar partida gravam primeiro no SQLite com `sincronizado = 0`. A UI é atualizada na hora.
3. **Sincronização:** o repositório tenta a requisição HTTP (timeout de 5 s). Com status 200/201, marca `sincronizado = 1`. Em `SocketException`, `TimeoutException` ou status de erro, o registro continua pendente sem travar o usuário. A tela **Diagnóstico** reenvia as pendências ("Sincronizar agora") e grava a data da última sincronização no `shared_preferences`.

**Desacoplamento:** as telas recebem o `QuizRepository` por construtor. O repositório recebe a interface `QuizLocalDatasource` e um `http.Client`, o que permite testá-lo com `FakeLocalDatasource` (memória) e `MockClient`, sem emulador.

## API utilizada (serviço mock)

O grupo optou por **não usar uma API pública**. A fonte remota é um `MockClient` (`package:http/testing.dart`) definido em `lib/datasources/mock_api.dart` e injetado no app como `http.Client`. O código de rede do repositório (`get`/`post`/`put`/`delete`, `jsonEncode`/`jsonDecode`, `statusCode`, `.timeout`) é o mesmo que seria usado com uma API real; basta trocar o cliente e a URL.

URL base (constante `QuizRepository.urlPadrao`): `https://api.quiz-adaptativo.mock/v1`

| Método | Endpoint | Resposta do mock | Uso no app |
|---|---|---|---|
| GET | `/questoes` | 200 + JSON com 10 questões | Botão "Baixar pacote de questões" |
| POST | `/partidas` | 201 (eco do corpo) | Envio de partida para o ranking |
| PUT | `/questoes/{id}` | 200 | Envio de questão criada/editada (idempotente) |
| DELETE | `/questoes/{id}` | 200 | Exclusão de questão (melhor esforço) |
| qualquer | com "Simular offline" ligado | lança `SocketException` | Simula queda de rede |

Formato de cada questão no GET:

```json
{"id": "API-01", "enunciado": "Qual linguagem é utilizada pelo Flutter?",
 "alternativas": ["Kotlin", "Dart", "Swift", "JavaScript"], "correta": 1,
 "dificuldade": "facil", "categoria": "Flutter"}
```

## Telas e rotas (10 rotas nomeadas)

Definidas em `lib/routes.dart` e montadas em `lib/app.dart` (`onGenerateRoute`). A tela só abre se o argumento tiver o tipo esperado (`when args is Partida`, por exemplo); caso contrário, aparece uma tela de "rota inválida".

| # | Rota | Tela | Argumento |
|---|---|---|---|
| 1 | `/` | Home/Dashboard (totais, Jogar, Baixar pacote) | nenhum |
| 2 | `/questoes` | Lista de questões (`ListView.builder`, `Dismissible`) | nenhum |
| 3 | `/questoes/form` | Formulário de cadastro/edição (`Form` validado) | `QuestaoMultiplaEscolha?` |
| 4 | `/questoes/detalhes` | Detalhes da questão | `QuestaoMultiplaEscolha` |
| 5 | `/selecao` | Nome do jogador, categoria e dificuldade | nenhum |
| 6 | `/jogar` | Jogar quiz (feedback por alternativa) | `JogoArgs` |
| 7 | `/resultado` | Resultado da partida | `Partida` |
| 8 | `/ranking` | Ranking (ícone sincronizado/pendente) | nenhum |
| 9 | `/ranking/detalhes` | Detalhes da partida | `Partida` |
| 10 | `/diagnostico` | Diagnóstico: pendências, última sincronização, "Sincronizar agora", Switch "Simular offline" | nenhum |

Ícones: `Icons.cloud_done` (verde) = sincronizado; `Icons.cloud_off` (laranja) = pendente. Sucesso e erro de rede aparecem em `SnackBar`.

## Tecnologias

- **Framework/linguagem:** Flutter (Material Design 3) e Dart 3
- **Estado:** `StatefulWidget` + `FutureBuilder`/`setState` (sem Bloc, Provider ou Riverpod)
- **Persistência local:** `sqflite` (SQLite) e `shared_preferences` (data da última sincronização)
- **Rede:** `http` (+ `MockClient` como API simulada)
- **CLI da AP1B:** `sqflite_common_ffi` (SQLite em `dart run`, sem Flutter)
- **Testes:** `flutter_test`

## Como Rodar o Projeto

### Pré-requisitos

* **Git** para clonar o repositório.
* **Flutter SDK 3.x** (Dart 3.12+) e um emulador/dispositivo Android para rodar o app.
* Opcional: **Docker** para rodar o CLI e os testes em contêiner.

### Comandos

```bash
git clone https://github.com/carlavloureiro/education-app.git
cd education-app

flutter pub get            # instala as dependências
flutter run                # executa o app no emulador/dispositivo
flutter test               # executa os 20 testes de unidade + 5 de widget
dart run bin/main.dart     # executa o CLI de demonstração da AP1B
```

### Como demonstrar o modo offline

1. Abra o app e toque em **Baixar pacote de questões** (10 questões vão para o SQLite).
2. Vá em **Diagnóstico de sincronização** e ligue **Simular offline** (ou ative o modo avião; com o mock, o Switch é o que simula a queda).
3. Jogue uma partida: o resultado aparece como pendente (`cloud_off`) no Resultado e no Ranking.
4. No Diagnóstico, **Sincronizar agora** mostra erro de rede no SnackBar e a pendência continua.
5. Desligue **Simular offline** e toque em **Sincronizar agora**: a partida passa a `cloud_done` e a data da última sincronização é atualizada.

### Execução via Docker (CLI e testes)

```bash
docker build -t quiz-adaptativo .

# PowerShell (Windows)
docker run --rm -v ${PWD}:/workspace -w /workspace quiz-adaptativo dart run bin/main.dart
docker run --rm -v ${PWD}:/workspace -w /workspace quiz-adaptativo flutter test

# Bash (Linux/macOS)
docker run --rm -v $(pwd):/workspace -w /workspace quiz-adaptativo dart run bin/main.dart

# CMD (Windows)
docker run --rm -v "%cd%":/workspace -w /workspace quiz-adaptativo dart run bin/main.dart
```

## Testes automatizados

| Arquivo | Tipo | O que cobre |
|---|---|---|
| `test/models_test.dart` | 8 de unidade | `toMap`/`fromMap`, `toJson`, `copyWith`, bool ↔ 0/1, valores padrão, `QuizException` para dados inválidos |
| `test/regras_quiz_test.dart` | 6 de unidade | Regras da AP1B: pontuação, mixin, `.where`/`.fold`, setter validado, construtor nomeado, proficiência, `rethrow` |
| `test/repository_test.dart` | 6 de unidade | Fallback do repositório com `FakeLocalDatasource` + `MockClient`: erro 500, `SocketException`, 201, envio só de pendentes, download sem duplicar, timeout |
| `test/widget_test.dart` | 5 de widget | Lista renderiza itens, formulário com campos vazios, formulário válido, ícone pendente vs sincronizado, toque em alternativa mostra feedback |
| `test/fakes/fake_local_datasource.dart` | apoio | Fonte local em memória (não é teste) |

O resultado deve ser conferido com `flutter test`.

## Estrutura do Projeto

```text
education-app/
├── .devcontainer/devcontainer.json  # Ambiente de desenvolvimento em contêiner (VS Code)
├── .gitignore
├── Dockerfile                       # Contêiner reproduzível (Ubuntu 22.04, JDK 17, Flutter SDK)
├── ENVIRONMENT_REPORT.md            # flutter doctor -v e organização do Git
├── PROMPTS.md                       # Log dos prompts de IA da AP2B
├── README.md
├── analysis_options.yaml
├── pubspec.yaml
├── bin/
│   └── main.dart                    # CLI Test Runner da AP1B (dart run bin/main.dart)
├── lib/
│   ├── main.dart                    # Entrada do app: cria MockApi, QuizDao e QuizRepository
│   ├── app.dart                     # MaterialApp (Material 3) + onGenerateRoute
│   ├── routes.dart                  # As 10 rotas nomeadas
│   ├── models/
│   │   ├── nivel_dificuldade.dart   # Enum com rótulo, pontos base e parse()
│   │   ├── questao.dart             # Questao (abstrata), QuestaoMultiplaEscolha, mixin, exceções
│   │   └── partida.dart             # Partida (ranking)
│   ├── services/
│   │   ├── gerenciador_quiz.dart    # Regras da AP1B (pontuação, coleções, proficiência)
│   │   └── database_helper.dart     # SQLite do CLI (sqflite_common_ffi)
│   ├── datasources/
│   │   ├── quiz_local_datasource.dart  # Interface abstrata da fonte local
│   │   ├── quiz_dao.dart               # DAO sqflite (CRUD) + SharedPreferences
│   │   └── mock_api.dart               # API REST simulada (MockClient)
│   ├── repositories/
│   │   └── quiz_repository.dart     # Orquestração Offline-First e tratamento de exceções
│   ├── screens/                     # 10 telas (uma por rota)
│   └── widgets/
│       ├── sync_status_icon.dart    # Ícone sincronizado/pendente
│       ├── baixar_pacote_button.dart # Botão de download (Home e Diagnóstico)
│       └── ui_helpers.dart          # SnackBar e formatação de data
└── test/                            # 20 testes de unidade + 5 de widget
```

## Onde está cada requisito

**AP1B (preservada):**

| Requisito | Onde |
|---|---|
| Classe abstrata com contrato | `Questao` (`responder()`), `lib/models/questao.dart` |
| `extends` / `super` / `@override` / `toString()` | `QuestaoMultiplaEscolha extends Questao` |
| Mixin com `with` | `LogAuditoriaMixin` em `QuestaoMultiplaEscolha` e em `QuizRepository` |
| Construtores gerativo, nomeado e factory | `QuestaoMultiplaEscolha(...)`, `.verdadeiroFalso(...)`, `.fromMap(...)`; `Partida.fromMap` |
| Encapsulamento (`_`) e getter/setter com validação | `_pontos` / `set pontos` |
| Null safety (`?`, `??`, `??=`, `?.`) | `fromMap`, `QuizDao._database` (`??=`), `aoConcluir?.call()` |
| Coleções funcionais, spread, collection-if/for | `GerenciadorQuiz`; `QuizRepository.baixarPacoteDeQuestoes`; telas (`for` em listas de widgets) |
| Exceção customizada + `try/on/catch/finally` + `rethrow` | `QuizException`, `SincronizacaoException`; `GerenciadorQuiz.sincronizarResultados`; `QuizRepository.baixarPacoteDeQuestoes` |
| CLI | `bin/main.dart` |

**AP2B:**

| Requisito | Onde |
|---|---|
| 10 rotas nomeadas com argumentos seguros | `lib/routes.dart`, `lib/app.dart` |
| `Scaffold`, `AppBar`, `ListView.builder`, `Dismissible`, `InkWell` | `questoes_screen.dart`, `ranking_screen.dart`, `jogar_screen.dart` |
| `Form`, `GlobalKey<FormState>`, `TextEditingController`, `TextFormField` validados | `questao_form_screen.dart`, `selecao_screen.dart` |
| Ícone sincronizado/pendente + `SnackBar` | `widgets/sync_status_icon.dart`, `widgets/ui_helpers.dart` |
| DAO sqflite (insert/query/update/delete) + `shared_preferences` | `datasources/quiz_dao.dart` |
| Serviço HTTP (async/await, JSON, statusCode, timeout) | `repositories/quiz_repository.dart` + `datasources/mock_api.dart` |
| Repository com fallback e exceções | `repositories/quiz_repository.dart` |
| 20 testes de unidade + 5 de widget | `test/` |

## Declaração de Uso de Inteligência Artificial

Esta seção presta contas do uso de IA nos dois marcos. O log detalhado dos prompts da AP2B está em [PROMPTS.md](PROMPTS.md).

### Marco 2 (AP2B)

#### 1. Ferramentas utilizadas e etapas

| Ferramenta | Etapas em que atuou |
|---|---|
| **Claude Code** (Anthropic, modelo Claude Opus 5.5), via extensão do VS Code | Geração inicial do código da AP2B (evolução dos modelos, DAO, repositório, mock da API, telas, rotas e testes); geração dos dados mock (as 10 questões de `MockApi.questoes`); depuração (um teste de ponta a ponta temporário revelou um `setState` que retornava `Future` em três telas, e a IA corrigiu); revisão de boas práticas guiada pelo analisador (`dart analyze`); redação desta documentação, do `PROMPTS.md` e da atualização do `ENVIRONMENT_REPORT.md`. |

#### 2. Fluxo de trabalho (spec-driven development)

Os requisitos foram definidos em etapas. Primeiro vieram os modelos e as regras de domínio, no Marco 1 (AP1B). Depois o grupo escreveu uma especificação para o Marco 2 com base no PDF da AP2B, cobrindo modelos, persistência SQLite, repositório Offline-First, mock da API, telas, testes e documentação, e com critérios de aceite explícitos (exatamente 10 rotas, 20 testes de unidade e 5 de widget, sem Bloc/Provider/Riverpod, mock em vez de API pública). Essa especificação foi enviada ao Claude Code, que gerou o código e rodou `flutter test`, `dart analyze` e `dart run bin/main.dart` para conferir o resultado.

O grupo revisou o código gerado, testou no emulador e pediu correções em novos prompts. [CONFIRMAR: o grupo descreve as rodadas reais de revisão e correção, ou ajusta este parágrafo se elas não aconteceram.]


#### 2. Limites e verificação

Os resultados dos testes devem ser verificados executando `flutter test`. Esta declaração não informa cobertura nem outras métricas que esse comando não reproduza. O comportamento no emulador (modo offline e ressincronização) deve ser conferido manualmente seguindo o roteiro em "Como demonstrar o modo offline".

### Marco 1 (AP1B)

> Conteúdo original da AP1B, mantido sem alterações. Os caminhos citados refletem a estrutura da época: o CLI `lib/main.dart` hoje está em `bin/main.dart` e `lib/services/dataBase_helper.dart` foi renomeado para `database_helper.dart`.

---

#### 1. Configuração de Infraestrutura: Criação do Dockerfile
* **Estruturação Conceitual (Trabalho do Grupo):**  
  A equipe definiu a estratégia de padronizar o ambiente de desenvolvimento através de contêineres Docker. O objetivo foi garantir que o projeto pudesse ser executado no terminal (CLI) por todos os membros do grupo e pelo professor de forma isolada, sem conflitos de versão ou exigência de instalações locais complexas.
* **Assistência da IA (Geração de Script de Infraestrutura):**  
  A IA foi consultada para gerar o código inicial do `Dockerfile` de forma que atendesse exatamente ao que foi pedido para essa primeira entrega do trabalho. A ferramenta estruturou as camadas do arquivo, incluindo a imagem base do Ubuntu, a instalação do Java, a declaração das variáveis de ambiente e os comandos para download e configuração do Android SDK e do Flutter SDK em modo headless (sem interface gráfica).
* **Prompt Utilizado:**  
  > *"Preciso criar um Dockerfile de modo que o contêiner gerado tenha o Flutter e o Android SDK configurados para rodar o projeto, sem precisarmos instalar o Android Studio na máquina."*

---

#### 2. Arquivo: `lib/models/questao.dart`
* **Estruturação Conceitual (Trabalho do Grupo):**  
  A equipe idealizou a hierarquia de classes, criando o enum `NivelDificuldade`, a classe abstrata base `Questao`, o encapsulamento do atributo privado `_pontos` com setter defensivo (rejeitando `<= 0`), e a especialização `QuestaoMultiplaEscolha`. O grupo também implementou um mixin transversal para auditoria com data/hora e de uma exceção própria de domínio (`QuizException`).
* **Assistência da IA (Aceleração de Boilerplate e Validação Sintática):**  
  A IA foi consultada para acelerar a escrita de código repetitivo (*boilerplate*), auxiliando na digitação das assinaturas dos três tipos de construtores em Dart 3 (repasse via `super`, construtor nomeado `.verdadeiroFalso` e esqueleto do `factory fromMap`), além de validar se a sintaxe do `LogAuditoriaMixin` e da `QuizException` estavam aderentes às convenções do Dart.
* **Prompt Utilizado:**  
  > *"Continue a escrita da classe concreta QuestaoMultiplaEscolha com: construtor generativo repassando super, construtor nomeado verdadeiroFalso, factory fromMap com validação defensiva de nulos, a exceção QuizException e o mixin LogAuditoriaMixin para formatar logs com timestamp."*

---

#### 3. Arquivo: `lib/services/gerenciador_quiz.dart`
* **Estruturação Conceitual (Trabalho do Grupo):**  
  A equipe projetou o serviço gerenciador para armazenar a lista interna de questões, controlar a pontuação acumulada do estudante e orquestrar a sessão do quiz, incluindo a lógica pedagógica de enquadramento de proficiência (Iniciante, Intermediário e Avançado).
* **Assistência da IA (Revisão de Código e Validação Sintática):**  
  Com a lógica de negócios e as operações funcionais já implementadas pelo grupo para atender aos requisitos do trabalho, a IA foi consultada estritamente para realizar a revisão técnica do que foi escrito (*code review*). A ferramenta auxiliou na checagem da sintaxe das funções de coleção do Dart (.where(), .fold(), .every(), .any(), Spread Operators e Collection-If/For), validando a tipagem estrita e confirmando o tratamento defensivo para casos de listas vazias.
* **Prompt Utilizado:**  
  > *"Faça uma revisão técnica do código em Dart no arquivo lib/services/gerenciador_quiz.dart para validar a tipagem estrita e a sintaxe dessas operações."*

---

#### 4. Arquivo: `lib/main.dart` (CLI Test Runner / Executável de Demonstração)
* **Desenvolvimento Inicial (Trabalho do Grupo):**  
  A equipe iniciou a codificação do arquivo `main.dart` montando um roteiro de testes no console para demonstrar a criação das instâncias, a persistência em banco local, as operações funcionais, a simulação de respostas do aluno e o relatório de proficiência sem depender de interface visual.
* **Assistência da IA (Auditoria de Conformidade e Revisão Técnica):**  
  O grupo forneceu à IA um documento descritivo contendo todo o passo a passo e critérios esperados para os testes práticos do trabalho. A ferramenta foi consultada para confrontar o código que já havia sido escrito pela equipe com as exigências desse documento, revisando a implementação e verificando se todas as etapas requeridas — como a validação explícita de casos de borda com blocos `try-catch` para a `QuizException` e o teste do setter de pontuação — estavam plenamente contempladas.
* **Prompt Utilizado:**  
  > *"A partir do documento enviado, analise o código presente em `lib/main.dart`, faça uma revisão técnica e verifique se está de acordo com as etapas exigidas no documento, apontando eventuais ajustes necessários. Além disso, estruture cabeçalhos e divisores visuais nos prints para que a saída no terminal fique nítida visualmente"*
---

#### 5. Depuração e Resolução de Erros de Build (Troubleshooting)
* **Contexto do Problema (Trabalho do Grupo):**  
  Ao executar `dart run lib/main.dart`, o compilador retornou o erro `Error when reading 'lib/models/quiz_models.dart': No such file or directory`, impedindo a compilação.
* **Assistência da IA (Diagnóstico Pontual):**  
  A equipe enviou a mensagem de erro para a IA, que rapidamente diagnosticou que o arquivo havia sido nomeado pelo grupo como `questao.dart`, mas o caminho de importação mantinha o nome antigo `quiz_models.dart`. O grupo realizou a correção imediata do caminho relativo.
* **Prompt Utilizado:**  
  > *"Executei `dart run lib/main.dart` e obtive o erro 'No such file or directory' ao ler lib/models/quiz_models.dart."*

---

#### 6. Evolução Arquitetural: Persistência Local com SQLite
* **Estruturação Conceitual (Trabalho do Grupo):**  
  A equipe decidiu evoluir a persistência temporária em memória para um banco de dados relacional em disco, viabilizando o paradigma *offline-first*.
* **Assistência da IA (Consulta Técnica de Biblioteca e Revisão de Assinaturas):**  
  O grupo consultou a IA para saber qual biblioteca permitia rodar SQLite em console Dart puro e contêiner Linux sem depender de canais nativos de celular (a IA recomendou o `sqflite_common_ffi`).
* **Prompt Utilizado:**  
  > *"Quero evoluir a persistência das questões para SQLite utilizando o ambiente atual (console/Docker). Como fazer isso?"*

---

#### 7. Evolução Arquitetural: Persistência Local com SQLite (lib\services\dataBase_helper.dart)
* **Estruturação Conceitual (Trabalho do Grupo):**  
    Definimos o esquema da tabela `questoes` com as colunas necessárias (`id`, `enunciado`, `dificuldade`, `pontos`, `opcoes`, `respostaCorreta`).
* **Assistência da IA (Esqueleto de Conexão e Adaptação):**  
  Como o SQLite tradicional de celular depende de canais nativos móveis e não roda no terminal/Docker, o grupo consultou a IA para saber como configurar a biblioteca `sqflite_common_ffi`. A IA forneceu a estrutura padrão de conexão de um helper com FFI, e a equipe utilizou esse modelo como base, adaptando os comandos SQL e implementando as rotinas de inserção e leitura das questões.
* * **Prompt Utilizado:**  
  > *"Como configurar o `sqflite_common_ffi` para rodar em console/Docker e se adaptar ao schema de banco:  
  > 
  > CREATE TABLE questoes (
  >   id TEXT PRIMARY KEY,
  >   enunciado TEXT NOT NULL,
  >   dificuldade TEXT NOT NULL,
  >   pontos INTEGER NOT NULL,
  >   opcoes TEXT NOT NULL,
  >   respostaCorreta TEXT NOT NULL
  > ); Forneça a estrutura básica de uma classe helper de conexão com métodos de inserção e consulta para que possamos adaptar ao projeto."*

---

#### 8. Resolução de Conflito de Resolução de Dependências (Host Windows vs Contêiner Linux)
* **Momento em que o Erro Surgiu e Motivação da Consulta:**
O erro surgiu no momento exato em que evoluímos o projeto para a implementação da persistência local em SQLite, adicionando os pacotes `sqflite_common_ffi` e `path` no `pubspec.yaml`. Para fazer o editor de código reconhecer as novas bibliotecas, executamos `flutter pub get` no PowerShell do Windows. Em seguida, ao tentar validar o pipeline no ambiente oficial do grupo (o contêiner Docker Linux) através do comando:
 ```powershell
  docker run --rm -v ${PWD}:/workspace -w /workspace quiz-adaptativo dart run lib/main.dart
  ```
  **Assistência da IA (Contribuição e Diagnóstico)**:
Enviamos o log completo do terminal solicitando a causa da falha. 

**Prompt utilizado**: "Adicionei as dependências do SQLite no pubspec.yaml e rodei flutter pub get no Windows. Porém, ao executar a aplicação no Docker com docker run --rm -v ${PWD}:/workspace -w /workspace quiz-adaptativo dart run lib/main.dart, o Linux abortou com erro dizendo que não encontrou os arquivos em '/C:/Users/carla/AppData/Local/Pub/Cache/hosted/pub.dev/...', disparando vários erros de 'Type Database not found'.""

  **Resposta e Solução**: a instrução recomendou a adição do download dos pacotes dentro do Dockerfile a partir da inserção de:
  ```
  COPY pubspec.yaml pubspec.lock* ./
  RUN flutter pub get
  ```

---
#### 9. Configuração de Ambiente (flutter doctor -v): Correção do Android Toolchain no Docker

**Estruturação Conceitual (Trabalho do Grupo):**
  A equipe decidiu utilizar o Docker para conteinerizar o ambiente de desenvolvimento do projeto em Flutter, garantindo o isolamento das ferramentas e dependências (como o Android SDK) sem a necessidade de instalações locais pesadas na máquina hospedeira.

**Assistência da IA (Resolução de Erros de Ambiente e Infraestrutura):**
  O grupo consultou a IA enviando os logs de execução do flutter doctor para interpretar o resultado. A dúvida principal era entender e corrigir o alerta ("!") apontado no Android toolchain dentro do contêiner. A IA esclareceu como o isolamento dos sistemas operacionais afeta as exigências do Flutter e indicou a correção exata no Dockerfile (atualizando o Android SDK para a versão 36 e o BuildTools para 28.0.3) para compatibilizar com a versão do Flutter recém-baixada.

**Prompt Utilizado:**
  >*"Resultado do flutter doctor dentro do container: [log com o "!" no Android toolchain]. Me explique porque"*

---

#### 10. Documentação Técnica: `README.md`
* **Estruturação Inicial (Trabalho do Grupo):**  
  Os alunos levantaram todas as informações técnicas, decisões de arquitetura, dados dos integrantes e requisitos do edital para compor a documentação.
* **Assistência da IA (Formatação e Diagramação):**  
  A ferramenta foi utilizada para formatar o texto em padrão Markdown, estruturar as tabelas e converter o diagrama conceitual desenhado pelo grupo para a sintaxe Mermaid e notação UML.
* * **Prompt Utilizado:**  
  > *"Organize as anotações técnicas do nosso projeto de Quiz Adaptativo em um README.md em padrão Markdown, contendo a árvore de pastas, instruções de execução via Docker e tabela de tecnologias utilizadas. Além disso, resuma todas as nossas interações ao longo do desenvolvimento em uma 'Declaração de Uso de Inteligência Artificial', redigindo essa seção no seguinte formato para cada tópico:  
  > - Identificação do Arquivo / Tópico;  
  > - Estruturação Conceitual (o que foi pensado e desenvolvido pelo grupo);  
  > - Assistência da IA (onde você nos auxiliou com boilerplate, revisão de sintaxe ou diagnóstico);  
  > - Prompt Utilizado (o comando real que enviamos)."  

---




## Referências

- TEIXEIRA, Giovany Frossard et al. **Fundamentos de Flutter e Dart para desenvolvimento de apps móveis**. Vitória: Edifes, 2024.
- MARINHO, Leonardo H. **Flutter Framework: Desenvolva aplicações móveis no Dart Side!**. São Paulo: Casa do Código, 2020.
- ARAÚJO, Everton Coimbra de. **Aprofundando em Flutter: desenvolva aplicações Dart com widgets**. São Paulo: Casa do Código, 2021.
- FLUTTER DEV. **Flutter Documentation: Building Applications with Flutter**. Google, 2026. Disponível em: https://docs.flutter.dev.
- DART DEV. **Dart Language Guide and Tour**. Google, 2026. Disponível em: https://dart.dev/docs.

## Entrega

Link do repositório enviado para `edgardpontes@professor.multivix.edu.br` com o assunto:

```text
[AP2B - Computação Móvel] - Tema 8 - Grupo 8
```
