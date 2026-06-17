# Documentação Técnica – Aplicativo Fortivus

## 1. Introdução

### 1.1. Visão Geral do Fortivus
O Fortivus é um aplicativo móvel desenvolvido para o Corpo de Bombeiros Militar do Estado de Mato Grosso (CBMMT). Sua principal função é permitir que os militares responsáveis por ocorrências possam preencher e registrar todas as informações pertinentes ao atendimento diretamente do local, de forma rápida e eficiente.

O aplicativo foi projetado com uma arquitetura Offline-First, garantindo que as operações críticas de registro de dados possam ser realizadas mesmo em locais remotos sem acesso à internet, como zonas rurais ou áreas de desastre.

### 1.2. Objetivo do Documento
Este documento descreve a arquitetura técnica, as funcionalidades, o fluxo de dados e as tecnologias utilizadas no desenvolvimento do aplicativo Fortivus. Ele serve como um guia de referência para a equipe de desenvolvimento, manutenção e futuros colaboradores do projeto.

### 1.3. Público-Alvo
Este documento é destinado a desenvolvedores, arquitetos de software e gestores de tecnologia envolvidos com o aplicativo Fortivus.

---

## 2. Arquitetura do Sistema

### 2.1. Visão Geral da Arquitetura
O Fortivus é composto por duas partes principais:

- **Aplicativo Móvel (Cliente):** Desenvolvido em Flutter, responsável pela interface com o usuário, coleta de dados e armazenamento local.
- **Módulo de Combate (Servidor Web):** O backend que centraliza as informações, recebe os dados sincronizados do aplicativo e gerencia o despacho das ocorrências.

A comunicação entre o cliente e o servidor ocorre via APIs RESTful, garantindo a integração e a consistência dos dados.

### 2.2. Arquitetura Offline-First
A capacidade de funcionar offline é o pilar central do Fortivus. Isso é alcançado através da seguinte estratégia:

- **Banco de Dados Local:** Todas as informações recebidas e geradas pelo usuário (Registros de Ocorrência, respostas de formulários, mídias) são armazenadas localmente em um banco de dados SQLite.
- **Fila de Sincronização:** As alterações e novos registros são mantidos em uma "fila" de sincronização. O aplicativo periodicamente verifica a disponibilidade de uma conexão com a internet.
- **Sincronização Automática:** Ao detectar uma conexão ativa, o aplicativo inicia o processo de envio dos dados pendentes para o servidor (Módulo de Combate) e atualiza o status local dos registros para "sincronizado".

### 2.3. Tecnologias Utilizadas

- **Linguagem de Programação:** Dart
- **Framework:** Flutter
- **Banco de Dados Local:** SQLite (gerenciado através do plugin sqflite)
- **Autenticação Online:** Integração com Keycloak (via OAuth 2.0/OpenID Connect)
- **Comunicação com API:** Pacote http 

---

# 3. Funcionalidades Detalhadas por Tela

O fluxo de interação do usuário no aplicativo é dividido nas seguintes telas principais:

---

## 3.1. Tela de Login (`login_page.dart`)

A porta de entrada do aplicativo com comportamento adaptativo à conectividade do dispositivo.

- **Detecção de Conexão:** Verificação ativa do status da internet.
- **Login Online:**  
  - Exibe o botão "Entrar com Keycloak" quando há conexão.
  - Redireciona para o fluxo de autenticação institucional.
  - Após autenticação, força sincronização de dados pendentes.
- **Login Offline:**  
  - Na ausência de internet, apresenta formulário para credenciais (Email/Matrícula/CPF e senha).
  - Validação local contra dados salvos no primeiro login online.

---

## 3.2. Tela Principal / Dashboard (`home_page.dart`)

Após o login, o usuário é direcionado para o dashboard central, que serve como menu principal.

- **Contadores de Ocorrências:**
  - **PENDENTES:** Mostra a contagem de Registros de Ocorrência (ROs) aguardando resposta.
  - **ENCERRADOS:** Mostra a contagem de ROs já respondidos e/ou sincronizados.
- **Atualização Automática:**  
  - Timer atualiza os contadores periodicamente.
  - Notificação (SnackBar) exibida em caso de novo RO detectado.
- **Gerenciamento de Sessão:**  
  - Controla o estado da sessão do usuário.
  - Banner é exibido se a sessão expirar (erro 401), instruindo o login online novamente.
- **Navegação:**  
  - Permite acesso às listas de ocorrências pendentes e encerradas.

---

## 3.3. Consulta de Ocorrências Pendentes (`consulta_registros_page.dart`)

Tela que lista todos os ROs com status "ABERTA", aguardando resposta do militar.

- **Listagem e Filtragem:**  
  - Exibição em lista (cards).
  - Filtro por ID do Registro ou ID da Ordem de Serviço.
- **Ações por Ocorrência:**  
  - **Navegar:** Abre aplicativo de mapas (Google Maps/Waze) com coordenadas da ocorrência.
  - **Detalhes:** Abre tela `DetalhesRegistroPage` para informações completas do RO (guarnição, viatura, militares escalados, descrição inicial).
  - **Responder:** Inicia preenchimento do formulário na tela `ResponderCombateIncendioPage`.

---

## 3.4. Preenchimento do Formulário de Ocorrência (`responder_combate_incendio_page.dart`)

Tela central para coleta dos dados da ocorrência atendida. O formulário é dividido em seções:

- **Dados da Pessoa Atendida:**  
  - Nome, documento, telefone, município.
- **Informações de Combate:**  
  - Múltipla seleção para ações de combate realizadas, órgãos de apoio, áreas de atuação (urbana/rural/...), materiais utilizados.
  - Seleção única para causa provável do incêndio.
- **Descrições e Resultados:**  
  - Campos de texto livre para descrição detalhada da operação e resultado.
- **Anexo de Arquivos:**  
  - Permite anexar imagens da galeria ou capturadas pela câmera.
- **Salvamento Local:**  
  - Ao clicar em "Salvar", dados são validados e armazenados no banco SQLite local, prontos para sincronização.

---

## 3.5. Consulta de Ocorrências Encerradas (`consulta_registros_encerrados_page.dart`)

Lista os ROs que já foram respondidos pelo militar.

- **Listagem e Filtragem:**  
  - Similar à tela de pendentes.
  - Filtro por ID do Registro ou da Ordem de Serviço.
- **Ação Principal:**  
  - Cada card possui a ação "Visualizar".
- **Visualizar:**  
  - Navega para a tela `VisualizarRespostaPage`, exibindo os dados preenchidos no formulário de modo somente leitura, incluindo as imagens anexadas.

---

# 4. Estrutura do Banco de Dados Local (SQLite)

O banco de dados local é estruturado em três tabelas principais para garantir o isolamento dos dados e o funcionamento offline.

---

## 4.1. Tabela `users`

Armazena as informações de todos os militares que já realizaram login no dispositivo. Isso permite a autenticação offline e a associação correta dos registros.

| Nome da Coluna          | Tipo de Dado | Descrição                                                        |
|-------------------------|--------------|------------------------------------------------------------------|
| id                      | TEXT         | Chave Primária (PK), UUID do usuário no sistema de origem.       |
| sub                     | TEXT         | Identificador único do usuário vindo do Keycloak. UNIQUE, NOT NULL. |
| nome                    | TEXT         | Nome completo do militar.                                        |
| email                   | TEXT         | E-mail institucional. UNIQUE.                                    |
| telefone                | TEXT         | Número de telefone do militar.                                   |
| dataNascimento          | TEXT         | Data de nascimento no formato ISO8601.                           |
| matricula               | TEXT         | Matrícula do militar. UNIQUE.                                    |
| cpf                     | TEXT         | CPF do militar. UNIQUE.                                          |
| nomeGuerra              | TEXT         | Nome de guerra do militar.                                       |
| posto                   | TEXT         | Posto/Graduação do militar.                                      |
| unidade                 | TEXT         | Unidade de lotação do militar.                                   |
| rg                      | TEXT         | RG do militar.                                                   |
| perfil                  | TEXT         | Perfil de acesso do usuário.                                     |
| dataAdmissao            | TEXT         | Data de admissão no formato ISO8601.                             |
| hashedPassword          | TEXT         | Hash da senha (gerado com BCrypt) para autenticação offline.      |
| token                   | TEXT         | Token de acesso JWT para a sessão online atual.                  |
| expiracaoToken          | TEXT         | Data de expiração do token no formato ISO8601.                   |
| comandoRegionalId       | TEXT         | ID do Comando Regional.                                          |
| comandoRegionalNome     | TEXT         | Nome do Comando Regional.                                        |
| failedAttempts          | INTEGER      | Contador de tentativas de login offline falhas.                  |
| accountLocked           | INTEGER      | Flag (0 ou 1) que indica se a conta está bloqueada para login offline. |

---

## 4.2. Tabela `registros`

Contém todos os Registros de Ocorrência (ROs) baixados do servidor e associados a um usuário específico.

| Nome da Coluna               | Tipo de Dado | Descrição                                                     |
|------------------------------|--------------|---------------------------------------------------------------|
| id                           | TEXT         | Chave Primária (PK), ID do Registro de Ocorrência.           |
| userId                       | TEXT         | Chave Estrangeira (FK) que referencia users.sub. NOT NULL.    |
| ordemServico                 | TEXT         | ID da Ordem de Serviço associada. NOT NULL.                   |
| dataCriacaoFormatada         | TEXT         | Data e hora em que o RO foi criado.                           |
| dataPreenchimentoFormatada   | TEXT         | Data e hora em que o formulário foi respondido.               |
| cicloGuarnicao               | TEXT         | Informações gerais sobre a guarnição.                         |
| cicloGuarnicaoGuarnicao      | TEXT         | Nome da guarnição.                                            |
| cicloGuarnicaoVeiculo        | TEXT         | Identificação do veículo.                                     |
| cicloGuarnicaoComandante     | TEXT         | Nome do comandante da guarnição.                              |
| cicloGuarnicaoPostoComandante| TEXT         | Posto do comandante.                                          |
| cicloGuarnicaoCondutor       | TEXT         | Nome do condutor da viatura.                                  |
| cicloGuarnicaoPostoCondutor  | TEXT         | Posto do condutor.                                            |
| categoriaDescricao           | TEXT         | Descrição da categoria da ocorrência (ex: "Combate a Incêndio").|
| descricao                    | TEXT         | Descrição inicial da ocorrência vinda do servidor. NOT NULL.  |
| situacao                     | TEXT         | Status do RO (ex: 'ABERTA', 'ENCERRADA', 'RESPONDIDO_OFFLINE'). NOT NULL.|
| usuario                      | TEXT         | ID do usuário responsável pelo atendimento.                   |
| latitudeRo                   | REAL         | Latitude da ocorrência.                                       |
| longitudeRo                  | REAL         | Longitude da ocorrência.                                      |
| militares                    | TEXT         | String JSON contendo a lista de militares da guarnição.       |
| comandoRegionalNome          | TEXT         | Nome do Comando Regional da ocorrência.                       |
| viaturaModelo                | TEXT         | Modelo da viatura.                                            |
| viaturaIdentificador         | TEXT         | Prefixo/Identificador da viatura.                             |
| isSynced                     | INTEGER      | Flag (0 ou 1) que indica se o registro está sincronizado com o servidor. |

---

## 4.3. Tabela `respostas_pendentes`

Funciona como uma fila de saída. Armazena as respostas dos formulários que foram preenchidas offline e aguardam sincronização com o servidor.

| Nome da Coluna   | Tipo de Dado | Descrição                                                   |
|------------------|--------------|-------------------------------------------------------------|
| id               | INTEGER      | Chave Primária (PK) com autoincremento.                    |
| registroId       | TEXT         | Chave Estrangeira (FK) que referencia registros.id. NOT NULL.|
| dados            | TEXT         | String JSON contendo todas as respostas do formulário. NOT NULL.|
| arquivosPath     | TEXT         | String JSON com os caminhos locais dos arquivos de mídia anexados.|
| status           | TEXT         | Status da sincronização (ex: 'PENDENTE', 'ERRO').           |
| dataCriacao      | TEXT         | Data e hora em que a resposta foi salva localmente. NOT NULL.|
| tentativasSinc   | INTEGER      | Contador de tentativas de sincronização.                    |
| ultimaTentativa  | TEXT         | Data e hora da última tentativa de sincronização.           |

---

# 5. Fluxo de Dados Detalhado

O fluxo de dados do Fortivus foi projetado para cobrir todo o ciclo de vida de uma ocorrência, desde o seu despacho até a sincronização da resposta final.

---

## 5.1. Etapa 1: Despacho da Ocorrência (Módulo Web)

- **Criação:**  
  Na Sala de Situação, um operador cria uma Ordem de Serviço no Módulo Web.

- **Registro:**  
  Dentro da Ordem de Serviço, é criado um novo Registro de Ocorrência (RO).

- **Atribuição:**  
  O operador seleciona a guarnição de serviço, a viatura e designa um militar como responsável pelo atendimento e preenchimento do RO.

- **Informações Iniciais:**  
  A localização (coordenadas) e a descrição primária da ocorrência são inseridas no RO.

- **Disponibilização:**  
  O RO é marcado como "ABERTA" e fica disponível para ser consultado pelo militar responsável via API.

---

## 5.2. Etapa 2: Recebimento e Resposta (App Fortivus)

Este fluxo se divide em dois cenários principais, dependendo da conectividade do militar.

### Cenário A: Operação Online

1. **Autenticação:**  
   O militar responsável faz login no App Fortivus usando suas credenciais institucionais via Keycloak.

2. **Sincronização de Entrada:**  
   O aplicativo faz uma requisição à API do Módulo Web e baixa os novos ROs atribuídos. Os dados são salvos na tabela `registros` do banco de dados local.

3. **Atendimento:**  
   O militar visualiza os detalhes do RO no app, se desloca para o local e realiza o atendimento da ocorrência.

4. **Preenchimento:**  
   Após o atendimento, o militar abre o RO no app e preenche o formulário de resposta com todos os detalhes da operação (dados da vítima, materiais, descrição, etc.) e anexa as mídias (fotos).

5. **Envio Imediato:**  
   Como o dispositivo está online, ao salvar, o app envia imediatamente a resposta (dados do formulário e arquivos) para a API do Módulo Web.

6. **Confirmação:**  
   O Módulo Web processa os dados, armazena a resposta e retorna um status de sucesso. A Sala de Situação já pode visualizar o relatório completo.

7. **Atualização Local:**  
   O app atualiza o status do RO local para "ENCERRADA".

---

### Cenário B: Operação Offline

1. **Dados Pré-carregados:**  
   O militar já possui os ROs em seu dispositivo, sincronizados da última vez que esteve online. Ele realiza o login offline no app usando sua senha local.

2. **Atendimento:**  
   O militar realiza o atendimento da ocorrência normalmente.

3. **Preenchimento Offline:**  
   Após o atendimento, ele preenche o formulário de resposta no App Fortivus.

4. **Armazenamento Local:**  
   Ao salvar, como não há conexão, o aplicativo:
   - Salva todos os dados do formulário como um registro na tabela `respostas_pendentes`, com o status "PENDENTE".
   - Salva as imagens no armazenamento interno do dispositivo, e seus caminhos são referenciados na tabela `respostas_pendentes`.
   - Atualiza o status do RO na tabela `registros` para "RESPONDIDO_OFFLINE", indicando que a resposta foi salva localmente mas ainda não foi enviada.

5. **Detecção de Rede:**  
   Posteriormente, quando o dispositivo se conecta a uma rede com internet, o Serviço de Sincronização do app é ativado.

6. **Sincronização Automática:**  
   O serviço busca por respostas com status "PENDENTE" na tabela `respostas_pendentes`.

7. **Envio em Fila:**  
   Ele envia os dados e os arquivos de cada resposta pendente para a API do Módulo Web.

8. **Confirmação e Limpeza:**  
   Após o Módulo Web confirmar o recebimento de uma resposta, o App Fortivus:
   - Remove o registro correspondente da tabela `respostas_pendentes`.
   - Atualiza o status do RO na tabela `registros` de "RESPONDIDO_OFFLINE" para "ENCERRADA".

---