# Documentação da Camada de Utilitários – Fortivus

## 1. Visão Geral

A camada de **Utilitários** (`/util`) agrupa classes e funções auxiliares que executam tarefas específicas e reutilizáveis em várias partes do aplicativo.  
O objetivo deste diretório é encapsular lógicas complexas ou repetitivas em um único local, mantendo o resto do código (como as Pages e Services) mais limpo e focado em suas responsabilidades principais.

---

## 2. `auth_http_helper.dart`

Esta classe é um wrapper sobre o pacote http padrão do Dart.  
Sua principal função é interceptar todas as requisições HTTP feitas para a API do Fortivus e anexar automaticamente o token de autenticação, além de gerenciar a renovação desse token de forma transparente.

### 2.1. Responsabilidades Detalhadas

- **Injeção Automática de Token:**  
  Antes de qualquer requisição ser enviada, o `AuthHttpHelper` chama `AuthService().getAccessToken()`. Este método já contém a lógica para verificar se o token está válido ou se precisa ser renovado. Isso garante que cada requisição saia do aplicativo com um token válido no cabeçalho Authorization.

- **Centralização da Lógica de Requisição:**  
  O método privado `_makeRequest` centraliza toda a lógica. Ele obtém o token, monta os cabeçalhos (headers) e então executa a função de requisição específica (GET, POST, etc.) que foi passada como argumento.

- **Tratamento de Erros de Autenticação:**  
  Se, mesmo após a verificação, a API retornar um erro 401 Unauthorized (o que pode acontecer em casos raros, como a revogação do token no servidor), o helper chama `AuthService().logout()` para forçar o logout e limpar a sessão do usuário, garantindo a segurança.

- **Simplificação das Chamadas:**  
  Fornece métodos públicos e estáticos (`get`, `post`, `put`, `delete`) que espelham os do pacote http, permitindo que os serviços façam chamadas de API de forma simples e direta, sem se preocuparem com a lógica de autenticação.

---

## 3. `map_launcher_util.dart`

Esta classe utilitária abstrai a complexidade de interagir com aplicativos de mapa externos (como Google Maps e Waze) a partir do Flutter.

### 3.1. Responsabilidades Detalhadas

- **Exibição de Opções (`openMapsDialog`):**  
  Em vez de abrir um mapa diretamente, o método principal exibe um `AlertDialog` para o usuário, permitindo que ele escolha qual aplicativo de navegação prefere usar (Google Maps ou Waze). Isso melhora a experiência do usuário.

- **Construção de URLs Específicas:**  
  Cada aplicativo de mapa requer um formato de URL diferente para abrir e iniciar a navegação para um par de coordenadas. Os métodos privados `_launchGoogleMaps` e `_launchWaze` são responsáveis por construir essas URLs corretamente.

- **Lançamento de Apps Externos:**  
  Utiliza o pacote `url_launcher` para abrir as URLs construídas. O `mode: LaunchMode.externalApplication` garante que o aplicativo de mapa seja aberto fora do Fortivus, como o usuário esperaria.

- **Validação:**  
  Antes de tentar abrir a URL, ele verifica se o aplicativo correspondente está instalado no dispositivo (`canLaunchUrl`), evitando erros.

---

## 4. `app_restart_notifier.dart`

Este arquivo fornece um mecanismo simples, mas eficaz, para forçar a reconstrução da árvore de widgets do aplicativo a partir da raiz (`MyApp`).

### 4.1. Propósito e Funcionamento

Em cenários complexos, como um logout onde o estado de autenticação muda fundamentalmente, pode ser necessário garantir que todo o aplicativo seja "redesenhado" para refletir essa nova realidade.

- **ValueNotifier Global:**  
  Ele cria um `ValueNotifier` global que armazena uma `UniqueKey`.

- **Função `restartApp()`:**  
  Quando esta função é chamada, ela simplesmente atribui uma nova `UniqueKey` ao notifier.

- **Mecanismo de Escuta:**  
  O widget raiz do aplicativo (`MyApp`) "escuta" as mudanças neste notifier. Quando o valor (a Key) muda, o Flutter entende que o widget precisa ser completamente reconstruído, o que, por sua vez, força a reconstrução de todas as telas filhas, reavaliando o estado de autenticação inicial na `SplashPage`.

---