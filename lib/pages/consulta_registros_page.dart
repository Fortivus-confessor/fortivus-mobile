import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/pages/detalhes_registro_page.dart';
import 'package:fortivus_app/pages/combate_incendio/aereo/responder_combate_incendio_aereo_page.dart';
import 'package:fortivus_app/pages/combate_incendio/maquinario/responder_combate_incendio_maquinario_page.dart';
import 'package:fortivus_app/pages/combate_incendio/terrestre/responder_combate_terrestre_page.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fortivus_app/model/despacho.dart' as model;
import 'package:fortivus_app/pages/registro_page.dart';
import 'package:fortivus_app/services/registro_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/local_db_service.dart';
import 'login_page.dart';

class ConsultaRegistrosPage extends StatefulWidget {
  const ConsultaRegistrosPage({super.key});

  @override
  State<ConsultaRegistrosPage> createState() => _ConsultaRegistrosPageState();
}

class _ConsultaRegistrosPageState extends State<ConsultaRegistrosPage> {
  final TextEditingController _registroIdController = TextEditingController();
  final TextEditingController _ordemServicoIdController = TextEditingController();
  String? _categoria;
  String? _situacao;

  RegistroPage? _pagina;
  int currentPage = 0;
  int pageSize = 10;
  bool isAscending = false;
  final RegistroService _registroService = RegistroService();
  String? _loggedUserSub;

  @override
  void initState() {
    super.initState();
    _situacao = 'ABERTA';
    _initializeUserAndLoadRegistros();
  }

  Future<void> _initializeUserAndLoadRegistros() async {
    try {
      final userMap = await LocalDbService.instance.getUserAsMap();

      String? userSub;
      final token = userMap?['token'] as String?;
      if (token != null) {
        try {
          final decoded = JwtDecoder.decode(token);
          userSub = decoded['sub'] as String?;
        } catch (e) {
          if (kDebugMode) debugPrint('[ConsultaRegistrosPage] Erro ao decodificar token: $e');
        }
      }
      userSub ??= userMap?['sub'] as String?;

      if (userSub == null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sessão expirada. Por favor, faça login novamente.')),
          );
        }
        return;
      }

      setState(() => _loggedUserSub = userSub);
      _loadRegistros();
    } catch (e) {
      if (kDebugMode) debugPrint('[ConsultaRegistrosPage] Erro ao inicializar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar sessão: ${e.toString()}')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  List<model.Despacho> get despachos => _pagina?.content ?? [];
  int get totalPages => _pagina?.totalPages ?? 1;
  int get totalItems => _pagina?.totalItems ?? 0;

  Future<void> _loadRegistros() async {
    if (_loggedUserSub == null) return;
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
          const SnackBar(content: Text('Nenhum despacho encontrado.')),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ConsultaRegistrosPage] Erro: $e');
      setState(() => _pagina = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  void _onPageChanged(int page) {
    setState(() => currentPage = page);
    _loadRegistros();
  }

  void _navegarParaFormularioResposta(model.Despacho despacho) async {
    final categoriaKey = despacho.categoria.name;
    Widget? page;

    switch (categoriaKey) {
      case 'AEREO':
        page = ResponderCombateAereoPage(registroId: despacho.id);
        break;
      case 'MAQUINARIO':
        page = ResponderCombateMaquinarioPage(registroId: despacho.id);
        break;
      default:
        page = ResponderCombateTerrestrePage(registroId: despacho.id);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page!),
    );
    if (result == true) _loadRegistros();
  }

  Widget _getCategoriaIcon(model.Despacho despacho) {
    switch (despacho.categoria.name) {
      case 'AEREO':
        return const Icon(Icons.airplanemode_active, color: Colors.blue, size: 20);
      case 'MAQUINARIO':
        return Icon(Icons.agriculture, color: Colors.amber[900], size: 20);
      default:
        return const Icon(Icons.local_fire_department, color: Colors.brown, size: 20);
    }
  }

  String _formatData(DateTime? dt) {
    if (dt == null) return '--';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: EnvironmentConfig.isHomologacao ? Colors.deepPurple.shade900 : Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        toolbarHeight: 100,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo-fortivus.png', height: 50),
            const SizedBox(height: 4),
            const Text('FORTIVUS', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            if (EnvironmentConfig.isHomologacao)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(4)),
                child: const Text('HOMOLOGAÇÃO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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

                  const SizedBox(height: 12),

                  if (_pagina == null)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                  else if (despachos.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text('Nenhum despacho encontrado.', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                        final isAberto = despacho.isAberto;

                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                                        Text(
                                          'Despacho: ${despacho.id}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            'OS: ${despacho.ordemServicoId}',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isAberto ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: isAberto ? Colors.green : Colors.grey),
                                      ),
                                      child: Text(
                                        despacho.status.label,
                                        style: TextStyle(
                                          color: isAberto ? Colors.green : Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider()),

                                Row(children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(_formatData(despacho.dataInicio), style: const TextStyle(color: Colors.black87)),
                                ]),

                                const SizedBox(height: 8),
                                Row(children: [
                                  _getCategoriaIcon(despacho),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      despacho.categoriaDescricao,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ]),

                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.visibility, size: 18),
                                        label: const Text('Detalhes'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black87,
                                          side: BorderSide(color: Colors.grey.shade300),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => DetalhesRegistroPage(despacho: despacho)),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.edit_note, size: 18),
                                        label: const Text('Responder'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isAberto ? Colors.redAccent : Colors.green,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          elevation: 0,
                                        ),
                                        onPressed: isAberto ? () => _navegarParaFormularioResposta(despacho) : null,
                                      ),
                                    ),
                                  ],
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
                                  backgroundColor: currentPage == i ? TacticalTheme.primary : null,
                                  side: BorderSide(color: currentPage == i ? TacticalTheme.primary : Colors.grey),
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
        ],
      ),
    );
  }
}
