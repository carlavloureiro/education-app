# Roteiro de Apresentação — Marco 1 (AP1B)
## Tema 08: Aplicativo de Educação e Quiz Adaptativo
**Disciplina:** Computação Móvel (2026/2) — 8° Período, Sistemas de Informação  
**Professor:** Edgard da Cunha Pontes  
**Instituição:** Faculdade Multivix  
**Tempo Estimado:** 12 a 15 minutos  
**Divisão da Equipe (5 Integrantes):** ~2m30s a 3m por integrante

---

### Visão Geral da Sequência da Apresentação

O roteiro segue rigorosamente a ordem lógica de engenharia e os requisitos do trabalho:

```text
1. Contextualização do Tema 08 e da Solução (Carla)
2. Diagnóstico do Ambiente com flutter doctor -v (Carla)
3. Decisão de Infraestrutura: Docker e Análise do Dockerfile (Gabriel)
4. Como Chegamos à Solução: Modelagem e Diagrama de Classes UML (Gabriel)
5. O Código em Si: Estrutura do Repositório e Camada de Domínio (Luis Gustavo)
6. O Código em Si: Camada de Serviços, Programação Funcional e SQLite (Luiz Henrique)
7. Execução dos Testes no CLI Runner (5 Etapas) e Relação com Requisitos (Vinicio)
8. Conclusão e Perspectivas para o Marco 2 (Vinicio)
```

---

## 🎤 Bloco 1: Contextualização do Tema e Diagnóstico do Ambiente
*Tempo sugerido: ~2m40s | Apresentador: Carla*

---

### 1.1 Contextualização do Tema 08 e da Solução
* **Tempo:** ~1m20s
* **O que falar:**
  > "Boa noite, professor Edgard e colegas. Somos o grupo de Computação Móvel composto por mim, Carla, e pelos colegas Gabriel, Luis Gustavo, Luiz Henrique e Vinicio.  
  > O nosso projeto aborda o **Tema 08: Aplicativo de Educação e Quiz Adaptativo**.  
  > Qual foi o problema de partida que identificamos? Os aplicativos de quiz convencionais são rígidos e estáticos: todos os alunos recebem as mesmas perguntas na mesma sequência, gerando desmotivação tanto para quem já domina o conteúdo quanto para quem precisa de reforço básico.  
  > A nossa solução é um motor de quiz adaptativo, capaz de classificar questões por níveis de dificuldade — fácil, médio e difícil —, auditar cada tentativa com carimbo de data e hora, e enquadrar o aluno dinamicamente em faixas pedagógicas de proficiência: Iniciante, Intermediário e Avançado.  
  > Um ponto fundamental: respeitamos estritamente a diretriz do Marco 1. Não construímos telas com Widgets do Flutter nesta fase. Focamos em desenvolver um núcleo de domínio e regras de negócio robusto em Dart puro, desacoplado e totalmente testável via terminal."
* **O que apontar no slide / apoio visual:**
  - Mostrar o título do Tema 08 e o tripé do problema: *Educação Estática vs. Aprendizado Adaptativo*.
  - Frisar a fronteira arquitetural: *Marco 1 = Lógica Pura em Dart* | *Marco 2 = Interface Gráfica em Widgets*.

---

### 1.2 Diagnóstico do Ambiente: `flutter doctor -v`
* **Tempo:** ~1m20s
* **O que falar:**
  > "Antes de qualquer linha de lógica de negócio ser escrita, o primeiro marco prático do trabalho foi homologar o ambiente de desenvolvimento através do comando `flutter doctor -v`.  
  > Como documentamos no nosso relatório `ENVIRONMENT_REPORT.md`, o comando faz uma varredura completa da cadeia de ferramentas (*toolchain*):  
  > Ele valida a versão estável do Flutter (3.47+) e do Dart SDK (3.13+), verifica os canais de rede e confirma a prontidão do compilador.  
  > Durante o diagnóstico no contêiner, o Flutter Doctor aponta advertências nas categorias de navegadores gráficos como Chrome e interface de desktop Linux. Explicamos isso tecnicamente na documentação: como estamos executando o Marco 1 em um contêiner Linux estritamente *headless* (sem interface visual), a ausência de janelas gráficas é proposital e esperada, não afetando em nada a compilação do código Dart puro e da suite de testes."
* **O que apontar no slide / apoio visual:**
  - Apontar o print do terminal com o `[✓] Flutter` e `[✓] Dart` com marcas de verificação verdes.
  - Destacar a justificativa técnica documentada para o modo *headless*.

---

## 🐳 Bloco 2: Infraestrutura Docker e Modelagem Conceitual (UML)
*Tempo sugerido: ~3m00s | Apresentador: Gabriel*

---

### 2.1 Nossa Escolha do Docker e Análise do `Dockerfile`
* **Tempo:** ~1m30s
* **O que falar:**
  > "Um dos pilares técnicos do nosso projeto foi a padronização do ambiente via DevOps com Docker.  
  > Por que escolhemos o Docker? Em projetos em equipe e na entrega acadêmica, o erro mais comum é o clássico 'na minha máquina funciona'. Cada integrante tem uma versão de Windows, Linux ou SDK diferente. O Docker elimina essa incerteza, garantindo paridade total entre desenvolvimento e correção.  
  > O nosso `Dockerfile` adota a imagem base oficial do Ubuntu 22.04 LTS. Nele, configuramos o JDK 17, provisionamos o Flutter/Dart SDK e configuramos variáveis de ambiente como o `PATH`.  
  > Além disso, resolvemos um desafio importante de volumes: ao espelhar a pasta do Windows no Linux, os binários locais de cache do Windows em `.dart_tool` entravam em conflito com os binários do Linux. Solucionamos isolando a pasta `.dart_tool` através de volumes anônimos e embutindo a pré-resolução de dependências com `COPY pubspec.yaml` e `RUN flutter pub get` na receita da imagem."
* **O que apontar no slide / apoio visual:**
  - Mostrar trechos-chave do `Dockerfile` (imagem base Ubuntu, variáveis de ambiente e `flutter pub get`).
  - Apontar o comando único de execução: `docker run --rm -v ${PWD}:/workspace ...`.

---

### 2.2 Como Chegamos à Solução: O Diagrama de Classes UML
* **Tempo:** ~1m30s
* **O que falar:**
  > "Com o ambiente isolado, partimos para a engenharia de software e modelagem conceitual das classes antes da codificação.  
  > Aqui podemos ver o nosso Diagrama de Classes UML que atende diretamente aos requisitos de Orientação a Objetos:  
  > 1. No topo, a classe abstrata `Questao`: define o contrato base com `id`, `enunciado`, `dificuldade` e o atributo privado `_pontos`. A pontuação é encapsulada com getter e setter que barra valores negativos com `ArgumentError`. Ela também declara o método polimórfico abstrato `responder()`;  
  > 2. A especialização `QuestaoMultiplaEscolha`, que estende `Questao` e incorpora o `LogAuditoriaMixin` para fornecer auditoria transversal com timestamp ISO-8601;  
  > 3. O enum `NivelDificuldade`, que elimina strings soltas no sistema;  
  > 4. A classe `GerenciadorQuiz`, que agrega a lista de questões e executa o algoritmo pedagógico de proficiência;  
  > 5. E a classe `DatabaseHelper`, que estabelece a ponte de persistência com o banco SQLite."
* **O que apontar no slide / apoio visual:**
  - Apontar no diagrama: a herança com seta fechada (`extends Questao`), o mixin (`with LogAuditoriaMixin`), o atributo privado `- _pontos: int` e o relacionamento de agregação do `GerenciadorQuiz`.

---

## 💻 Bloco 3: O Código em Si — Estrutura e Camada de Domínio
*Tempo sugerido: ~2m50s | Apresentador: Luis Gustavo*

---

### 3.1 Estrutura do Repositório Git e Separação de Responsabilidades
* **Tempo:** ~50s
* **O que falar:**
  > "Passando para o código-fonte, organizamos o repositório aplicando o princípio da Separação de Responsabilidades (SoC) e Clean Architecture:  
  > Na raiz, temos a governança: `pubspec.yaml`, `Dockerfile`, a documentação no `README.md`, o banco gerado `quiz_app.db` e as diretrizes do linter em `analysis_options.yaml`.  
  > Dentro de `lib/`, separamos o projeto em duas camadas limpas: a pasta `models/`, contendo as regras e entidades de domínio puras, e a pasta `services/`, contendo a lógica de orquestração e acesso a dados. O arquivo `main.dart` atua como o ponto de entrada da aplicação."
* **O que apontar no slide / apoio visual:**
  - Exibir a árvore de diretórios destacando a separação entre `models/` e `services/`.

---

### 3.2 Camada de Domínio e Atendimento aos Requisitos de POO (`lib/models/`)
* **Tempo:** ~2m00s
* **O que falar:**
  > "Na pasta `lib/models/`, atendemos integralmente aos Requisitos 1 e 2 do trabalho:  
  > No arquivo `nivel_dificuldade.dart`, criamos o `enum NivelDificuldade` com os valores `facil`, `medio` e `dificil`. Ele traz métodos de extensão defensivos como `fromString()` para garantir segurança ao ler dados do banco.  
  > No arquivo `questao.dart`, concentramos os recursos mais avançados de POO pedidos pelo edital:  
  > **Primeiro, Abstração e Encapsulamento:** a classe `Questao` protege a pontuação privativa `_pontos`. Se alguém tentar atribuir `<= 0`, o setter rejeita com `ArgumentError`;  
  > **Segundo, Mixin:** criamos o `LogAuditoriaMixin`, que injeta a capacidade de gerar logs formatados com carimbo de data e hora em qualquer questão;  
  > **Terceiro, Exceção Customizada:** criamos a classe `QuizException`, atendendo ao requisito de tratamento de regras de negócio;  
  > **Quarto, os 3 Construtores Exigidos na mesma classe:** em `QuestaoMultiplaEscolha`, temos:  
  > 1. O construtor padrão com repasse moderno via `super`;  
  > 2. O construtor nomeado `.verdadeiroFalso()`;  
  > 3. E o construtor de fábrica (`factory .fromMap()`), que faz parsing de mapas e JSON validando nulos com Sound Null Safety e disparando `QuizException` se o enunciado vier vazio."
* **O que apontar no slide / apoio visual:**
  - Destacar trechos de código do `questao.dart`: `with LogAuditoriaMixin`, o setter validando `novoValor <= 0`, e as assinaturas dos 3 construtores (`super`, `.verdadeiroFalso`, `factory fromMap`).

---

## ⚙️ Bloco 4: O Código em Si — Serviços, Programação Funcional e SQLite
*Tempo sugerido: ~3m00s | Apresentador: Luiz Henrique*

---

### 4.1 Camada de Serviços: Coleções Avançadas e Programação Funcional (`gerenciador_quiz.dart`)
* **Tempo:** ~1m30s
* **O que falar:**
  > "Na pasta `lib/services/`, o arquivo `gerenciador_quiz.dart` cumpre 100% dos requisitos de Coleções e Programação Funcional do edital, sem utilizar laços imperativos arcaicos:  
  > **1. Métodos Funcionais:** utilizamos `.where()` para filtrar questões por dificuldade, `.fold()` para acumular o somatório de pontuação máxima, `.every()` para validar que todas as questões possuem pontuação positiva, e `.any()` para verificar se há perguntas difíceis no banco;  
  > **2. Spread Operators (`...` e `...?`):** no método `cadastrarEmLote()`, mesclamos coleções obrigatórias e coleções opcionais utilizando o spread tradicional e o null-aware spread;  
  > **3. Collection-For e Collection-If:** no método `gerarCatalogoFormatado()`, usamos Collection-For para projetar cada questão diretamente na lista e Collection-If para inserir alertas pedagógicos apenas quando existirem perguntas difíceis;  
  > E por fim, o método `calcularProficiencia()`, que processa a taxa percentual de acertos e enquadra o estudante no nível de proficiência adaptativo."
* **O que apontar no slide / apoio visual:**
  - Apontar no código: `.where()`, `.fold()`, `[...loteObrigatorio, ...?loteOpcional]`, e a lista com `for (final q in _questoes)` e `if (condicao)`.

---

### 4.2 Persistência Local: A Evolução para SQLite com FFI (`database_helper.dart`)
* **Tempo:** ~1m30s
* **O que falar:**
  > "Uma das maiores evoluções do projeto foi a transição da persistência em memória volátil para um banco relacional em disco.  
  > Inicialmente, se a aplicação fosse fechada, todas as perguntas seriam perdidas. Para resolver isso e atender ao paradigma *Offline-first*, criamos a classe `DatabaseHelper` no arquivo `database_helper.dart`.  
  > Um detalhe de engenharia essencial: não usamos o pacote móvel tradicional `sqflite`, pois ele depende dos canais nativos do Android e iOS e quebraria em ambiente de terminal e Docker.  
  > Adotamos a biblioteca `sqflite_common_ffi`. Ela acessa o motor nativo em C do SQLite via Foreign Function Interface. Com isso, o sistema cria e manipula a tabela `questoes` diretamente no arquivo físico `quiz_app.db` na raiz do projeto, tanto no Windows quanto no Linux do Docker, garantindo que o aplicativo funcione com zero dependência de conexão com a internet."
* **O que apontar no slide / apoio visual:**
  - Mostrar a classe `DatabaseHelper`, a instrução `CREATE TABLE questoes` e o arquivo físico gerado `quiz_app.db` (12 KB em disco).
  - Enfatizar o paradigma *Offline-first*.

---

## 🧪 Bloco 5: Testes Executados, Relação com os Requisitos e Conclusão
*Tempo sugerido: ~3m10s | Apresentador: Vinicio*

---

### 5.1 O CLI Test Runner (`lib/main.dart`) e as 5 Etapas de Teste
* **Tempo:** ~1m40s
* **O que falar:**
  > "Para comprovar que todo o sistema funciona de forma integrada sem depender de interface visual, transformamos o `lib/main.dart` em um CLI Test Runner automatizado, dividido em 5 etapas que cobrem todos os requisitos:  
  > Na **Etapa 1**, criamos as questões com os 3 construtores e consolidamos o lote com os Spread Operators (`...` e `...?`);  
  > Em seguida, acionamos a **Persistência SQLite**, gravando no arquivo `quiz_app.db` e recuperando as questões do disco com sucesso;  
  > Na **Etapa 2**, validamos as **Coleções Funcionais**: o `.where()` filtrou as 2 questões fáceis, o `.fold()` totalizou a pontuação máxima de 40 pontos, o `.every()` retornou `true`, e o catálogo foi impresso formatado via Collection-For e Collection-If;  
  > Na **Etapa 3**, simulamos o aluno respondendo ao quiz. Toda resposta gerou o log de auditoria do `LogAuditoriaMixin` com carimbo de data e hora em ISO-8601;  
  > Na **Etapa 4**, o sistema calculou o relatório pedagógico: 30 de 40 pontos (75% de aproveitamento), enquadrando o aluno no nível **Avançado**;  
  > E na **Etapa 5**, executamos testes de borda propositais: forçamos a criação de uma questão sem enunciado e o bloco `try-catch` capturou a nossa `QuizException`. Depois, tentamos atribuir pontuação negativa via setter e o `ArgumentError` foi interceptado perfeitamente."
* **O que apontar no slide / apoio visual:**
  - Apontar os prints do terminal com as saídas reais de cada etapa: os logs `[AUDITORIA QUIZ - timestamp]`, a caixinha do relatório final e a captura dos testes de borda com `[SUCESSO]`.

---

### 5.2 Relação Direta dos Testes com o Edital e Conclusão do Marco 1
* **Tempo:** ~1m30s
* **O que falar:**
  > "Cruzando os testes executados com os critérios do edital do Marco 1, fechamos 100% dos requisitos avaliados:  
  > - Orientação a Objetos, herança, mixins e 3 tipos de construtores: **Validado**;  
  > - Encapsulamento com setter defensivo e exceções customizadas: **Validado**;  
  > - Métodos funcionais de coleções (.where, .fold, .every, .any) e operadores spread/collection-if/for: **Validado**;  
  > - Persistência relacional local com SQLite e paradigma offline-first: **Validado**;  
  > - Infraestrutura reproduzível em Docker e documentação com política de IA no README: **Validado**.  
  > Como próximos passos para o **Marco 2**, pegaremos essa camada estável de serviços e banco local e construiremos a árvore de Widgets visuais do Flutter, adicionando telas interativas, animações de feedback e sincronização remota.  
  > Agradecemos ao professor Edgard e a todos os colegas. Estamos prontos para responder às perguntas da banca!"
* **O que apontar no slide / apoio visual:**
  - Exibir a tabela de conformidade (Requisitos do Edital vs. Implementação no Projeto).
  - Encerrar abrindo espaço para a banca avaliadora.

---

## 📌 Cartão de Consulta Rápida para o Grupo (Perguntas Frequentes do Professor)

| Pergunta Provável do Professor | Resposta-Chave Recomendada |
| :--- | :--- |
| **"Por que não tem nenhuma tela gráfica de celular se o trabalho é de Computação Móvel?"** | *"O edital do Marco 1 focou deliberadamente no domínio, regras de negócio e POO pura em Dart. Isolar a lógica de domínio da interface gráfica segue a Clean Architecture. As telas em Widgets virão no Marco 2 consumindo essa base estável."* |
| **"Qual o motivo técnico de usar `sqflite_common_ffi` e não `sqflite`?"** | *"O `sqflite` tradicional exige canais nativos de Android/iOS (MethodChannels), impossibilitando execução em console e em contêineres Docker headless. O `sqflite_common_ffi` utiliza Foreign Function Interface direto na biblioteca C do SQLite, rodando nativamente no Linux e no Windows."* |
| **"Por que não usaram laço `for` tradicional nas coleções?"** | *"Porque métodos de ordem superior funcionais (`.where`, `.fold`, `.any`, `.every`) evitam efeitos colaterais de mutabilidade de variáveis acumuladoras, reduzem bugs de índice e deixam o código declarativo, cumprindo expressamente o Requisito 2."* |
| **"O que causou o problema de volumes no Docker e como resolveram?"** | *"O `.dart_tool/package_config.json` continha caminhos absolutos do Windows (`C:/Users/...`). Quando o Linux tentava rodar, não encontrava os caminhos. Isolamos a pasta `.dart_tool` com volume anônimo e fizemos o build das dependências no Dockerfile."* |
| **"Por que usar Mixin e não colocar o log na classe Questao?"** | *"O mixin permite desacoplamento e reutilização transversal (princípio de responsabilidade única). A auditoria com timestamp não pertence à essência de uma Questao e poderá ser reutilizada em futuras classes como Usuario ou Sessao no Marco 2."* |
