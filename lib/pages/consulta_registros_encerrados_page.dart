import 'package:fortivus_app/pages/combate_incendio/aereo/visualizar_combate_aereo_page.dart';
import 'package:fortivus_app/pages/combate_incendio/maquinario/visualizar_combate_incendio_maquinario_page.dart';
import 'package:flutter/material.dart';
import 'package:fortivus_app/model/despacho.dart' as model;
import 'package:fortivus_app/pages/registro_page.dart';
import 'package:fortivus_app/services/registro_service.dart';
import 'package:fortivus_app/pages/combate_incendio/terrestre/visualizar_combate_terrestre_page.dart';
import '../services/local_db_service.dart';
import 'login_page.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class ConsultaRegistrosEncerradosPage extends StatefulWidget {
  const ConsultaRegistrosEncerradosPage({super.key});

  @override
  State<ConsultaRegistrosEncerradosPage> createState() => _ConsultaRegistrosEncerradosPageState();
}

class _ConsultaRegistrosEncerradosPageState extends State<ConsultaRegistrosEncerradosPage> {
  final TextEditingController _registroIdController = TextEditingController();
  final TextEditingController _ordemServicoIdController = TextEditingController();
  String? _categoria;
  final String _situacao = 'ENCERRADA';
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

  Future<void> _initializeUserAndLoadRegistros() async {
    try {
      final userMap = await LocalDbService.instance.getUserAsMap();
      final sub = userMap?['sub'] as String?;
      if (sub == null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sessão expirada. Por favor, faça login novamente.'), duration: Duration(seconds: 4)),
          );
        }
        return;
      }
      setState(() => _loggedUserApiId = sub);
      _loadRegistros();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar sessão: ${e.toString()}'), duration: const Duration(seconds: 4)),
        );
      }
    }
  }

  List<model.Despacho> get despachos => _pagina?.content ?? [];
  int get totalPages => _pagina?.totalPages ?? 1;
  int get totalItems => _pagina?.totalItems ?? 0;

  Future<void> _loadRegistros() async {
    if (_loggedUserApiId == null) return;
    setState(() => _pagina = null);

    try {
      final pagina = await _registroService.consultarRegistros(
        registroId: int.tryParse(_registroIdController.text),
        ordemServicoId: int.tryParse(_ordemServicoIdController.text),
        categoria: _categoria,
        situacao: _situacao,
        page: currentPage,
        size: pageSize,
        sort: isAscending ? 'asc' : 'desc',
      );
      setState(() => _pagina = pagina);
      if (pagina.totalItems == 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum histórico encontrado.'), duration: Duration(seconds: 4)),
        );
      }
    } catch (e) {
      setState(() => _pagina = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum histórico offline. Conecte-se para buscar antigos.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _navegarParaDetalhes(model.Despacho despacho) {
    final categoriaKey = despacho.categoria.name;
    Widget? paginaDestino;

    if (categoriaKey == 'AEREO') {
      paginaDestino = VisualizarCombateAereoPage(registroId: despacho.id);
    } else if (categoriaKey == 'MAQUINARIO') {
      paginaDestino = VisualizarCombateMaquinarioPage(registroId: despacho.id);
    } else {
      paginaDestino = VisualizarCombateTerrestrePage(registroId: despacho.id);
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => paginaDestino!));
  }

  void _onPageChanged(int page) {
    setState(() => currentPage = page);
    _loadRegistros();
  }

  Widget _getCategoriaIcon(model.Despacho despacho) {
    switch (despacho.categoria.name) {
      case 'AEREO':
        return const Icon(Icons.airplanemode_active, color: Colors.blue, size: 20);
      case 'MAQUINARIO':
        return const Icon(Icons.agriculture, color: Colors.orange, size: 20);
      default:
        return const Icon(Icons.local_fire_department, color: Colors.brown, size: 20);
    }
  }

  String _formatData(DateTime? dt) {
    if (dt == null) return '--';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        toolbarHeight: 100,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo-fortivus.png', height: 50),
            const SizedBox(height: 4),
            const Text('HISTÓRICO', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          Text('Filtros de Busca', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TacticalTheme.primary)),
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
                                labelText: 'ID Despacho',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: _loadRegistros,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recarregar Lista'),
                  onPressed: _loadRegistros,
                ),
              ),

              const SizedBox(height: 10),

              if (_pagina == null)
                const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
              else if (despachos.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('Nenhum histórico encontrado.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: despachos.length,
                  itemBuilder: (context, index) {
                    final despacho = despachos[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade300),
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
                                    Text('Despacho: ${despacho.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text('OS: ${despacho.ordemServicoId}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                                    ),
                                  ],
                                ),
                                const Tooltip(
                                  message: 'Concluído',
                                  child: Icon(Icons.cloud_done_rounded, color: Colors.green, size: 20),
                                ),
                              ],
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider()),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(_formatData(despacho.dataInicio), style: const TextStyle(color: Colors.black87)),
                              ],
                            ),
                            if (despacho.dataFim != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_available, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text('Encerrado: ${_formatData(despacho.dataFim)}', style: const TextStyle(color: Colors.black87)),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _getCategoriaIcon(despacho),
                                const SizedBox(width: 8),
                                Expanded(child: Text(despacho.categoriaDescricao, style: const TextStyle(color: Colors.black87), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('Visualizar Dados'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                onPressed: () => _navegarParaDetalhes(despacho),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 12),

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
                              backgroundColor: currentPage == i ? Colors.blue.shade800 : null,
                              side: BorderSide(color: currentPage == i ? Colors.blue.shade800 : Colors.grey),
                            ),
                            onPressed: () => _onPageChanged(i),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: currentPage == i ? Colors.white : Colors.black87,
                                fontWeight: currentPage == i ? FontWeight.bold : FontWeight.normal,
                              ),
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
