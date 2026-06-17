# Documentação do Ponto de Entrada – `main.dart`

## 1. Visão Geral

O arquivo `main.dart` é o ponto de entrada principal da aplicação Fortivus.  
Sua responsabilidade é realizar todas as inicializações críticas e assíncronas antes de desenhar a interface do usuário.  
Além disso, define o widget raiz (`MyApp`), que encapsula toda a estrutura do aplicativo.

---

## 2. Função `main()`

Esta é a função executada pelo Dart quando o aplicativo é iniciado.

- **`WidgetsFlutterBinding.ensureInitialized()`:**  
  Garante que o framework do Flutter esteja pronto para uso antes de qualquer outra operação. Essencial para chamadas assíncronas subsequentes.

- **`_initializeApp()`:**  
  Chama a função de inicialização principal, responsável por preparar o banco de dados e os serviços de background.

- **`runApp(const MyApp())`:**  
  Após a inicialização bem-sucedida, constrói e exibe o widget `MyApp`, raiz da árvore de widgets da aplicação.

- **Tratamento de Erros Críticos:**  
  Um bloco `try-catch` envolve o processo de inicialização. Caso ocorra um erro fatal durante a preparação do banco de dados, o aplicativo exibe uma tela amigável de erro, informando o problema ao usuário, em vez de travar.

---

## 3. Função `_initializeApp()`

Orquestra as tarefas de preparação que precisam ser concluídas antes que o app esteja pronto para uso.

- **Reset e Migração do Banco de Dados:**  
  Verifica a versão salva do banco de dados no `SharedPreferences`.  
  Se a versão for mais antiga que a esperada, chama `LocalDbService.resetarBancoDados()` para apagar e recriar o banco de dados com o esquema mais recente.  
  Isso garante que mudanças estruturais sejam aplicadas a todos os usuários ao atualizarem o app.

- **Inicialização dos Serviços:**  
  - `LocalDbService.database`: Garante a conexão com o banco de dados SQLite.
  - `SyncService.iniciarSincronizacao()`: Inicia o serviço de sincronização em segundo plano, monitorando conectividade.
  - **Sincronização Imediata:**  
    Verifica se há respostas pendentes no banco local e, se houver, chama `SyncService.forceSyncNow()` para tentar enviá-las imediatamente.

---

## 4. Widget `MyApp`

Widget raiz da aplicação.

- **Gerenciamento do Ciclo de Vida:**  
  No método `dispose`, chama `SyncService.stopSync()` para garantir que timers e listeners de sincronização sejam encerrados corretamente ao fechar o app.

- **Mecanismo de Reinicialização:**  
  No `initState`, configura um listener para o `appRestartNotifier`.  
  O `ValueListenableBuilder` no método `build` garante que, ao chamar `restartApp()` em qualquer lugar, toda a `MaterialApp` será reconstruída, forçando uma reavaliação completa do estado de autenticação.

- **Roteamento Inicial (`_buildAuthWrapper`):**  
  Decide qual tela o usuário verá primeiro com base na autenticação.  
  Utiliza um `FutureBuilder` para chamar `AuthService().isAuthenticated()`:
  - Enquanto a verificação está em andamento, exibe uma tela de carregamento.
  - Se o usuário estiver autenticado, navega para a `MainPage`.
  - Se não estiver autenticado, navega para a `LoginPage`.

---