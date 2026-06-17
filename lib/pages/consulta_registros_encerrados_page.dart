import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/pages/combate_incendio/aereo/visualizar_combate_aereo_page.dart';
import 'package:fortivus_app/pages/combate_incendio/maquinario/visualizar_combate_incendio_maquinario_page.dart';
import 'package:fortivus_app/pages/conscientizacao_educacao_ambiental/visualizar_conscientizacao_page.dart';
import 'package:fortivus_app/pages/formacao_brigadista_florestal/visualizar_formacao_brigadista_florestal_page.dart';
import 'package:fortivus_app/pages/ronda/visualizar_ronda_page.dart';
import 'package:flutter/material.dart';
import 'package:fortivus_app/model/registro.dart';
import 'package:fortivus_app/pages/registro_page.dart';
import 'package:fortivus_app/services/registro_service.dart';
import 'package:fortivus_app/pages/combate_incendio/terrestre/visualizar_combate_terrestre_page.dart';
import '../services/local_db_service.dart';
import 'login_page.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class ConsultaRegistrosEncerradosPage extends StatefulWidget {
  const ConsultaRegistrosEncerradosPage({super.key});

  @override
  State<ConsultaRegistrosEncerradosPage> createState() =>
      _ConsultaRegistrosEncerradosPageState();
}

class _ConsultaRegistrosEncerradosPageState
    extends State<ConsultaRegistrosEncerradosPage> {
  // Filtros
  final TextEditingController _registroIdController = TextEditingController();
  final TextEditingController _ordemServicoIdController =
      TextEditingController();
  String? _categoria;
  final String _situacao = 'ENCERRADA'; // Sempre Encerrada nesta tela
  RegistroPage? _pagina;
  int currentPage = 0;
  int pageSize = 10;
  bool isAscending = false;
  final RegistroService _registroService = RegistroService();
  String? _loggedUserApiId;

  @override
  void initState() {
    super.initState();
    _initializeUserAndLoadRegistros();
  }

  Widget _getStatusIcon(String situacao) {
    switch (situacao) {
      case 'RESPONDIDO_OFFLINE':
        return const Tooltip(
          message: 'Aguardando sincronização',
          child: Icon(Icons.cloud_off_rounded, color: Colors.amber, size: 20),
        );
      case 'ENCERRADA':
      default:
        return const Tooltip(
          message: 'Sincronizado',
          child: Icon(Icons.cloud_done_rounded, color: Colors.green, size: 20),
        );
    }
  }

  Future<void> _initializeUserAndLoadRegistros() async {
    try {
      final user = await LocalDbService.getLoggedUser();
      if (user?.sub == null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Sessão expirada. Por favor, faça login novamente.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
      setState(() {
        _loggedUserApiId = user!.sub;
      });
      _loadRegistros();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar sessão: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  List<Registro> get registros {
    if (_pagina?.content == null) {
      return [];
    }
    final lista = List<Registro>.from(_pagina!.content);
    lista.sort((a, b) {
      final aNaoSincronizado = a.situacao == 'RESPONDIDO_OFFLINE';
      final bNaoSincronizado = b.situacao == 'RESPONDIDO_OFFLINE';
      if (aNaoSincronizado && !bNaoSincronizado) {
        return -1;
      }
      if (!aNaoSincronizado && bNaoSincronizado) {
        return 1;
      }
      return 0;
    });
    return lista;
  }

  int get totalPages => _pagina?.totalPages ?? 1;
  int get totalItems => _pagina?.totalItems ?? 0;

  Future<void> _loadRegistros() async {
    if (_loggedUserApiId == null) {
      return;
    }
    setState(() {
      _pagina = null;
    });
    try {
      final pagina = await _registroService.consultarRegistros(
        // ✅ Converte o texto para int. Se estiver vazio ou inválido, retorna null automático.
        registroId: int.tryParse(_registroIdController.text),

        // ✅ Converte o texto para int. Se estiver vazio ou inválido, retorna null automático.
        ordemServicoId: int.tryParse(_ordemServicoIdController.text),

        categoria: _categoria,
        situacao: _situacao,
        page: currentPage,
        size: pageSize,
        sort: isAscending ? "asc" : "desc",
      );

      setState(() {
        _pagina = pagina;
      });

      if (pagina.totalItems == 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum registro histórico encontrado.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _pagina = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Nenhum histórico encontrado offline. Conecte-se para buscar antigos.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _navegarParaDetalhes(Registro registro) {
    final categoria = registro.categoriaDescricao.toUpperCase().trim();
    final categoriaNormalizada = _removerAcentos(categoria);
    Widget? paginaDestino;

    if (categoriaNormalizada.contains("TERRESTRE")) {
      paginaDestino = VisualizarCombateTerrestrePage(registroId: registro.id);
    } else if (categoriaNormalizada.contains("AEREO")) {
      paginaDestino = VisualizarCombateAereoPage(registroId: registro.id);
    } else if (categoriaNormalizada.contains("MAQUINARIO")) {
      paginaDestino = VisualizarCombateMaquinarioPage(registroId: registro.id);
    } else if (categoriaNormalizada.contains("RONDA")) {
      paginaDestino = VisualizarRondaPage(registroId: registro.id);
    } else if (categoriaNormalizada.contains("CONSCIENTIZACAO") ||
        categoriaNormalizada.contains("EDUCACAO_AMBIENTAL")) {
      paginaDestino = VisualizarConscientizacaoPage(registroId: registro.id);
    } else if (categoriaNormalizada.contains("FORMACAO") ||
        categoriaNormalizada.contains("BRIGADISTA") ||
        categoriaNormalizada.contains("FLORESTAL")) {
      // ✅ NOVO: Navegação para Visualizar Formação Brigadista
      paginaDestino = VisualizarFormacaoBrigadistPage(registroId: registro.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Visualização para "$categoria" ainda não implementada.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => paginaDestino!),
    );
  }

  String _removerAcentos(String str) {
    const comAcento =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const semAcento =
        'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';
    for (int i = 0; i < comAcento.length; i++) {
      str = str.replaceAll(comAcento[i], semAcento[i]);
    }
    return str;
  }

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _loadRegistros();
  }

  Widget _getCategoriaIcon(String categoria) {
    final cat = categoria.toUpperCase();

    if (cat.contains('RONDA')) {
      return const Icon(Icons.security, color: Colors.teal, size: 20);
    } else if (cat.contains('MAQUINÁRIO') || cat.contains('MAQUINARIO')) {
      return const Icon(Icons.agriculture, color: Colors.orange, size: 20);
    } else if (cat.contains('AÉREO') || cat.contains('AEREO')) {
      return const Icon(Icons.airplanemode_active,
          color: Colors.blue, size: 20);
    } else if (cat.contains('TERRESTRE') || cat.contains('COMBATE')) {
      return const Icon(Icons.directions_car, color: Colors.brown, size: 20);
    } else if (cat.contains('CONSCIENTIZAÇÃO') ||
        cat.contains('CONSCIENTIZACAO') ||
        cat.contains('EDUCAÇÃO_AMBIENTAL') ||
        cat.contains('EDUCACAO_AMBIENTAL')) {
      return const Icon(Icons.eco, color: Colors.green, size: 20);
    } else if (cat.contains('FORMAÇÃO') ||
        cat.contains('FORMACAO') ||
        cat.contains('BRIGADISTA') ||
        cat.contains('FLORESTAL')) {
      // ✅ NOVO: Icon para Formação Brigadista
      return const Icon(Icons.school, color: Colors.purple, size: 20);
    } else if (cat.contains('FISCALIZAÇÃO') || cat.contains('FISCALIZACAO')) {
      return const Icon(Icons.search, color: Colors.orange, size: 20);
    }

    return const Icon(Icons.info_outline, size: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Muda para roxo escuro em homologação, preto em produção
        backgroundColor: EnvironmentConfig.isHomologacao ? Colors.deepPurple.shade900 : Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        toolbarHeight: 100,
        title: Column(
          mainAxisSize: MainAxisSize.min, // Importante para centralizar os itens
          children: [
            Image.asset(
              'assets/images/logo-fortivus.png',
              height: 50,
            ),
            const SizedBox(height: 4),
            const Text(
              'HISTÓRICO',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            
            if (EnvironmentConfig.isHomologacao)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HOMOLOGAÇÃO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CARD DE FILTROS (VISUAL ATUALIZADO) ---
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: TacticalTheme.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.search, color: TacticalTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Filtros de Busca',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TacticalTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _registroIdController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'ID Registro',
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onSubmitted: (_) => _loadRegistros(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _ordemServicoIdController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'ID OS',
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onSubmitted: (_) => _loadRegistros(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.filter_list),
                          label: const Text('Filtrar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TacticalTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: _loadRegistros,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // --- BOTÃO RECARREGAR LISTA ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recarregar Lista'),
                  onPressed: _loadRegistros,
                ),
              ),

              const SizedBox(height: 10),

              // --- LISTAGEM DE REGISTROS ---
              if (_pagina == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (registros.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.history,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum histórico encontrado.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: registros.length,
                  itemBuilder: (context, index) {
                    final registro = registros[index];
                    final isRetroativo = registro.retroativo;
                    
                    return Card(
                      color: isRetroativo ? Colors.orange.shade50 : null,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isRetroativo ? Colors.orange.shade300 : Colors.grey.shade300, 
                          width: isRetroativo ? 1.5 : 1
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('RO: ${registro.id}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        if (isRetroativo)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'RO RETROATIVO',
                                              style: TextStyle(
                                                color: Colors.orange.shade900,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (registro.ordemServico != 0)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                            'OS: ${registro.ordemServico}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade700)),
                                      ),
                                  ],
                                ),
                                _getStatusIcon(registro.situacao),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(registro.dataCriacaoFormatada,
                                    style:
                                        const TextStyle(color: Colors.black87)),
                              ],
                            ),
                            if (isRetroativo && registro.dataFinalRoFormatada != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_available, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Data Final: ${registro.dataFinalRoFormatada}',
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),                            Row(
                              children: [
                                _getCategoriaIcon(registro.categoriaDescricao),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                  registro.categoriaDescricao,
                                  style: const TextStyle(color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                )),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('Visualizar Dados'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: isRetroativo ? Colors.orange.shade100 : Colors.grey.shade100,
                                    foregroundColor: Colors.black87,
                                    elevation: 0,
                                    side:
                                        BorderSide(color: isRetroativo ? Colors.orange.shade300 : Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6))),
                                onPressed: () {
                                  _navegarParaDetalhes(registro);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 12),

              // --- PAGINAÇÃO ---
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        totalPages,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: currentPage == i
                                  ? Colors.blue.shade800
                                  : null,
                              side: BorderSide(
                                  color: currentPage == i
                                      ? Colors.blue.shade800
                                      : Colors.grey),
                            ),
                            onPressed: () => _onPageChanged(i),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                  color: currentPage == i
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: currentPage == i
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
