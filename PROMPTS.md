# Log de Prompts: Quiz Adaptativo (Grupo 8, Tema 08)

**Fluxo spec-driven.** O grupo definiu os requisitos por etapa: domínio em Dart puro (AP1B), depois persistência SQLite, repositório Offline-First, mock da API, telas, testes e documentação (AP2B). A cada etapa, os requisitos e critérios de aceite viraram um prompt. O código gerado foi revisado, testado (`flutter test`, emulador) e corrigido em novos prompts quando necessário.

**Como a AP2B foi pedida, de fato.** Os requisitos das etapas 1b a 8 foram enviados ao Claude Code em **um único prompt consolidado** (seções A a J), junto com os PDFs da AP1B e da AP2B. Esse prompt está copiado na íntegra no [Anexo A](#anexo-a-prompt-consolidado-real-da-ap2b). Os prompts de cada etapa abaixo são recortes reescritos desse prompt real, com os nomes que existem no código.

---

## Etapa 1 - Modelos de domínio (AP1B)

### 1a. Marco 1 (AP1B)

*Prompt enviado pelo grupo:*
> Continue a escrita da classe concreta QuestaoMultiplaEscolha com: construtor generativo repassando super, construtor nomeado verdadeiroFalso, factory fromMap com validação defensiva de nulos, a exceção QuizException e o mixin LogAuditoriaMixin para formatar logs com timestamp.

*O que foi gerado:* esqueleto dos construtores de `QuestaoMultiplaEscolha` (gerativo, `.verdadeiroFalso`, `factory .fromMap`), `QuizException` e `LogAuditoriaMixin` em `lib/models/questao.dart` (detalhes na seção do Marco 1 do README).


### 1b. Evolução dos modelos para a AP2B

*Prompt enviado pelo grupo:*
> Evolua os modelos da AP1B sem remover nada e mantendo `lib/models` em Dart puro (sem flutter, sqflite ou http). Em `Questao`, adicione `categoria` e `sincronizado`. Em `QuestaoMultiplaEscolha`, adicione `toMap()` para o SQLite (alternativas como texto JSON, bool como 0/1), `toJson()` para a API, `copyWith({bool? sincronizado})` e o getter `indiceCorreta`. O `factory fromMap` deve aceitar o formato antigo (`opcoes`/`respostaCorreta`), o do SQLite e o da API (`alternativas` + `correta` como índice), e continuar lançando `QuizException` para dados inválidos. Crie `lib/models/partida.dart` com `Partida` (id, jogador, categoria, pontuacao, acertos, total, data, sincronizado), com as mesmas conversões e validação. No enum `NivelDificuldade`, adicione `rotulo`, `pontosBase` e `parse()`. Extraia a classificação de proficiência do CLI para `GerenciadorQuiz.classificarProficiencia`, sem mudar as faixas (40% e 70%), e faça `processarResposta` retornar `bool`. Mova o CLI para `bin/main.dart`.

*O que foi gerado:* alterações em `lib/models/questao.dart` (campos novos, conversões, `SincronizacaoException extends QuizException`), `lib/models/nivel_dificuldade.dart` e `lib/services/gerenciador_quiz.dart`; novo `lib/models/partida.dart`; `lib/main.dart` movido para `bin/main.dart`; `lib/services/dataBase_helper.dart` renomeado para `database_helper.dart`.

---

## Etapa 2 - Persistência SQLite (DAO)

*Prompt enviado pelo grupo:*
> Crie em `lib/datasources/quiz_local_datasource.dart` a interface abstrata `QuizLocalDatasource` com `inserirQuestao`, `listarQuestoes`, `atualizarQuestao`, `removerQuestao`, `inserirPartida`, `listarPartidas`, `listarPartidasPendentes`, `atualizarPartida` e leitura/gravação da data da última sincronização. Implemente em `lib/datasources/quiz_dao.dart` a classe `QuizDao` com `sqflite`: tabelas `questoes` e `partidas` (coluna `sincronizado INTEGER`), as quatro operações insert/query/update/delete usando `toMap()`/`fromMap()`, e `shared_preferences` apenas para a data/hora da última sincronização. Nenhuma outra classe do app pode executar SQL.

*O que foi gerado:* `lib/datasources/quiz_local_datasource.dart` (interface) e `lib/datasources/quiz_dao.dart` (`QuizDao`).

---

## Etapa 3 - Repositório Offline-First

*Prompt enviado pelo grupo:*
> Crie `lib/repositories/quiz_repository.dart` com `QuizRepository`, recebendo por construtor um `QuizLocalDatasource` e um `http.Client`. A UI só fala com o repositório. Leitura sempre local. Escrita resiliente: `salvarQuestao` e `salvarPartida` gravam primeiro com `sincronizado = false`, depois tentam a API (PUT `/questoes/{id}` e POST `/partidas`) e marcam `true` só com status 200/201. Implemente também `removerQuestao` (DELETE de melhor esforço), `baixarPacoteDeQuestoes()` (GET, grava sem duplicar ids), `sincronizarPendencias()` (reenvia só os pendentes e grava a data da última sincronização) e `contarPendencias()`. Use `async/await`, `dart:convert`, `.timeout(const Duration(seconds: 5))` e `try` / `on SocketException` / `on TimeoutException` / `catch` / `finally`, com `rethrow` de `QuizException` e a exceção customizada `SincronizacaoException`. O app tem de continuar 100% operacional sem internet.

*O que foi gerado:* `lib/repositories/quiz_repository.dart` (`QuizRepository`, que também aplica `LogAuditoriaMixin`).

---

## Etapa 4 - Mock da API e Switch "Simular offline"

*Prompt enviado pelo grupo:*
> Não use API pública. Crie `lib/datasources/mock_api.dart` com a classe `MockApi`, que expõe um `MockClient` (`package:http/testing.dart`) injetado no `QuizRepository` como `http.Client`. GET `/questoes` devolve 200 com 10 questões fixas no formato `{"id","enunciado","alternativas":[...],"correta","dificuldade","categoria"}` (fácil/médio/difícil e categorias variadas, sem o formato do Open Trivia DB). POST `/partidas` devolve 201, PUT e DELETE em `/questoes/{id}` devolvem 200. Com o campo `simularOffline` ligado, toda requisição lança `SocketException`. A tela de Diagnóstico liga e desliga esse campo por um Switch.

*O que foi gerado:* `lib/datasources/mock_api.dart` (`MockApi` e `MockApi.questoes`, com as 10 questões mock geradas pela IA); injeção em `lib/main.dart`.

---

## Etapa 5 - Telas, rotas e formulários

*Prompt enviado pelo grupo:*
> Crie exatamente 10 rotas nomeadas em `lib/routes.dart` (`Rotas`) e o roteamento em `lib/app.dart` (`QuizApp`, Material 3, `onGenerateRoute` validando o tipo do argumento): Home, lista de questões (`ListView.builder` + `Dismissible`), formulário de questão (`Form`, `GlobalKey<FormState>`, `TextEditingController`, `TextFormField` com validadores), detalhes da questão, seleção de categoria/dificuldade, jogar (`JogoArgs`), resultado (`Partida`), ranking com `Icons.cloud_done`/`Icons.cloud_off`, detalhes da partida e diagnóstico (pendências, última sincronização, "Sincronizar agora", Switch "Simular offline"). Use só `StatefulWidget` + `FutureBuilder`/`setState`, sem Bloc, Provider ou Riverpod. Nada de HTTP ou SQL em widgets. Botão "Baixar pacote de questões" na Home e no Diagnóstico, com SnackBar. Com o banco vazio, a Home mostra "Nenhuma questão. Baixe um pacote quando estiver online" e desabilita o Jogar. Evite overflow.

*O que foi gerado:* `lib/routes.dart`, `lib/app.dart`, `lib/main.dart` (app Flutter) e as telas em `lib/screens/` (`home_screen.dart`, `questoes_screen.dart`, `questao_form_screen.dart`, `questao_detalhes_screen.dart`, `selecao_screen.dart`, `jogar_screen.dart`, `resultado_screen.dart`, `ranking_screen.dart`, `partida_detalhes_screen.dart`, `diagnostico_screen.dart`); widgets em `lib/widgets/` (`sync_status_icon.dart`, `baixar_pacote_button.dart`, `ui_helpers.dart`). Na verificação, um teste de ponta a ponta temporário (depois removido) revelou que `_recarregar()` em três telas passava ao `setState` uma closure que retornava `Future`. A IA corrigiu para o corpo com chaves.

---

## Etapa 6 - Testes de unidade

*Prompt enviado pelo grupo:*
> Crie exatamente 20 testes de unidade com `group`/`test`/`expect`/`throwsA`: 8 de modelos em `test/models_test.dart` (toMap/fromMap, toJson, copyWith, bool ↔ 0/1, padrões, `QuizException` para dados inválidos), 6 de regras da AP1B em `test/regras_quiz_test.dart` (pontuação, dificuldade, resposta, setter validado, mixin, exceção com rethrow) e 6 do repositório em `test/repository_test.dart`, usando `FakeLocalDatasource` (em `test/fakes/`) e `MockClient`: erro 500 mantém pendente, `SocketException` mantém pendente, 201 marca sincronizado, `sincronizarPendencias` envia só os pendentes, baixar pacote grava questões sem duplicar e timeout tratado.

*O que foi gerado:* `test/models_test.dart`, `test/regras_quiz_test.dart`, `test/repository_test.dart` e `test/fakes/fake_local_datasource.dart`. Para o teste de timeout não esperar 5 s, o `QuizRepository` aceita um `timeout` opcional no construtor (padrão de 5 s).

---

## Etapa 7 - Testes de widget

*Prompt enviado pelo grupo:*
> Crie exatamente 5 testes de widget em `test/widget_test.dart` com `testWidgets`, `pumpWidget`, `pump`, `find.byType`, `find.text` e `tester.tap`, passando o `QuizRepository` com fakes por construtor: (1) `QuestoesScreen` renderiza itens fake; (2) `QuestaoFormScreen` mostra erro em campos vazios; (3) formulário válido salva sem erro; (4) `SyncStatusIcon` diferencia pendente e sincronizado; (5) em `JogarScreen`, tocar numa alternativa mostra o feedback e o botão de avançar. O `widget_test.dart` atual é o modelo padrão do Flutter (contador) e não compila: substitua o conteúdo.

*O que foi gerado:* `test/widget_test.dart` com os 5 testes.

---

## Etapa 8 - README e documentação

*Prompt enviado pelo grupo:*
> Atualize o `README.md` mantendo o conteúdo da AP1B (integrantes, tema, como rodar, Declaração de IA da AP1B, referências) e acrescentando: Grupo 8, diagrama ASCII da arquitetura Offline-First (UI → `QuizRepository` → `QuizDao` + `MockApi`), descrição do mock e dos endpoints, comandos `flutter pub get`, `flutter run`, `flutter test` e `dart run bin/main.dart`, as 5 referências do PDF da AP2B, o assunto do e-mail e uma Declaração de Uso de IA da AP2B (ferramentas, fluxo spec-driven, participação do grupo com marcações [CONFIRMAR], autoria cognitiva, tabela IA vs. grupo com placeholders e limites de verificação). Crie este `PROMPTS.md` com as 8 etapas marcadas como [REAL] ou [RECONSTRUÍDO] e atualize o `ENVIRONMENT_REPORT.md` e o `.gitignore`.

*O que foi gerado:* `README.md` (reestruturado, com a declaração da AP1B preservada na íntegra), `PROMPTS.md`, `ENVIRONMENT_REPORT.md` (saída do `flutter doctor -v` da AP1B mantida e seção da AP2B adicionada) e `.gitignore` ampliado.
