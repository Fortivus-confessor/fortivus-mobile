# Documentação da Camada de Models – Fortivus

## 1. Visão Geral

A camada de **Models** (`/models`) é a fundação que define a estrutura de dados do aplicativo Fortivus.  
Cada arquivo `.dart` neste diretório representa uma entidade de negócio, como um `Registro`, um `User` ou uma `RespostaCombateIncendio`.

### Responsabilidades das Classes de Modelo

- **Definir a Estrutura:**  
  Listar todas as propriedades e seus tipos de dados (ex: `String`, `int`, `List`).
- **Encapsular Dados:**  
  Agrupar informações relacionadas em um único objeto, facilitando a passagem de dados entre as camadas do aplicativo.
- **Serialização e Desserialização:**  
  Fornecer lógica para converter os dados de e para diferentes formatos, essencial para comunicação com API (JSON) e banco de dados local (Map).

#### Principais Métodos de Serialização

- `factory NomeDaClasse.fromJson(Map<String, dynamic> json)`: Constrói objeto a partir de um mapa JSON vindo da API.
- `factory NomeDaClasse.fromMap(Map<String, dynamic> map)`: Constrói objeto a partir de um mapa do banco SQLite.
- `Map<String, dynamic> toMap()`: Converte o objeto em um mapa para inserção/atualização no banco de dados local.

---

## 2. `registro.dart`

Esta é uma das classes de modelo mais centrais do aplicativo, representando um **Registro de Ocorrência (RO)**.  
Contém todos os detalhes de uma ocorrência despachada pela Sala de Situação, necessários para que o militar possa entender e atender ao chamado.

### 2.1. Propriedades Principais

A classe `Registro` encapsula diversas informações sobre a ocorrência:

- **Identificadores:**  
  - `id` (ID do RO),  
  - `ordemServico` (ID da OS)
- **Informações Temporais:**  
  - `dataCriacaoFormatada`,  
  - `dataPreenchimentoFormatada`
- **Dados da Guarnição:**  
  - `cicloGuarnicaoGuarnicao` (nome da equipe),  
  - `cicloGuarnicaoVeiculo`,  
  - `cicloGuarnicaoComandante`,  
  - `cicloGuarnicaoCondutor`,  
  - e os postos correspondentes
- **Detalhes da Ocorrência:**  
  - `categoriaDescricao`,  
  - `descricao` (histórico inicial),  
  - `situacao` ('ABERTA', 'ENCERRADA', etc.),  
  - `latitudeRo`/`longitudeRo` para geolocalização
- **Dados de Associação:**
  - `militares`: `List<Usuario>` com todos os militares escalados para a guarnição
  - `userId`: sub do usuário responsável, usado para ligar o registro ao usuário no banco local

---

### 2.2. Lógica de Negócio e Métodos

A classe não apenas armazena dados, mas também contém métodos úteis para manipulação e apresentação:

- **fromJson(Map<String, dynamic> json):**  
  Constrói um objeto `Registro` a partir da resposta JSON da API, lidando com conversão de tipos e desserialização da lista aninhada de militares.
- **fromMap(Map<String, dynamic> map):**  
  Constrói um objeto `Registro` a partir dos dados do banco SQLite, decodificando a string JSON da coluna militares para uma `List<Usuario>`.
- **toMap():**  
  Converte o objeto `Registro` em um mapa para inserção no SQLite, serializando a lista de militares para uma string JSON.
- **getComandante() e getCondutor():**  
  Métodos inteligentes que analisam a lista de militares e, com base nos nomes e postos, identificam e retornam o objeto `Usuario` correspondente ao comandante e ao condutor, com lógicas de fallback para garantir que sempre haja um resultado se a informação existir.
- **hasValidCoordinates():**  
  Método auxiliar simples que verifica se as coordenadas de latitude e longitude não são nulas, usado para decidir se o botão "Navegar" deve ser exibido na UI.

---

# 3. `resposta_combate_incendio.dart`

Este arquivo define o modelo de dados para a resposta de um formulário de combate a incêndio.  
Ele representa todas as informações que o militar coleta em campo e que serão salvas localmente ou enviadas ao servidor.

---

## 3.1. Propriedades Principais

A classe `RespostaCombateIncendio` armazena os dados preenchidos pelo usuário, que complementam as informações do Registro original:

- **Dados da Pessoa Atendida:**  
  - `nomePessoaAtendida`
  - `documentoPessoaAtendida`
  - `telefonePessoaAtendida`
  - `municipioPessoaAtendida`

- **Relatório Descritivo:**  
  - `resultadoDia`
  - `descricaoOperacao`

- **Dados de Múltipla Escolha:**
  - `tipoAcaoCombate`
  - `tipoAreaAtuacao`
  - `tipoApoioOrgao`
  - `tipoMaterialUtilizados`  
  > Todas são listas de `EnumDescricao`, uma classe auxiliar que armazena o código e a descrição de cada item selecionado.

  - `tipoCausaIncendio`: Um único objeto `EnumDescricao` para a causa provável.

- **Anexos:**  
  - `arquivos`: Uma `List<String>` contendo os nomes dos arquivos de imagem associados a esta resposta.

---

## 3.2. Lógica de Negócio e Métodos

- **fromJson(Map<String, dynamic> json):**  
  Constrói um objeto `RespostaCombateIncendio` a partir de um JSON.  
  Este método é particularmente robusto:
  - **parseEnumList:**  
    Função interna inteligente que desserializa listas de seleção múltipla, seja uma lista de Strings ou uma lista de objetos Map (com código e descrição).  
    Torna o app resiliente a variações no backend.
  - **Valores Padrão:**  
    Garante que campos de texto nunca sejam nulos, atribuindo "Não informado" caso a chave não exista no JSON, prevenindo erros na UI.

- **toJson():**  
  Converte o objeto `RespostaCombateIncendio` de volta para um mapa JSON, pronto para ser enviado como corpo de requisição HTTP para a API.  
  Serializa corretamente as listas de `EnumDescricao` para o formato esperado pelo servidor.

---

# 4. `user.dart`

Esta classe modela a entidade **Usuário**, representando um militar no sistema.  
Ela é fundamental para autenticação, autorização e associação dos registros de ocorrência ao militar correto.

---

## 4.1. Propriedades Principais

A classe `User` armazena um conjunto completo de informações sobre o militar:

- **Identificadores Únicos:**
  - `id`: UUID do usuário no banco de dados central (PostgreSQL).
  - `sub`: Identificador único do usuário no Keycloak. Campo chave para relacionamentos no banco local.
  - `matricula`, `cpf`, `email`: Outros identificadores usados para login e referência.

- **Dados Pessoais:**
  - `nome`
  - `nomeGuerra`
  - `dataNascimento`
  - `rg`
  - `telefone`

- **Dados Funcionais:**
  - `posto`
  - `unidade`
  - `perfil`
  - `dataAdmissao`
  - `comandoRegionalId`

- **Dados de Sessão e Segurança:**
  - `token`: access_token JWT da sessão online atual.
  - `expiracaoToken`: Data de expiração do token.
  - `hashedPassword`: Hash da senha gerado via BCrypt, para autenticação offline.

---

## 4.2. Lógica de Negócio e Métodos

- **fromMap(Map<String, dynamic> map):**
  - Constrói um objeto `User` a partir dos dados do banco SQLite.
  - Garante que o campo `sub` seja sempre preenchido, construindo-o a partir do `id` se necessário.

- **toMap():**
  - Converte o objeto `User` em um mapa para ser salvo no SQLite.
  - Extrai o `sub` do token JWT se ainda não estiver presente, garantindo persistência do identificador principal.

- **fromJson(Map<String, dynamic> json):**
  - Constrói um objeto `User` a partir dos dados vindos da API (`/auth/me`).
  - Garante extração e preenchimento corretos dos identificadores `id` e `sub`.

- **extractUserIdFromSub(String? sub):**
  - Método utilitário estático que extrai o UUID do usuário (`id`) a partir da string completa do `sub` do Keycloak (formato: `f:realm-id:user-uuid`).

---