import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/pages/conscientizacao_educacao_ambiental/detalhes_conscientizacao_page.dart';
import 'package:fortivus_app/pages/conscientizacao_educacao_ambiental/responder_conscientizacao_page.dart';
import 'package:fortivus_app/pages/detalhes_registro_page.dart';
import 'package:fortivus_app/pages/combate_incendio/aereo/responder_combate_incendio_aereo_page.dart';
import 'package:fortivus_app/pages/combate_incendio/maquinario/responder_combate_incendio_maquinario_page.dart';
import 'package:fortivus_app/pages/combate_incendio/terrestre/responder_combate_terrestre_page.dart';
import 'package:fortivus_app/pages/formacao_brigadista_florestal/detalhes_formacao_page.dart';
import 'package:fortivus_app/pages/formacao_brigadista_florestal/responder_formacao_brigadista_florestal_page.dart';
import 'package:fortivus_app/pages/ronda/responder_ronda_page.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fortivus_app/model/registro.dart';
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
  // Filtros
  final TextEditingController _registroIdController = TextEditingController();
  final TextEditingController _ordemServicoIdController =
      TextEditingController();
  String? _categoria;
  String? _situacao;

  // Dados e paginação
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
      final user = await LocalDbService.getLoggedUser();
      
      // Tenta obter o sub do usuário
      String? userSub;
      if (user?.token != null) {
        try {
          final decodedToken = JwtDecoder.decode(user!.token!);
          userSub = decodedToken['sub'] as String?;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[ConsultaRegistrosPage] Erro ao extrair sub do token: $e');
          }
        }
      }
      
      // Se não conseguiu extrair do token, usa o sub armazenado
      userSub ??= user?.sub;

      if (userSub == null) {
        // Se não há usuário logado ou sub, redireciona para o login
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sessão expirada ou usuário não logado. Por favor, faça login novamente.'),
            ),
          );
        }
        return;
      }

      setState(() {
        _loggedUserSub = userSub;  // Salva o sub do usuário logado
      });

      if (kDebugMode) {
        debugPrint('[ConsultaRegistrosPage] Usuário inicializado com sub: $userSub');
      }

      _loadRegistros();  // Agora que temos o sub, podemos carregar os registros
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ConsultaRegistrosPage] Erro ao inicializar usuário: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar sessão: ${e.toString()}')),
        );
        // Redireciona para login em caso de erro
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  List<Registro> get registros => _pagina?.content ?? [];
  int get totalPages => _pagina?.totalPages ?? 1;
  int get totalItems => _pagina?.totalItems ?? 0;

  Future<void> _loadRegistros() async {
    // Só tenta carregar registros se já tivermos o sub do usuário logado
    if (_loggedUserSub == null) {
      if (kDebugMode) {
        debugPrint('[ConsultaRegistrosPage] Sub do usuário não disponível, aguardando inicialização.');
      }
      return;
    }

    setState(() {
      _pagina = null; // Limpa a página atual para mostrar um loading
    });

    try {
      final pagina = await _registroService.consultarRegistros(
        registroId: int.tryParse(_registroIdController.text),
            
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
          const SnackBar(content: Text('Nenhum registro encontrado.')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ConsultaRegistrosPage] Erro ao carregar registros: $e');
      }
      setState(() {
        _pagina = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar registros: ${e.toString().replaceFirst('Exception: ', '')}'),
          ),
        );
      }
    }
  }


  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _loadRegistros();
  }

  void _navegarParaFormularioResposta(Registro registro) async {
    Widget? page;
    final categoriaKey = registro.categoria;
    
    switch (categoriaKey) {
      case 'RONDA':
        page = ResponderRondaPage(registroId: registro.id);
        break;

      case 'COMBATE_INCENDIO_AEREO':
        page = ResponderCombateAereoPage(registroId: registro.id);
        break;
        
      case 'COMBATE_INCENDIO_TERRESTRE':
        page = ResponderCombateTerrestrePage(registroId: registro.id);
        break;

      case 'COMBATE_INCENDIO_MAQUINARIO':
        page = ResponderCombateMaquinarioPage(registroId: registro.id);
        break; 
      
      case 'CONSCIENTIZACAO_EDUCACAO_AMBIENTAL':
        // ✅ CORRIGIDO: Passe os dados do registro
        page = ResponderConscientizacaoPage(
          registroId: registro.id,
          latitudeRo: registro.latitudeRo,
          longitudeRo: registro.longitudeRo,
          acaoDespacho: null, // TODO: Se tiver ação prevista no backend, mapeie aqui
        );
        break;

      case 'FORMACAO_BRIGADISTA_FLORESTAL':
        // ✅ NOVO: Navegação para Formação Brigadista
        page = ResponderFormacaoPage(
          registroId: registro.id,
          latitudeRo: registro.latitudeRo,
          longitudeRo: registro.longitudeRo,
          dataInicialDespacho: null, // TODO: Se tiver data inicial no backend, mapeie aqui
          dataFinalDespacho: null, // TODO: Se tiver data final no backend, mapeie aqui
        );
        break;
        
      default:
        final descricao = registro.categoriaDescricao.toUpperCase();
        
        if (descricao.contains('AÉREO') || descricao.contains('AEREO')) {
          page = ResponderCombateAereoPage(registroId: registro.id);
        } 
        else if (descricao.contains('MAQUINÁRIO') || descricao.contains('MAQUINARIO')) {
          page = ResponderCombateMaquinarioPage(registroId: registro.id);
        }
        else if (descricao.contains('RONDA') || descricao.contains('PATRULHAMENTO')) {
          page = ResponderRondaPage(registroId: registro.id);
        } 
        else if (descricao.contains('COMBATE') || descricao.contains('TERRESTRE')) {
          page = ResponderCombateTerrestrePage(registroId: registro.id);
        }
        else if (descricao.contains('CONSCIENTIZAÇÃO') || descricao.contains('CONSCIENTIZACAO') || 
                descricao.contains('EDUCAÇÃO AMBIENTAL') || descricao.contains('EDUCACAO AMBIENTAL')) {
          page = ResponderConscientizacaoPage(
            registroId: registro.id,
            latitudeRo: registro.latitudeRo,
            longitudeRo: registro.longitudeRo,
            acaoDespacho: null,
          );
        }
        else if (descricao.contains('FORMAÇÃO') || descricao.contains('FORMACAO') ||
                descricao.contains('BRIGADISTA') || descricao.contains('FLORESTAL')) {
          // ✅ NOVO: Fallback para Formação Brigadista
          page = ResponderFormacaoPage(
            registroId: registro.id,
            latitudeRo: registro.latitudeRo,
            longitudeRo: registro.longitudeRo,
            dataInicialDespacho: null,
            dataFinalDespacho: null,
          );
        }
    }

    if (page != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page!),
      );

      if (result == true) {
        _loadRegistros();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Formulário não disponível para: $categoriaKey'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  Widget _getCategoriaIcon(String categoria) {
  final catLower = categoria.toLowerCase();

  if (catLower.contains('ronda') || catLower.contains('patrulha')) {
    return const Icon(Icons.security, color: Colors.teal, size: 20);
  }

  if (catLower.contains('aéreo') || catLower.contains('aereo')) {
    return const Icon(Icons.airplanemode_active, color: Colors.blue, size: 20);
  }

  if (catLower.contains('maquinario') || catLower.contains('maquinário')) {
    return Icon(Icons.agriculture, color: Colors.amber[900], size: 20);
  }
  
  if (catLower.contains('terrestre')) {
    return const Icon(Icons.local_fire_department, color: Colors.brown, size: 20); 
  }
  
  if (catLower.contains('conscientização') || 
      catLower.contains('conscientizacao') ||
      catLower.contains('educação ambiental') ||
      catLower.contains('educacao ambiental')) {
    return const Icon(Icons.eco, color: Colors.green, size: 20);
  }

  if (catLower.contains('formação') || 
      catLower.contains('formacao') ||
      catLower.contains('brigadista') || 
      catLower.contains('florestal')) {
    return const Icon(Icons.school, color: Colors.purple, size: 20);
  }

  switch (catLower) {
    case 'combate incêndio':
    case 'combate a incêndio':
      return const Icon(Icons.local_fire_department, color: Colors.red, size: 20);
      
    case 'atividade comunitária':
      return const Icon(Icons.volunteer_activism, color: Colors.purple, size: 20);
      
    case 'fiscalização':
    case 'fiscalizacao':
      return const Icon(Icons.content_paste_search, color: Colors.orange, size: 20);
      
    default:
      return const Icon(Icons.info_outline, color: Colors.grey, size: 20);
  }
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo-fortivus.png', 
              height: 50,
            ), 
            const SizedBox(height: 4),
            const Text(
              'FORTIVUS', 
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- CARD DE FILTROS (TEMA TÁTICO) ---
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

                  // --- LISTAGEM DOS REGISTROS ---
                  if (_pagina == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40), 
                        child: CircularProgressIndicator()
                      )
                    )
                  else if (registros.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40), 
                        child: Column(
                          children: [
                            Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'Nenhum registro encontrado.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        )
                      )
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: registros.length,
                      itemBuilder: (context, index) {
                        final registro = registros[index];
                        final isAberto = registro.situacao == 'ABERTA';
                        final isRetroativo = registro.retroativo;
                        
                        return Card(
                          elevation: 1,
                          color: isRetroativo ? Colors.orange.shade50 : null,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: isRetroativo ? Colors.orange.shade300 : Colors.grey.shade300, 
                              width: isRetroativo ? 1.5 : 1
                            ),
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
                                        Row(
                                          children: [
                                            Text(
                                              'RO: ${registro.id}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
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
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              'OS: ${registro.ordemServico}', 
                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)
                                            ),
                                          ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isAberto ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: isAberto ? Colors.green : Colors.grey)
                                      ),
                                      child: Text(
                                        registro.situacao, 
                                        style: TextStyle(color: isAberto ? Colors.green : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)
                                      ),
                                    )
                                  ],
                                ),
                                
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Divider(),
                                ),
                                
                                Row(children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(registro.dataCriacaoFormatada, style: const TextStyle(color: Colors.black87)),
                                ]),
                                if (isRetroativo && registro.dataFinalRoFormatada != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(children: [
                                      const Icon(Icons.event_available, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Data Final: ${registro.dataFinalRoFormatada}', 
                                        style: const TextStyle(color: Colors.black87),
                                      ),
                                    ]),
                                  ),
                                const SizedBox(height: 8),                                Row(children: [
                                  _getCategoriaIcon(registro.categoriaDescricao),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      registro.categoriaDescricao, 
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
                                          Widget pageDestino;

                                          if (registro.categoria == 'CONSCIENTIZACAO_EDUCACAO_AMBIENTAL') {
                                            pageDestino = DetalhesConscientizacaoPage(registro: registro);
                                          } else if (registro.categoria == 'FORMACAO_BRIGADISTA_FLORESTAL') {
                                            pageDestino = DetalhesFormacaoPage(registro: registro);
                                          } else {
                                            pageDestino = DetalhesRegistroPage(registro: registro);
                                          }

                                          Navigator.push(context, MaterialPageRoute(builder: (context) => pageDestino));
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
                                        onPressed: isAberto 
                                          ? () => _navegarParaFormularioResposta(registro) 
                                          : null,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 12),
                  
                  // --- PAGINAÇÃO (NOVO ESTILO) ---
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
                                      ? TacticalTheme.primary
                                      : null,
                                  side: BorderSide(
                                      color: currentPage == i
                                          ? TacticalTheme.primary
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
        ],
      ),
    );
  }
}