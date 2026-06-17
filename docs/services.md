# Documentação da Camada de Serviços – Fortivus

## 1. Visão Geral

A camada de Serviços (`/services`) é o cérebro do aplicativo Fortivus.  
Ela contém a lógica de negócio, orquestra a comunicação com a API remota, gerencia o banco de dados local e lida com as regras de autenticação e sincronização.  
Esta camada atua como uma ponte entre a interface do usuário (Pages) e as fontes de dados.

Cada serviço possui uma responsabilidade única e bem definida:

- **AuthService:** Controla o acesso, gerenciando identidade do usuário, sessões e tokens para os modos online e offline.
- **LocalDbService:** Pilar da funcionalidade offline, gerenciando todo o ciclo de vida do banco SQLite.
- **RegistroService:** Repositório de dados, decide de forma inteligente se busca as ocorrências da API remota ou do banco local.
- **SyncService:** Motor de sincronização, responsável por enviar dados gerados offline para o servidor quando a conexão é restaurada.

---

## 2. `auth_service.dart`

Este serviço é o componente central para segurança e gerenciamento de sessão do Fortivus.  
Implementado como Singleton, garante que exista apenas uma instância gerenciando a autenticação em todo o app, evitando conflitos e estados inconsistentes.

### 2.1. Responsabilidades Detalhadas

#### Orquestração de Autenticação (Online e Offline)

O `AuthService` é responsável por decidir como o usuário vai se autenticar, com base na conectividade.

- **Login Online (`login()`):**
  - Utiliza a biblioteca `flutter_appauth` para iniciar o fluxo de login padrão do Keycloak, redirecionando o usuário para a tela de autenticação institucional.
  - Após sucesso, recebe os tokens (`access_token`, `refresh_token`, `id_token`) e os armazena de forma segura usando `flutter_secure_storage`.
  - Utiliza o `access_token` para buscar dados completos do usuário na API Fortivus (`/auth/me`).
  - Invoca `LocalDbService.saveUser()` para persistir os dados do usuário no banco local, criando e armazenando a senha para o futuro acesso offline (hashed).

- **Login Offline (`loginOffline()`):**
  - Acionado quando o app está sem internet, recebe identificador (matrícula, email, etc.) e senha digitados pelo usuário.
  - Repassa as credenciais para `LocalDbService.authenticateUserOffline()`, que compara a senha fornecida com o hash guardado no banco.
  - Se a validação for positiva, estabelece uma "sessão offline" (`is_offline_session`), permitindo o acesso ao app.

#### Gerenciamento Inteligente de Sessão e Tokens

Manter o usuário conectado de forma segura e transparente é a principal tarefa deste serviço.

- **Verificação de Sessão (`isAuthenticated()`):**
  - Verifica se existe um `access_token` armazenado.
  - Utiliza a biblioteca `jwt_decoder` para checar se o token está expirado ou prestes a expirar (próximos 5 minutos).

- **Renovação Automática de Token (`renewToken()`):**
  - Se o `access_token` está perto de expirar, usa o `refresh_token` (de validade mais longa) para solicitar silenciosamente um novo token ao Keycloak, sem necessidade de login manual.
  - Garante experiência fluida e sem interrupções.
  - Possui travas de segurança (`_isTokenRenewalInProgress`, `_canAttemptRenewal`) para evitar múltiplas tentativas simultâneas de renovação.

- **Obtenção Segura do Token (`getAccessToken()`):**
  - Método utilizado por outros serviços (ex: `RegistroService`) para obter o token antes de chamada à API.
  - Contém lógica para verificar validade, renovar se necessário e devolver o token válido.

#### Gerenciamento de Logout e Erros

- **Logout (`logout()`):**
  - Realiza limpeza completa via `_clearSessionData()`, apagando tokens do `secureStorage` e flags de sessão do `SharedPreferences`.
  - Se online, tenta se comunicar com o endpoint de logout do Keycloak para invalidar a sessão no servidor, garantindo logout mais seguro.
  - Importante: Dados do usuário no `LocalDbService` não são apagados, permitindo futuros logins offline.

- **Notificação de Erros (`onAuthError`):**
  - Utiliza um `StreamController` (`_authErrorController`) para criar canal de comunicação.
  - Se renovação de token falhar (ex: expiração do `refresh_token`), emite um "sinal de erro" neste canal.
  - A `HomePage`, que escuta este canal, recebe o sinal e mostra o banner para o usuário fazer login online novamente.

---

## 3. `local_db_service.dart`

Este serviço é o pilar da funcionalidade **Offline-First** do aplicativo. Ele encapsula toda a interação com o banco de dados SQLite, garantindo que o restante do aplicativo não precise conhecer os detalhes de implementação do SQL. Todos os seus métodos são estáticos, funcionando como uma classe utilitária de acesso direto aos dados.

### 3.1. Responsabilidades Detalhadas

#### Gerenciamento do Ciclo de Vida do Banco de Dados

- **Inicialização (`_initDb()`):**
  - Responsável por abrir o arquivo `app_database.db`.
  - Controla a criação inicial do esquema (`onCreate`) e as futuras atualizações (`onUpgrade`).

- **Versionamento e Migração (`_upgradeDatabase()`):**
  - Lógica robusta para atualizar o esquema do banco de dados de forma incremental.
  - Para cada nova versão do app que exige alteração no banco, uma nova função `_upgradeToV_()` é adicionada.
  - Garante que usuários com versões antigas possam atualizar sem perder dados locais.

- **Criação de Tabelas (`_createAllTables()`):**
  - Define a estrutura SQL das três tabelas principais: `users`, `registros` e `respostas_pendentes`.

- **Otimização (`_createIndexes()`):**
  - Cria índices em colunas frequentemente consultadas (como `userId`, `situacao`, `registroId`).
  - Acelera buscas e melhora performance da interface.

---

#### Operações de Dados do Usuário

- **`saveUser(User user)`:**
  - Persiste os dados de um usuário no banco local.
  - Chamado pelo `AuthService` após login online bem-sucedido.

- **`authenticateUserOffline(identifier, password)`:**
  - Coração do login offline.
  - Busca usuário pelo identificador (matrícula ou email) e usa a biblioteca bcrypt para comparar de forma segura a senha fornecida com o hash armazenado (`hashedPassword`).
  - Evita o armazenamento de senhas em texto plano.

- **`getLoggedUser()`:**
  - Recupera do banco os dados completos do usuário com sessão ativa (online ou offline).

---

#### Operações de Dados de Ocorrências e Respostas

- **`saveRegistros(List<Registro> registros, ...)`:**
  - Salva ou atualiza uma lista de ROs vindos da API na tabela `registros`.

- **`getOfflineRegistrosPaginated(...)`:**
  - Consulta paginada na tabela `registros` baseada nos filtros aplicados pelo usuário na tela.
  - Principal fonte de dados para as listas de ocorrências.

- **`salvarRespostaPendente(...)`:**
  - Orquestra o salvamento de um formulário respondido em modo offline.
  - Serializa os dados do formulário e lista de caminhos dos arquivos para JSON e insere na tabela `respostas_pendentes` (funciona como "caixa de saída" para o `SyncService`).

- **`getRespostasPendentes()`:**
  - Retorna lista de respostas aguardando envio ao servidor.

---

## 4. `registro_service.dart`

Atua como uma camada de abstração (um "repositório") para o acesso aos dados dos Registros de Ocorrência. As telas não sabem se os dados vêm da internet ou do banco local; elas apenas pedem os dados a este serviço.

### 4.1. Responsabilidades Detalhadas

#### Repositório de Dados (Online/Offline Fallback)

- **`consultarRegistros(...)`:**
  - Método central de busca de dados.
  - Verifica a conectividade do dispositivo.
  - **Se online:** monta os parâmetros de consulta e chama a API (`/consultar`) usando o `AuthHttpHelper`.
    - Em caso de sucesso, salva os resultados no banco local (`LocalDbService.saveRegistros`) para manter o cache atualizado antes de retornar os dados para a tela.
  - **Se offline** (ou se a chamada à API falhar): recorre automaticamente ao `LocalDbService.getOfflineRegistrosPaginated()`, garantindo acesso aos dados mais recentes salvos no dispositivo.

#### Sincronização e Cache de Dados

- **`sincronizarTodosRegistros()`:**
  - Método proativo para garantir que o cache local seja espelho fiel do servidor.
  - Busca a contagem total de registros do usuário na API e, em seguida, busca todos de uma vez.
  - **Debounce e Throttling:**  
    - A sincronização possui um "debounce" (`_syncDebounceTimer`) que aguarda curto período de inatividade antes de iniciar.
    - Um "throttle" (`_minSyncInterval`) impede novas sincronizações logo após uma ter sido concluída.

- **Atualização do Cache (`_updateLocalCache`):**
  - Após buscar todos os registros online, salva-os no banco local, sobrescrevendo dados existentes para garantir consistência.

#### Gerenciamento de Cache de Usuário

- **`_getLoggedUserSub()`:**
  - Evita consultas repetidas ao banco para obter o ID do usuário logado.
  - Implementa cache simples em memória (`_cachedUserSub`) com tempo de validade (`_cacheValidityTime`), melhorando performance.

#### Otimização de Consultas

- **`getTotalPendentes()` / `getTotalEncerrados()`:**
  - Métodos usados pelo dashboard, otimizados para performance.
  - Em vez de baixar lista completa de registros, solicitam à API apenas uma página de tamanho 1 (`size: 1`) e leem o campo `totalItems` da resposta.
  - Obtêm a contagem total de forma rápida e com baixo consumo de dados.

---

# 5. responder_combateincendio_service.dart

Este serviço é dedicado a gerenciar todo o ciclo de vida da resposta de um formulário, desde o salvamento inicial até o envio para o servidor. Ele implementa a lógica crucial de fallback para o modo offline.

---

## 5.1. Responsabilidades Detalhadas

### Orquestrador de Respostas (Online/Offline Fallback)

- **`salvarCombateIncendio(...)`**:  
  Método principal e orquestrador do serviço.
  - **Verifica a Conectividade**: Usa o pacote `connectivity_plus` para determinar se o dispositivo está online.
  - **Tenta o Envio Online**: Se houver conexão, tenta enviar os dados do formulário (`_enviarResposta`) e os arquivos (`_enviarArquivos`) diretamente para a API.  
    Em caso de sucesso, atualiza o status do registro local para `"ENCERRADA"` e o processo termina.
  - **Fallback para Offline**:  
    Se o dispositivo estiver offline ou se a tentativa de envio falhar (ex: erro de rede, servidor indisponível), o fluxo automaticamente executa o salvamento local.
  - **Salvamento Local (`_salvarLocalmente`)**:  
    Chama o `LocalDbService` para salvar a resposta na tabela `respostas_pendentes` e atualiza o status do registro para `"RESPONDIDO_OFFLINE"`.

---

### Gerenciamento de Upload de Arquivos

- **`_enviarArquivos(...)`**:  
  Lida com o processo de upload de imagens para o servidor.
  - **Requisição Multipart**: Constrói uma requisição `http.MultipartRequest`, padrão para envio de arquivos.
  - **Autenticação**:  
    Diferente das requisições JSON (que usam o `AuthHttpHelper`), este método obtém o token de acesso diretamente do `AuthService` e insere manualmente no cabeçalho da requisição.
  - **Processamento em Lote**:  
    Adiciona todos os arquivos selecionados pelo usuário à mesma requisição para um upload eficiente.

---

### Sincronização de Respostas Pendentes

- **`sincronizarRespostasPendentes()`**:  
  Método chamado pelo `SyncService` quando a conexão com a internet é restabelecida.
  - **Busca Pendências**:  
    Consulta o `LocalDbService` para obter a lista de respostas com status `"PENDENTE"` ou `"ERRO"`.
  - **Processamento em Fila**:  
    Itera sobre cada resposta pendente e tenta enviá-la para o servidor usando os métodos `_enviarResposta` e `_enviarArquivos`.
  - **Atualização de Status**:  
    Se o envio for bem-sucedido, atualiza o status da resposta para `"SINCRONIZADO"` e o do registro para `"ENCERRADA"`.  
    Se falhar, o status da resposta é atualizado para `"ERRO"`, para que possa ser tentado novamente mais tarde.
  - **Controle de Concorrência**:  
    Utiliza uma flag (`_isSincronizando`) para garantir que apenas um processo de sincronização ocorra por vez.

---

# 6. sync_service.dart

Este serviço atua como o motor de sincronização do aplicativo. Ele opera de forma autônoma para garantir que os dados salvos localmente sejam enviados ao servidor assim que possível. É implementado com métodos estáticos, funcionando como um serviço de background que pode ser iniciado e parado.

---

## 6.1. Responsabilidades Detalhadas

### Gerenciamento do Ciclo de Sincronização

- **`iniciarSincronizacao()`**:  
  Inicializa o serviço, configurando dois gatilhos principais:
  - **Listener de Conectividade**:  
    Usa o `connectivity_plus` para "ouvir" mudanças no status da rede. Assim que uma conexão é detectada, dispara uma tentativa de sincronização.
  - **Timer Periódico**:  
    Um Timer é configurado para disparar a cada 15 minutos (`_syncInterval`), garantindo que, mesmo com o app aberto e conectado, ele tente sincronizar os dados periodicamente.

### Controle de Concorrência e Performance

- **Flag de Execução (`_isSyncInProgress`)**:  
  Garante que apenas uma operação de sincronização ocorra por vez, evitando chamadas duplicadas e possíveis condições de corrida.

- **Debounce (`_debounceSync`)**:  
  Para evitar múltiplas mudanças rápidas de conectividade disparando várias sincronizações em sequência, utiliza um Timer de debounce. Aguarda 2 segundos de "calmaria" na rede antes de iniciar o processo, otimizando uso de bateria e rede.

---

### Orquestração da Lógica de Envio

- **`_sincronizarRespostasPendentes()`**:  
  O coração do serviço, responsável por:
  - Verificar se há conexão.
  - Buscar respostas pendentes no `LocalDbService.getRespostasPendentes()`.
  - **Delegar o Envio**:  
    Em vez de implementar a lógica de envio HTTP, delega para o `ResponderCombateIncendioService.sincronizarRespostasPendentes()`.  
    Isso mantém boa separação de responsabilidades: o `SyncService` decide quando sincronizar, o `ResponderCombateIncendioService` sabe como sincronizar.

---

### Controle Manual

- **`forceSyncNow()`**:  
  Permite que outras partes do app (como o `AuthService` após login bem-sucedido) forcem uma tentativa de sincronização imediata, pulando timers e debounces.

- **`stopSync()`**:  
  Encerra todos os timers e listeners, parando completamente o serviço de sincronização.

---