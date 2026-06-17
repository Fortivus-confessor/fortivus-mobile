# Documentação da Camada de Enums – Fortivus

## 1. Visão Geral

A camada de **Enums** (`/enums`) é responsável por definir conjuntos de constantes nomeadas que representam opções fixas no aplicativo, principalmente nos formulários de resposta.  
O uso de enums em vez de Strings puras aumenta a segurança do código, evita erros de digitação e torna a intenção do código mais clara.

Esta camada é composta por dois arquivos principais que trabalham em conjunto:

- **enums.dart:**  
  Define os próprios enums, ou seja, as listas de opções válidas (ex: `TipoAreaAtuacao.RURAL`, `TipoAreaAtuacao.URBANA`).

- **enum_extensions.dart:**  
  Adiciona funcionalidades extras à classe String para permitir a conversão segura de texto (vindo da API ou do banco de dados) para um dos enums definidos.

---

# 2. `enums.dart`

Este arquivo funciona como um ponto de acesso central para todas as enumerações do aplicativo.  
Em vez de importar cada arquivo de enum individualmente nas telas ou serviços, basta importar este único arquivo para ter acesso a todas as definições.

---

## 2.1. Propósito e Vantagens

O uso de um arquivo "barril" como este simplifica as importações e melhora a organização do projeto.  
As enumerações em si oferecem várias vantagens:

- **Segurança de Tipo:**  
  Evita o uso de Strings "mágicas", que são propensas a erros de digitação. O compilador pode verificar se os valores usados são válidos.

- **Consistência de Dados:**  
  Garante que os dados enviados para a API correspondam exatamente às opções esperadas pelo backend.

- **Facilidade de Manutenção:**  
  Se novas opções precisarem ser adicionadas ou removidas, a alteração é feita em um único local (no arquivo de enum específico), e o compilador Dart ajudará a encontrar todos os locais no código que precisam ser atualizados.

---

## 2.2. Enumerações Exportadas

O arquivo `enums.dart` exporta as seguintes definições:

- `TipoAcaoCombateIncendio`
- `TipoAreaAtuacao`
- `TipoApoioOrgao`
- `TipoMateriaisUtilizados`
- `TipoCausaIncendio`

Cada enum possui uma propriedade `descricao` que fornece um texto amigável para ser exibido na interface do usuário (UI), enquanto o valor do próprio enum (`.name`) é usado para a comunicação com a API, mantendo a UI e a lógica de dados desacopladas.

---

## 3. `enum_extensions.dart`

Este arquivo utiliza um recurso poderoso do Dart chamado **Extensions** para adicionar novos métodos à classe String.  
O objetivo é criar conversores seguros que transformam uma String (por exemplo, "RURAL") no seu enum correspondente (`TipoAreaAtuacao.RURAL`).

### 3.1. Responsabilidades Detalhadas

#### Conversão Segura de String para Enum

O principal problema ao lidar com dados externos é que uma String vinda de uma API pode não corresponder a nenhum valor de enum esperado (pode ser nula, vazia ou ter um valor inesperado).  
Tentar uma conversão direta causaria um erro e travaria o aplicativo.

O `enum_extensions.dart` resolve isso com a extensão **StringToEnum**, que adiciona métodos como `toTipoAcaoCombateIncendio()`, `toTipoApoioOrgao()`, etc.

#### Funcionamento dos Métodos de Conversão

Cada método segue um padrão de segurança:

- **Busca (`firstWhere`):**  
  Itera sobre todos os valores possíveis do enum (ex: `TipoAcaoCombateIncendio.values`).
- **Comparação:**  
  Tenta encontrar o primeiro valor cujo nome (`e.name`) seja exatamente igual à String que está sendo convertida.
- **Fallback (`orElse`):**  
  Se nenhum valor correspondente for encontrado, em vez de gerar erro, o `orElse` é acionado e retorna um valor padrão pré-definido (geralmente `NENHUM` ou `SEM_INDICIOS_CAUSA`).

Essa abordagem garante que a conversão de String para enum nunca falhará, tornando o aplicativo mais robusto e resiliente a dados inconsistentes vindos do backend.

---

# 4. `municipios_mato_grosso.dart`

Este arquivo define um enum abrangente, `MunicipiosMT`, que contém a lista completa de todos os municípios do estado de Mato Grosso.

---

## 4.1. Propósito e Vantagens

- **Fonte Única da Verdade:**  
  Centraliza a lista de municípios em um único local, garantindo que todos os campos de seleção de cidade no aplicativo usem as mesmas opções padronizadas.

- **Dados Amigáveis para UI:**  
  Cada valor do enum (ex: `aguaBoa`) armazena uma String `nome` (ex: 'Água Boa') já formatada corretamente para exibição em menus `DropdownButtonFormField` e outros componentes da interface.

- **Simplicidade e Performance:**  
  Por ser um enum, a lista é compilada junto com o aplicativo, tornando o acesso e a exibição das opções extremamente rápidos, sem a necessidade de buscar esses dados de um banco de dados ou de uma API.

---

# 5. `tipo_acao_combate.dart`

Este arquivo define o enum `TipoAcaoCombateIncendio`, que padroniza as opções de ações que podem ser registradas durante uma operação de combate a incêndio.

---

## 5.1. Propósito e Vantagens

- **Padronização de Relatórios:**  
  Garante que todas as respostas de ocorrência usem a mesma terminologia para as ações realizadas, facilitando a análise de dados e a geração de relatórios estatísticos.

- **Clareza na Interface:**  
  A propriedade `descricao` de cada enum fornece um texto claro e completo para ser exibido nos menus de seleção do formulário, melhorando a usabilidade para o militar.

- **Desacoplamento:**  
  O valor do enum (`.name`, ex: `COMBATE_INCENDIO_FLORESTAL_DIRETO`) é usado para lógica interna e comunicação com a API, enquanto a `descricao` ("Combate Incêndio Florestal Direto") é usada apenas para exibição, separando dados da apresentação.

---

## 5.2. Opções Definidas

| Valor do Enum                        | Descrição (Exibido na UI)                 |
|-------------------------------------- |-------------------------------------------|
| NENHUM                               | Nenhum                                    |
| COMBATE_INCENDIO_FLORESTAL_DIRETO    | Combate Incêndio Florestal Direto         |
| CONFECCAO_ACEIRO_MANUAL              | Confecção Aceiro Manual                   |
| CONFECCAO_ACEIRO_MECANICO            | Confecção Aceiro Mecânico                 |
| REALIZACAO_FOGO_CONTRA_FOGO          | Realização Fogo Contra Fogo               |
| VIGILANCIA                           | Vigilância                                |
| RESCALDO                             | Rescaldo                                  |

---

# 6. `tipo_apoio_orgao.dart`

Este arquivo define o enum `TipoApoioOrgao`, que lista os possíveis órgãos e instituições que podem dar apoio em uma ocorrência.

---

## 6.1. Propósito e Vantagens

- **Registro Padronizado:**  
  Garante que o registro de apoio de outras agências seja consistente em todos os relatórios, utilizando siglas e nomes padronizados.

- **Facilidade de Seleção:**  
  Fornece uma lista pré-definida e clara para o militar selecionar no formulário, agilizando o preenchimento.

- **Análise de Dados:**  
  Permite a extração de dados estatísticos sobre quais órgãos mais colaboram com o Corpo de Bombeiros em diferentes tipos de ocorrências.

---

## 6.2. Opções Definidas

| Valor do Enum    | Descrição (Exibido na UI) |
|------------------|--------------------------|
| NENHUM           | Nenhum                   |
| DEFESA_CIVIL     | Defesa Civil             |
| FORCAS_ARMADAS   | Forças Armadas           |
| GM               | GM                       |
| IBAMA            | IBAMA                    |
| ICMBIO           | ICMBIO                   |
| PJC              | PJC                      |
| PM               | PM                       |
| POLITEC          | POLITEC                  |
| PREFEITURA       | Prefeitura               |
| PRF              | PRF                      |
| SEMA             | SEMA                     |

---

# 7. `tipo_area_atuacao.dart`

Este arquivo define o enum `TipoAreaAtuacao`, que categoriza as diferentes frentes de trabalho em um incêndio.

---

## 7.1. Propósito e Vantagens

- **Terminologia Técnica:**  
  Utiliza termos técnicos padrão do combate a incêndios (Cabeça, Flanco, Retaguarda), garantindo que os relatórios sejam precisos e compreensíveis para outros profissionais da área.

- **Registro Estruturado:**  
  Permite que o militar registre de forma estruturada em quais partes do incêndio a guarnição atuou, fornecendo dados valiosos para a análise pós-ocorrência.

- **Clareza no Formulário:**  
  As descrições amigáveis ("Cabeça Incêndio") facilitam a seleção correta pelo usuário no aplicativo.

---

## 7.2. Opções Definidas

| Valor do Enum      | Descrição (Exibido na UI) |
|--------------------|--------------------------|
| NENHUM             | Nenhum                   |
| RETAGUARDA         | Retaguarda               |
| CABECA_INCENDIO    | Cabeça Incêndio          |
| FLANCO_DIREITO     | Flanco Direito           |
| FLANCO_ESQUERDO    | Flanco Esquerdo          |

---

# 8. `tipo_causa_incendio.dart`

Este arquivo define o enum `TipoCausaIncendio`, que lista as causas prováveis de um incêndio a serem selecionadas no formulário.

---

## 8.1. Propósito e Vantagens

- **Análise Criminológica e Estatística:**  
  Padronizar as causas é fundamental para a inteligência do Corpo de Bombeiros, permitindo identificar padrões, como áreas com maior incidência de incêndios criminosos ("Incendiário") ou problemas com infraestrutura ("Rede elétrica").

- **Orientação no Preenchimento:**  
  Oferece ao militar uma lista de opções claras e diretas, facilitando a classificação da ocorrência.

- **Consistência de Dados:**  
  Garante que a mesma causa seja sempre registrada da mesma forma, melhorando a qualidade dos dados para análises futuras.

---

## 8.2. Opções Definidas

| Valor do Enum         | Descrição (Exibido na UI)    |
|-----------------------|------------------------------|
| RAIO                  | Raio                         |
| REDE_ELETRICA         | Rede elétrica                |
| USO_IRREGULAR_FOGO    | Uso irregular do fogo        |
| ACIDENTE_VEICULO      | Acidente veicular            |
| INCENDIARIO           | Incendiário                  |
| SEM_INDICIOS_CAUSA    | Sem indícios de causa        |

---

# 9. `tipo_materiais_utilizados.dart`

Este arquivo define o enum `TipoMateriaisUtilizados`, que cataloga os equipamentos e ferramentas que podem ser empregados em uma ocorrência.

---

## 9.1. Propósito e Vantagens

- **Controle de Recursos:**  
  Padroniza o registro do uso de materiais, essencial para controle de inventário, logística e planejamento de reposição de equipamentos.

- **Análise de Emprego:**  
  Permite analisar quais equipamentos são mais utilizados em determinados tipos de ocorrência, auxiliando decisões estratégicas sobre aquisição e distribuição de materiais.

- **Agilidade no Preenchimento:**  
  Fornece uma lista de opções comuns, evitando que o militar precise digitar manualmente cada item utilizado.

---

## 9.2. Opções Definidas

| Valor do Enum     | Descrição (Exibido na UI) |
|-------------------|--------------------------|
| NENHUM            | Nenhum                   |
| SOPRADOR          | Soprador                 |
| KIT_COMBATE       | Kit combate              |
| MOTOSSERRA        | Motosserra               |
| MOCHILA_COSTAL    | Mochila costal           |
| MOTOBOMBA         | Motobomba                |
| FOICE             | Foice                    |
| ENXADA            | Enxada                   |
| RASTELO           | Rastelo                  |
| ABAFADOR          | Abafador                 |
| PINGA_FOGO        | Pinga fogo               |
| DRONE             | Drone                    |

---