# Documentação da Camada de Pages – Fortivus

## 1. Visão Geral

A camada de **Pages** (ou Screens) é responsável pela interface do usuário (UI) do aplicativo Fortivus. Cada arquivo `.dart` neste diretório representa uma tela completa com a qual o usuário interage.

As Pages são construídas como `StatefulWidgets` para gerenciar estados dinâmicos, como a digitação em campos de texto, o carregamento de dados e a atualização da UI em resposta às ações do usuário. Elas orquestram a apresentação dos dados obtidos da camada de Services e capturam as entradas do usuário para iniciar lógicas de negócio.

---

## 2. `consulta_registros_encerrados_page.dart`

Esta tela tem a responsabilidade de exibir uma lista paginada de todos os Registros de Ocorrência (ROs) que já foram concluídos pelo militar logado.

### 2.1. Responsabilidades Detalhadas

#### Gerenciamento de Estado e Dados

- **Inicialização (`initState` e `_initializeUserAndLoadRegistros`):**
  - Ao entrar na tela, verifica se há usuário logado, buscando informações no `LocalDbService`.
  - Se encontrado, o ID (`sub`) é armazenado no estado da tela e chama a função `_loadRegistros` para buscar a primeira página de dados.
  - Se não houver usuário, redireciona para a tela de login.

- **Carregamento de Dados (`_loadRegistros`):**
  - Método central da tela, chama `_registroService.consultarRegistros()` passando os filtros atuais, número da página e tamanho da página.
  - A situação é fixada como `'ENCERRADA'`.
  - Gerencia o estado de carregamento (exibe `CircularProgressIndicator`) e trata erros, mostrando uma `SnackBar` ao usuário.

- **Paginação:**
  - Gerencia o estado da página atual (`currentPage`) e tamanho da página (`pageSize`).
  - UI renderiza botões de paginação, e funções `_onPageChanged` e `_onPageSizeChanged` atualizam o estado e chamam `_loadRegistros`.

---

#### Interface do Usuário (UI)

- **Filtros de Busca:**
  - UI apresenta campos de texto (`TextField`) para que o usuário filtre a lista por ID do Registro ou ID da Ordem de Serviço.
  - Ao pressionar "Buscar" ou submeter o campo, a função `_loadRegistros` é acionada com os novos filtros.

- **Lista de Registros:**
  - Registros retornados pelo serviço são exibidos em uma `ListView`.
  - Cada item é um Card customizado mostrando as informações importantes do RO (ID, data, categoria).

- **Visualização de Detalhes:**
  - Cada card possui um botão "Visualizar".
  - Ao pressionar, navega para a `VisualizarRespostaPage`, passando o `registroId` para exibição do relatório completo preenchido.

- **Feedback Visual:**
  - Tela fornece feedback constante ao usuário, mostrando indicador de carregamento, mensagens de "Nenhum registro encontrado" e `SnackBars` para erros ou informações.

# 3. `consulta_registros_page.dart`

Esta é uma das telas mais importantes do fluxo de trabalho do militar, pois lista todos os Registros de Ocorrência (ROs) que estão com o status **"ABERTA"**, ou seja, que aguardam uma ação.

---

## 3.1. Responsabilidades Detalhadas

### Gerenciamento de Estado e Dados

- **Inicialização (`initState` e `_initializeUserAndLoadRegistros`):**
  - Valida a sessão do usuário buscando o `sub` no `LocalDbService`.
  - Se o usuário for válido, dispara a busca inicial de registros com o status fixo em `'ABERTA'`.

- **Carregamento de Dados (`_loadRegistros`):**
  - Invoca `_registroService.consultarRegistros()` para buscar os ROs pendentes.
  - O serviço decide se busca os dados da API (online) ou do banco local (offline), garantindo funcionamento contínuo.

- **Paginação e Ordenação:**
  - Gerencia página atual (`currentPage`) e tamanho da página (`pageSize`).
  - Controla ordenação (`isAscending`), permitindo listar os ROs mais recentes ou mais antigos primeiro.

---

### Interface do Usuário (UI) e Ações

- **Filtros e Atualização:**
  - Filtros por ID do Registro e ID da Ordem de Serviço.
  - Botão "Atualizar" para forçar nova busca de dados no serviço.

- **Lista de Ações por Registro:**
  - Cada card de registro oferece ações cruciais para o atendimento da ocorrência:
    - **Navegar:**  
      Utiliza o `MapLauncherUtil` para abrir o aplicativo de mapas padrão do dispositivo com as coordenadas do RO, facilitando o deslocamento da guarnição.
    - **Detalhes:**  
      Navega para a `DetalhesRegistroPage`, permitindo consultar todas as informações despachadas pela Sala de Situação (descrição, viatura, militares escalados, etc.) antes de iniciar o atendimento.
    - **Responder:**  
      Ação principal da tela. Navega para a `ResponderCombateIncendioPage`, passando o `registroId` para que o formulário de resposta seja preenchido. Este botão é o ponto de partida para o registro do atendimento.

- **Logout:**
  - Botão disponível na AppBar, permitindo encerrar a sessão de forma segura.

---

# 4. `detalhes_registro_page.dart`

Esta tela funciona como uma ficha de consulta **somente leitura** para um Registro de Ocorrência.  
Seu principal objetivo é apresentar ao militar todas as informações que foram originalmente despachadas pela Sala de Situação, antes que qualquer resposta seja preenchida.

---

## 4.1. Responsabilidades Detalhadas

### Gerenciamento de Estado e Dados

- **Simplicidade de Estado:**  
  - A tela é um `StatelessWidget`, pois sua única responsabilidade é exibir os dados de um objeto `Registro` recebido via construtor.
  - Não busca dados nem gerencia estados complexos; apenas renderiza as informações fornecidas.

---

### Interface do Usuário (UI) e Ações

- **Estrutura de Informação:**  
  A UI é organizada em seções claras e distintas para facilitar a leitura rápida:
  - **Informações Básicas:**  
    Exibe o ID da Ordem de Serviço, data de criação, categoria e situação atual do RO.
  - **Informações da Guarnição:**  
    Apresenta detalhes sobre a equipe, incluindo nome da guarnição, viatura (identificador e modelo) e uma lista detalhada dos militares escalados.
  - **Militares da Guarnição:**  
    Lista de militares renderizada de forma inteligente, usando `ExpansionTile` para mostrar detalhes de cada um (matrícula, nome de guerra).  
    O comandante e o condutor são visualmente destacados com ícones e cores diferentes para fácil identificação.
  - **Detalhes da Ocorrência:**  
    Mostra o militar responsável, a descrição textual da ocorrência e as coordenadas geográficas.

- **Ação Interativa:**  
  - **Abrir no Mapa:**  
    Um botão proeminente "Abrir no Mapa" está disponível se o RO contiver coordenadas válidas.  
    Utiliza o `MapLauncherUtil` para permitir que o militar inicie a navegação para o local da ocorrência diretamente da tela de detalhes.

---

# 5. `home_page.dart`

Esta tela é o **dashboard principal** do aplicativo, servindo como o ponto central de navegação após o login do usuário.  
Ela fornece uma visão geral e imediata do status das ocorrências atribuídas ao militar.

---

## 5.1. Responsabilidades Detalhadas

### Gerenciamento de Estado e Dados

- **Inicialização (`initState`):**
  - Ao carregar, inicia múltiplos processos para manter a tela sempre atualizada e reativa:
    - **`_initConnectivity()`:**  
      Configura um listener que monitora continuamente o status da rede (online/offline).
    - **`_startTimers()`:**  
      Inicia dois timers em paralelo:
        - Um timer principal (`_refreshTimer`): força atualização completa dos contadores a cada 60 segundos.
        - Um timer de verificação rápida (`_quickRefreshTimer`): a cada 10 segundos, busca apenas a contagem de pendentes para notificar o usuário sobre novos ROs quase instantaneamente.
    - **Listener de Erro de Autenticação:**  
      Inscreve-se no stream `onAuthError` do `AuthService`.  
      Se um erro de autenticação ocorrer (ex: falha na renovação do token), a tela é notificada para exibir um banner de alerta.

- **Carregamento de Contadores (`_carregarContadores`):**
  - Busca as contagens de ROs pendentes e encerrados do `RegistroService`.
  - Gerencia estado de carregamento (`_isLoading`) para feedback visual na UI.
  - Atualiza os valores de `pendentesCount` e `encerradosCount`.

---

### Interface do Usuário (UI) e Ações

- **Dashboard Visual:**
  - UI composta por dois grandes botões clicáveis:
    - **PENDENTES:**  
      Exibe contagem de ocorrências que aguardam resposta, com badge vermelho.
    - **ENCERRADOS:**  
      Exibe contagem de ocorrências finalizadas, com badge verde.

- **Navegação:**
  - Clicar em "PENDENTES" leva à `ConsultaRegistrosPage`.
  - Clicar em "ENCERRADOS" leva à `ConsultaRegistrosEncerradosPage`.
  - Após retornar dessas telas, os contadores são atualizados.

- **Notificação de Novos ROs (`_mostrarNotificacaoNovoRO`):**
  - Se o timer rápido detectar aumento no número de ocorrências pendentes, uma SnackBar verde é exibida na parte inferior, informando sobre o novo RO e oferecendo botão "VER AGORA" para navegação direta.

- **Alerta de Sessão Expirada:**
  - Se listener de erro de autenticação for acionado, um banner de alerta laranja (`_showLoginNotification`) aparece no topo, informando que a sessão expirou e fornecendo botão "Login" para reautenticação online.

---

# 6. `login_page.dart`

Esta tela é a porta de entrada do aplicativo e a primeira interação do usuário.  
Sua principal característica é a **interface adaptativa**, que muda completamente com base na conectividade do dispositivo, garantindo que o usuário possa sempre acessar o app.

---

## 6.1. Responsabilidades Detalhadas

### Gerenciamento de Estado e Lógica

- **Detecção de Conectividade (`_checkConnectivityAndAuth`, `_updateConnectivityStatus`):**
  - No `initState`, a tela verifica imediatamente o status da rede.
  - Inscreve-se em um `StreamSubscription` do `connectivity_plus` para reagir em tempo real a qualquer mudança na conexão (ex: usuário liga o Wi-Fi).
  - O estado da conexão é mantido na variável `_hasInternet`.

- **Verificação de Sessão Ativa (`_checkAuthentication`):**
  - Antes de exibir qualquer coisa, verifica com `AuthService.isAuthenticated()` se o usuário já possui uma sessão online válida.
  - Se sim, o usuário é redirecionado diretamente para a `MainPage` (provavelmente contendo a `HomePage`), pulando a etapa de login.

- **Lógica de Login Online (`_loginWithKeycloak`):**
  - Chamado ao tocar no botão "Entrar com Keycloak".
  - Toda a complexidade da autenticação é delegada ao `AuthService.login()`.
  - Após sucesso, força sincronização de dados pendentes via `SyncService.forceSyncNow()` antes de navegar para a tela principal.

- **Lógica de Login Offline (`_loginOffline`):**
  - Chamado ao preencher o formulário e tocar em "Entrar Offline".
  - Valida campos do formulário e chama `AuthService.loginOffline()`, passando identificador e senha para validação local.

---

### Interface do Usuário (UI) e Ações

- **UI Adaptativa:**
  - O método `build` contém lógica condicional que renderiza uma de duas interfaces, baseada na variável `_hasInternet`:
    - **Modo Online:**  
      Exibe interface simples com logo do Fortivus e botão "Entrar com Keycloak" para iniciar autenticação institucional.
    - **Modo Offline:**  
      Exibe formulário com campos para "Email, Matrícula ou CPF" e "Senha", além do botão "Entrar Offline".

- **Feedback de Carregamento:**
  - Variável de estado `_isLoading` desabilita botões de login e exibe `CircularProgressIndicator` durante operações de autenticação.
  - Previne cliques duplos e informa o usuário que há uma operação em andamento.

- **Mensagens de Alerta:**
  - Tela pode receber e exibir mensagens de alerta (`alertMessage`) vindas de outras telas (ex: da `HomePage` quando sessão expira).
  - Mostra um `MaterialBanner` no topo para fornecer contexto ao usuário.

---

# 7. `main_page.dart`

Esta tela atua como o **container principal** ou "shell" da aplicação após um login bem-sucedido.  
Sua função não é exibir conteúdo próprio, mas sim hospedar a tela principal (`HomePage`) e gerenciar ações globais como o logout e a confirmação de saída do aplicativo.

---

## 7.1. Responsabilidades Detalhadas

### Gerenciamento de Estado e Lógica

- **Logout (`_logout`):**
  - Fornece uma função de logout segura.
  - Ao ser acionada, exibe um indicador de progresso.
  - Chama `AuthService.logout()` para limpar a sessão e os tokens.
  - Redireciona o usuário para a `LoginPage`, removendo todas as telas anteriores da pilha de navegação.

---

### Interface do Usuário (UI) e Ações

- **Hospedagem de Conteúdo:**
  - O `body` da tela é fixado para exibir a `HomePage`, tornando-a a view principal do app após o login.

- **Controle de Saída do App (`PopScope`):**
  - Utiliza o widget `PopScope` para interceptar o gesto de "voltar" do sistema Android.
  - Em vez de fechar o app imediatamente, exibe um diálogo de confirmação ("Sair do aplicativo?").
  - Previne que o usuário saia acidentalmente, melhorando a experiência de uso.

---

# 8. `responder_combate_incendio_page.dart`

Esta é a tela de entrada de dados mais complexa do aplicativo.  
Ela apresenta um formulário detalhado para que o militar registre todas as informações pertinentes a uma ocorrência de combate a incêndio.

---

## 8.1. Responsabilidades Detalhadas

### Gerenciamento de Estado e Dados

- **Controladores de Formulário:**  
  Utiliza múltiplos `TextEditingController` para capturar entradas de texto do usuário (nome, documento, descrições etc.).  
  Para campos de seleção múltipla, são usados `Sets` (como `_tiposAcaoSelecionados`) para armazenar opções escolhidas.

- **Seleção de Mídia (`_selecionarArquivos`):**  
  Integra-se com o pacote `image_picker` para permitir seleção de imagens da galeria ou foto com câmera.  
  Arquivos selecionados são mantidos em uma lista (`_arquivosSelecionados`) no estado da tela.

- **Lógica de Salvamento (`_salvarRegistro`):**
  - **Validação:**  
    Valida o formulário (`_formKey.currentState?.validate()`) para garantir que todos os campos obrigatórios foram preenchidos.
  - **Coleta de Dados:**  
    Coleta valores de controladores e Sets, organizando tudo em um `Map<String, dynamic>` (`dados`), que representa o payload.
  - **Delegação:**  
    Chama `ResponderCombateIncendioService.salvarCombateIncendio()` passando ID do registro, dados do formulário e lista de arquivos.  
    Não se preocupa se o salvamento será online ou offline; essa lógica é do serviço.
  - **Navegação:**  
    Após sucesso, fecha a tela (`Navigator.of(context).pop(true)`) e retorna `true` para a tela anterior atualizar a lista de pendentes.

---

### Interface do Usuário (UI)

- **Estrutura do Formulário:**  
  Organizada em seções lógicas, cada uma dentro de um `Card`, facilitando o preenchimento:
  - **Dados da Pessoa Atendida:**  
    Campos de texto para informações básicas.
  - **Informações de Combate:**  
    Campos de seleção, incluindo widget customizado `_buildMultiSelectDropdown` que exibe diálogo com checkboxes para melhor experiência em campos de múltipla escolha.
  - **Descrições e Resultados:**  
    Campos de texto de múltiplas linhas para descrições detalhadas.
  - **Upload de Arquivos:**  
    Botões para "Galeria" e "Câmera" e lista de miniaturas das imagens selecionadas, com opção de remoção.
  - **Validação e Feedback:**  
    Campos obrigatórios marcados com asterisco vermelho e usam a propriedade `validator` dos `TextFormFields` para exibir mensagens de erro caso não sejam preenchidos.

---

# 9. `splash_page.dart`

Esta é a primeira tela que o usuário vê ao abrir o aplicativo.  
Sua função é atuar como uma tela de carregamento e roteamento inicial, decidindo para qual tela o usuário deve ser direcionado.

---

## 9.1. Responsabilidades Detalhadas

### Gerenciamento de Estado e Lógica

- **Inicialização (`initState` e `_checkAuthStatusAndNavigate`):**
  - Assim que construída, inicia o processo de verificação:
    - **Garante a Inicialização do BD:**  
      Executa `await LocalDbService.database`, forçando a inicialização do banco SQLite para garantir que todas as consultas seguintes funcionarão.
    - **Verifica a Sessão:**  
      Chama `AuthService().isAuthenticated()` para verificar se o usuário já possui um token de sessão válido.
    - **Navegação:**  
      - Se autenticado, navega para `MainPage`.
      - Se não autenticado, navega para `LoginPage`.
    - Um `Future.delayed` de 1 segundo é usado para garantir que a tela de splash seja visível por um curto período, melhorando a percepção de carregamento para o usuário.

---

### Interface do Usuário (UI)

- **Tela de Carregamento:**  
  UI minimalista, exibindo apenas um `CircularProgressIndicator` e o texto "Carregando...".  
  Informa ao usuário que o aplicativo está preparando os dados necessários antes de exibir a interface principal.

---

# 10. `visualizar_resposta_page.dart`

Esta tela tem a função de exibir um relatório completo e **somente leitura** de um RO que já foi respondido.  
Ela é a contraparte de visualização da tela `responder_combate_incendio_page`.

---

## 10.1. Responsabilidades Detalhadas

### Gerenciamento de Estado e Dados

- **Busca de Dados Assíncrona:**  
  - No `initState`, inicia a busca dos dados da resposta chamando `_service.getResposta()`, passando o `registroId` recebido.
  - O resultado é armazenado em uma variável `Future<RespostaCombateIncendio>`.

- **Renderização com FutureBuilder:**  
  - O corpo da tela é envolvido por um `FutureBuilder`, que gerencia os diferentes estados da requisição:
    - **Carregando:**  
      Exibe um `CircularProgressIndicator` enquanto os dados estão sendo buscados.
    - **Erro:**  
      Mostra uma mensagem clara se a busca falhar.
    - **Sucesso:**  
      Quando os dados são recebidos com sucesso (`snapshot.hasData`), o `FutureBuilder` constrói a UI do relatório com as informações da resposta.

---

### Interface do Usuário (UI) e Ações

- **Estrutura de Relatório:**  
  UI organizada em seções dentro de `Cards` para facilitar a leitura:
  - **Pessoa Atendida:**  
    Exibe dados da pessoa/vítima informados no formulário.
  - **Recursos e Ações Utilizados:**  
    Lista todas as seleções feitas nos campos de múltipla escolha (ações, áreas, apoio, materiais).
  - **Detalhes da Operação:**  
    Mostra textos descritivos e a causa provável do incêndio.
  - **Fotos e Anexos:**  
    Se houver imagens, exibe uma `ListView` horizontal com as miniaturas.

- **Visualizador de Imagens Interativo:**
  - **`_showImageDialog`:**  
    Ao tocar em uma miniatura, abre um diálogo em tela cheia exibindo a imagem em alta resolução.
  - **Zoom:**  
    O diálogo utiliza o widget `InteractiveViewer`, permitindo zoom e exploração dos detalhes das fotos, funcionalidade importante para análise de ocorrências.

---