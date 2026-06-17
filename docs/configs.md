# Documentação da Camada de Configuração – Fortivus

## 1. Visão Geral

A camada de **Config** (`/config`) é responsável por centralizar as variáveis e configurações que podem mudar dependendo do ambiente em que o aplicativo está sendo executado (Desenvolvimento, Homologação, Produção).

Manter essas configurações em um local separado do código da lógica de negócio é uma prática fundamental para facilitar a compilação de diferentes versões do aplicativo sem a necessidade de alterar o código-fonte.

---

## 2. `environment_config.dart`

Este arquivo é o ponto central para gerenciar as variáveis de ambiente do aplicativo.  
Ele utiliza o construtor `String.fromEnvironment` do Dart, uma técnica poderosa que permite injetar valores diferentes durante o processo de compilação.

### 2.1. Propósito e Funcionamento

Quando o aplicativo é compilado para diferentes ambientes (como homologação ou produção), um comando de build pode passar valores para essas variáveis. Por exemplo:

```shell
flutter build apk --dart-define=ISSUER=https://url-de-producao.com
```

Se nenhum valor for passado durante a compilação, o `defaultValue` é utilizado, o que é ideal para o ambiente de desenvolvimento local.

### 2.2. Variáveis Definidas

- **ISSUER:**  
  Armazena a URL base do servidor de autenticação Keycloak.  
  É a partir desta URL que o AuthService descobre os endpoints de login, token e logout.  
  **Valor Padrão:**  
  `https://authh.beaifmt.com.br/realms/hom` (Ambiente de Homologação)

- **API_BASE_URL:**  
  Armazena a URL base da API do Módulo de Combate, para onde todas as requisições de dados (como buscar registros e enviar respostas) são direcionadas.  
  **Valor Padrão:**  
  `https://combateh.beaifmt.com.br/api` (Ambiente de Homologação)

---

# 3. `keycloak_config.dart`

Este arquivo atua como um centralizador de todas as constantes e configurações necessárias para a comunicação com o servidor de autenticação Keycloak.  
Centralizar essas informações em uma única classe evita a repetição de código e facilita a manutenção, já que qualquer alteração nos endpoints ou credenciais do cliente precisa ser feita em um único lugar.

---

## 3.1. Responsabilidades e Constantes

- **issuer:**  
  A URL base do servidor Keycloak, importada do `EnvironmentConfig`.  
  É a partir dela que a biblioteca `openid_client` descobre automaticamente os outros endpoints necessários (autorização, token, etc.).

- **clientId:**  
  O identificador único do aplicativo Fortivus dentro do Keycloak.  
  É como o servidor sabe qual cliente está tentando se autenticar.

- **scopes:**  
  Define as permissões que o aplicativo solicita ao usuário durante o login (ex: `openid`, `profile`, `email`), que determinam quais informações (claims) estarão disponíveis no token.

- **redirectUri:**  
  A URL para a qual o Keycloak redirecionará o usuário após a autenticação ser bem-sucedida.  
  O esquema (`com.fortivus.app`) é um link profundo que reabre o aplicativo Fortivus.

- **getClient():**  
  Um método utilitário que usa a URL do `issuer` para descobrir a configuração completa do provedor OpenID e retorna um objeto Client pronto para ser usado pelo AuthService para iniciar o fluxo de autenticação.

---