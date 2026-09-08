# Quiz Adaptativo

Aplicativo mobile de educação com quiz adaptativo, desenvolvido como proposta do trabalho avaliativo da disciplina de Computação Móvel.

**Professor:** Edgard da Cunha Pontes
**Curso:** Sistemas de Informação | Período: 8°

## Integrantes

- Carla Vazzoler Loureiro 
- Gabriel Ramos Maciel
- Luis Gustavo de Jesus Ribeiro Pimentel
- Luiz Henrique Lesquives Sartório
- Vinicio da Silva Mendes

## Tema

**Tema 08 — Aplicativo de Educação e Quiz Adaptativo**

## Descrição

O **Quiz Adaptativo** é uma solução de tecnologia educacional voltada para dispositivos móveis, desenvolvida como parte do Marco 1 do Projeto Prático Integrado (PBL) da disciplina de Computação Móvel do curso de Sistemas de Informação da Faculdade Multivix.
O foco central deste primeiro marco é o projeto e a implementação do **Módulo Central de Domínio e Lógica de Negócios** da aplicação em Dart puro, estruturado em camadas e totalmente desacoplado da camada visual de interface gráfica (árvore de Widgets do Flutter, que será introduzida nos marcos posteriores).

### Objetivos e Funcionalidades Principais:
* **Gerenciamento de Questões por Dificuldade:** Estruturação de um banco de questões em memória categorizado por níveis de complexidade (`facil`, `medio` e `dificil`) através de enums fortemente tipados.
* **Validação Polimórfica e Herança:** Modelagem de um contrato base abstrato (`Questao`) com especialização para questões de múltipla escolha e verdadeiro/falso, garantindo extensibilidade para novos formatos de perguntas.
* **Variedade de Construtores:** Suporte a instanciação direta com repasse via `super`, construtores nomeados para criação simplificada de testes rápidos e construtores de fábrica (`factory .fromMap`) com validação defensiva contra dados nulos ou incompletos.
* **Auditoria Pedagógica com Mixins:** Registro automático de logs de auditoria em tempo real com carimbo de data e hora (timestamp no padrão ISO-8601) para cada resposta submetida pelo aluno.
* **Processamento Funcional de Dados:** Manipulação de coleções de domínio utilizando métodos de ordem superior nativos do Dart (`.where()` para filtragem e `.fold()` para cálculo acumulado da pontuação máxima).
* **Classificação de Proficiência Adaptativa:** Avaliação do aproveitamento percentual do estudante com enquadramento dinâmico em níveis de proficiência (*Iniciante*, *Intermediário* e *Avançado*).
* **Validação Defensiva e Casos de Borda:** Tratamento rigoroso de exceções customizadas de negócio (`QuizException`) e regras de encapsulamento com `try-on-catch-finally`, garantindo estabilidade e aderência total ao *Sound Null Safety*.

## Modelagem (Diagrama de Classes)
<img width="797" height="1059" alt="Diagrama sem nome drawio" src="https://github.com/user-attachments/assets/55731df0-6a0a-43cf-9fca-fe3e0a8d06ba" />


## Arquitetura e Tecnologias

- **Framework:** Flutter
- **Linguagem:** Dart
- **Persistência local:** SQLite (questões)
- **Paradigma:** Offline-first

## Como Rodar o Projeto

O projeto pode ser executado tanto diretamente no ambiente da sua máquina quanto de forma isolada via contêiner Docker.

### Pré-requisitos

* **Git** instalado na máquina para clonagem do repositório.
* **Opção A (Execução Local):** Dart SDK (versão 3.13+) ou Flutter SDK (versão 3.x+).
* **Opção B (Execução em Contêiner):** Docker Desktop ou Docker Engine instalado (opcionalmente com a extensão *Dev Containers* no VS Code).

### Modo 1: Execução Local com Dart SDK (Recomendado / Mais Rápido)
Se você já possui o Dart ou Flutter instalado na sua máquina:
1. Clone o repositório e acesse a pasta raiz do projeto:
   ```bash
   git clone https://github.com/carlavloureiro/education-app.git
   cd education-app

2. Execute o CLI Test Runner de demonstração:
    ```bash
    dart run lib/main.dart

### Modo 2: Execução via Docker CLI (Linha de Comando Pura)
1. Na raiz do projeto, construa a imagem Docker:
    ```bash
    docker build -t quiz-adaptativo .

2. Execute o script de testes mapeando o volume do projeto:
    1. PowerShell (Windows)
      ```bash
      docker run --rm -v ${PWD}:/workspace -w /workspace quiz-adaptativo dart run lib/main.dart
      ```
   2. Bash (Linux/macOS)
      ```bash
      docker run --rm -v $(pwd):/workspace -w /workspace quiz-adaptativo dart run lib/main.dart
      ```

   3. 3. Bash (Linux/macOS)
      ```bash
      docker run --rm -v "%cd%":/workspace -w /workspace quiz-adaptativo dart run lib/main.dart
      ```



### Estrutura do Projeto

O projeto adota uma arquitetura em camadas modular e desacoplada em Dart puro, separando as entidades de domínio, a camada de serviços/persistência e o executável de demonstração em console:

O projeto adota uma arquitetura em camadas simples e modular em Dart puro, separando as entidades de domínio, a camada de serviços e o executável de demonstração em console:
```text
education_app/
├── .devcontainer/                # Configurações do ambiente de desenvolvimento integrado (VS Code)
│   └── devcontainer.json
├── .gitignore                    # Regras de exclusão de artefatos de build, caches e arquivos de IDE
├── Dockerfile                    # Receita do contêiner reproduzível (Ubuntu 22.04, JDK 17, Flutter SDK)
├── ENVIRONMENT_REPORT.md         # Diagnóstico do ambiente (flutter doctor -v) e justificativas do Git
├── README.md                     # Documentação técnica oficial e declaração obrigatória de IA
├── ROTEIRO_APRESENTACAO.md       # Guia e roteiro de apresentação com divisão de falas por integrante
├── analysis_options.yaml         # Regras estáticas do linter oficial (flutter_lints)
├── pubspec.yaml                  # Metadados do projeto, dependências (SQLite FFI, path) e SDK
├── quiz_app.db                   # Banco de dados relacional SQLite local em disco (Offline-first)
│
├── lib/
│   ├── main.dart                 # Ponto de entrada da aplicação e CLI Test Runner (5 etapas)
│   │
│   ├── models/                   # Camada de Domínio (Entidades, Contratos e Regras Base)
│   │   ├── nivel_dificuldade.dart # Enum tipado com os níveis (fácil, médio, difícil) e parsers
│   │   └── questao.dart          # Classe abstrata Questao, QuestaoMultiplaEscolha,
│   │                             # LogAuditoriaMixin e QuizException
│   │
│   └── services/                 # Camada de Serviços, Lógica de Negócios e Persistência Local
│       ├── database_helper.dart  # Conexão SQLite (sqflite_common_ffi), DDL e operações CRUD
│       └── gerenciador_quiz.dart # Motor do quiz com coleções funcionais (.where e .fold)
│
└── test/                         # Diretório de testes automatizados
```

## Declaração de Uso de Inteligência Artificial

> **Nota de Integridade Acadêmica:**  
> Todo o projeto, modelagem conceitual orientada a objetos, arquitetura em camadas, regras de negócio do quiz adaptativo e implementação das rotinas foram concebidos e desenvolvidos pelos integrantes do grupo.  
> A Inteligência Artificial (**Gemini 3.8 Flash**, através do ambiente **Antigravity**) foi consultada como ferramenta de apoio à produtividade e revisão técnica, com o propósito de:
> 1. Evitar a digitação manual de código repetitivo (*boilerplate*);
> 2. Realizar revisão sintática de código (*code review*) já idealizado pela equipe;
> 3. Consultar recomendações de bibliotecas compatíveis com Docker e diagnosticar logs de erro de compilação.
>


---

### 1. Arquivo: `lib/models/questao.dart`
* **Estruturação Conceitual (Trabalho do Grupo):**  
  A equipe idealizou a hierarquia de classes, criando o enum `NivelDificuldade`, a classe abstrata base `Questao`, o encapsulamento do atributo privado `_pontos` com setter defensivo (rejeitando `<= 0`), e a especialização `QuestaoMultiplaEscolha`. O grupo também implementou um mixin transversal para auditoria com data/hora e de uma exceção própria de domínio (`QuizException`).
* **Assistência da IA (Aceleração de Boilerplate e Validação Sintática):**  
  A IA foi consultada para acelerar a escrita de código repetitivo (*boilerplate*), auxiliando na digitação das assinaturas dos três tipos de construtores em Dart 3 (repasse via `super`, construtor nomeado `.verdadeiroFalso` e esqueleto do `factory fromMap`), além de validar se a sintaxe do `LogAuditoriaMixin` e da `QuizException` estavam aderentes às convenções do Dart.
* **Prompt Utilizado:**  
  > *"Continue a escrita da classe concreta QuestaoMultiplaEscolha com: construtor generativo repassando super, construtor nomeado verdadeiroFalso, factory fromMap com validação defensiva de nulos, a exceção QuizException e o mixin LogAuditoriaMixin para formatar logs com timestamp."*

---

### 2. Arquivo: `lib/services/gerenciador_quiz.dart`
* **Estruturação Conceitual (Trabalho do Grupo):**  
  A equipe projetou o serviço gerenciador para armazenar a lista interna de questões, controlar a pontuação acumulada do estudante e orquestrar a sessão do quiz, incluindo a lógica pedagógica de enquadramento de proficiência (Iniciante, Intermediário e Avançado).
* **Assistência da IA (Revisão de Código e Validação Sintática):**  
  Com a lógica de negócios e as operações funcionais já implementadas pelo grupo para atender aos requisitos do trabalho, a IA foi consultada estritamente para realizar a revisão técnica do que foi escrito (*code review*). A ferramenta auxiliou na checagem da sintaxe das funções de coleção do Dart (.where(), .fold(), .every(), .any(), Spread Operators e Collection-If/For), validando a tipagem estrita e confirmando o tratamento defensivo para casos de listas vazias.
* **Prompt Utilizado:**  
  > *"Faça uma revisão técnica do código em Dart no arquivo lib/services/gerenciador_quiz.dart para validar a tipagem estrita e a sintaxe dessas operações."*

---

### 3. Arquivo: `lib/main.dart` (CLI Test Runner / Executável de Demonstração)
* **Desenvolvimento Inicial (Trabalho do Grupo):**  
  A equipe iniciou a codificação do arquivo `main.dart` montando um roteiro de testes no console para demonstrar a criação das instâncias, a persistência em banco local, as operações funcionais, a simulação de respostas do aluno e o relatório de proficiência sem depender de interface visual.
* **Assistência da IA (Auditoria de Conformidade e Revisão Técnica):**  
  O grupo forneceu à IA um documento descritivo contendo todo o passo a passo e critérios esperados para os testes práticos do trabalho. A ferramenta foi consultada para confrontar o código que já havia sido escrito pela equipe com as exigências desse documento, revisando a implementação e verificando se todas as etapas requeridas — como a validação explícita de casos de borda com blocos `try-catch` para a `QuizException` e o teste do setter de pontuação — estavam plenamente contempladas.
* **Prompt Utilizado:**  
  > *"A partir do documento enviado, analise o código presente em `lib/main.dart`, faça uma revisão técnica e verifique se está de acordo com as etapas exigidas no documento, apontando eventuais ajustes necessários. Além disso, estruture cabeçalhos e divisores visuais nos prints para que a saída no terminal fique nítida visualmente"*
---

### 4. Depuração e Resolução de Erros de Build (Troubleshooting)
* **Contexto do Problema (Trabalho do Grupo):**  
  Ao executar `dart run lib/main.dart`, o compilador retornou o erro `Error when reading 'lib/models/quiz_models.dart': No such file or directory`, impedindo a compilação.
* **Assistência da IA (Diagnóstico Pontual):**  
  A equipe enviou a mensagem de erro para a IA, que rapidamente diagnosticou que o arquivo havia sido nomeado pelo grupo como `questao.dart`, mas o caminho de importação mantinha o nome antigo `quiz_models.dart`. O grupo realizou a correção imediata do caminho relativo.
* **Prompt Utilizado:**  
  > *"Executei `dart run lib/main.dart` e obtive o erro 'No such file or directory' ao ler lib/models/quiz_models.dart."*

---

### 5. Evolução Arquitetural: Persistência Local com SQLite
* **Estruturação Conceitual (Trabalho do Grupo):**  
  A equipe decidiu evoluir a persistência temporária em memória para um banco de dados relacional em disco, viabilizando o paradigma *offline-first*.
* **Assistência da IA (Consulta Técnica de Biblioteca e Revisão de Assinaturas):**  
  O grupo consultou a IA para saber qual biblioteca permitia rodar SQLite em console Dart puro e contêiner Linux sem depender de canais nativos de celular (a IA recomendou o `sqflite_common_ffi`).
* **Prompt Utilizado:**  
  > *"Quero evoluir a persistência das questões para SQLite utilizando o ambiente atual (console/Docker). Como fazer isso?"*

---

### 6. Evolução Arquitetural: Persistência Local com SQLite (lib\services\dataBase_helper.dart)
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

### 7. Resolução de Conflito de Resolução de Dependências (Host Windows vs Contêiner Linux)
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
### 8. Configuração de Ambiente (flutter doctor -v): Correção do Android Toolchain no Docker

**Estruturação Conceitual (Trabalho do Grupo):**
  A equipe decidiu utilizar o Docker para conteinerizar o ambiente de desenvolvimento do projeto em Flutter, garantindo o isolamento das ferramentas e dependências (como o Android SDK) sem a necessidade de instalações locais pesadas na máquina hospedeira.

**Assistência da IA (Resolução de Erros de Ambiente e Infraestrutura):**
  O grupo consultou a IA enviando os logs de execução do flutter doctor para interpretar o resultado. A dúvida principal era entender e corrigir o alerta ("!") apontado no Android toolchain dentro do contêiner. A IA esclareceu como o isolamento dos sistemas operacionais afeta as exigências do Flutter e indicou a correção exata no Dockerfile (atualizando o Android SDK para a versão 36 e o BuildTools para 28.0.3) para compatibilizar com a versão do Flutter recém-baixada.

**Prompt Utilizado:**
  >*"Resultado do flutter doctor dentro do container: [log com o "!" no Android toolchain]. Me explique porque"*

---

### 9. Documentação Técnica: `README.md`
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



