import 'package:fortivus_app/enums/tipo_resultado_incendio_terrestre.dart';
import 'package:fortivus_app/model/mobile_registro_avulso_request.dart';
import 'package:fortivus_app/pages/combate_incendio/terrestre/combate_terrestre_state.dart' as state_module;
import 'package:fortivus_app/pages/combate_incendio/terrestre/widgets/widgets.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/widgets/historico_resultado_card.dart'; 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Página para responder formulário de Combate Incêndio Terrestre
class ResponderCombateTerrestrePage extends StatelessWidget {
  // ============================================================================
  // PROPRIEDADES
  // ============================================================================
  final int? registroId;
  final RegistroAvulsoTemp? dadosIniciais;

  // ============================================================================
  // CONSTANTES
  // ============================================================================
  static const String _pageTitle = 'Combate Terrestre';
  static const String _saveBtnLabel = 'SALVAR REGISTRO';

  // ============================================================================
  // CONSTRUTOR
  // ============================================================================
  const ResponderCombateTerrestrePage({
    super.key,
    this.registroId,
    this.dadosIniciais,
  });

  // ============================================================================
  // BUILD
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🏗️ [TERRESTRE PAGE] Construindo');
      debugPrint('   - registroId: $registroId');
      debugPrint('   - isAvulso: ${registroId == null}');
    }

    return ChangeNotifierProvider(
      create: (_) {
        if (kDebugMode) {
          debugPrint('🏗️ [TERRESTRE PAGE] Criando CombateTerrestreState');
        }

        final bool isAvulso = registroId == null;

        return state_module.CombateTerrestreState(
          registroId: registroId,
          dadosIniciais: dadosIniciais,
          isAvulso: isAvulso,
        );
      },
      child: const _CombateTerrestreView(),
    );
  }
}

class _CombateTerrestreView extends StatefulWidget {
  const _CombateTerrestreView();

  @override
  State<_CombateTerrestreView> createState() => _CombateTerrestreViewState();
}

class _CombateTerrestreViewState extends State<_CombateTerrestreView> {

  // ============================================================================
  // BUILD
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Consumer<state_module.CombateTerrestreState>(
      builder: (context, state, _) {
        if (kDebugMode) {
          debugPrint('🔧 [TERRESTRE VIEW] isLoading: ${state.isLoading}');
        }

        if (state.isLoading) {
          return _buildLoadingScaffold();
        }

        return _buildFormScaffold(state, context);
      },
    );
  }

  // ============================================================================
  // BUILDERS PRINCIPAIS
  // ============================================================================

  Scaffold _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: TacticalTheme.background,
      appBar: _buildAppBar(isLoading: true),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildFormScaffold(state_module.CombateTerrestreState state, BuildContext context) {
    return PopScope(
      canPop: !state.isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && kDebugMode) {
          debugPrint('🔙 [TERRESTRE PAGE] Voltando');
        }
      },
      child: Scaffold(
        backgroundColor: TacticalTheme.background,
        appBar: _buildAppBar(isLoading: state.isLoading),
        body: _buildFormBody(state, context),
      ),
    );
  }

  Widget _buildFormBody(state_module.CombateTerrestreState state, BuildContext context) {
    return Form(
      key: state.formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LocalizacaoMapaCard(
            localizacaoNotifier: state.localizacaoNotifier,
            eventoFogoGeoJson: state.eventoFogoGeoJson,
            isOffline: state.isOffline,
            title: 'Localização da Operação',
          ),
          const SizedBox(height: 16),
          const InformacoesCombateCard(),
          const SizedBox(height: 16),
          const ApoioColaboracaoCard(),
          const SizedBox(height: 16),
          const RecursosOrigemCard(),
          const SizedBox(height: 16),
          const AvaliacaoOperacionalCard(),
          const SizedBox(height: 16),
          HistoricoResultadoCard<TipoResultadoIncendioTerrestre>(
            historicoController: state.descricaoOperacaoController,
            resultadoOutroController: state.resultadoDiaController,
            resultadoSelecionado: state.tipoResultado,
            onResultadoChanged: state.setTipoResultado,
            enumValues: TipoResultadoIncendioTerrestre.values,
            showResultadoOutro: state.tipoResultado == TipoResultadoIncendioTerrestre.OUTRO,
            title: "Histórico e Resultado da Operação",
          ),
          const SizedBox(height: 16),
          AnexosFotoCard(
            arquivosNotifier: state.arquivosNotifier,
            picker: state.picker,
          ),
          const SizedBox(height: 24),

          FormularioSalvarButton(
            isLoading: state.isLoading,
            onSalvar: ({onSucessoAntesDeFechar}) => _executarSalvar(state),
            labelSalvar: ResponderCombateTerrestrePage._saveBtnLabel,
            icon: Icons.check,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ============================================================================
  // BUILDERS DE COMPONENTES
  // ============================================================================

  AppBar _buildAppBar({required bool isLoading}) {
    return AppBar(
      title: const Text(
        ResponderCombateTerrestrePage._pageTitle,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: TacticalTheme.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      leading: isLoading ? _buildLoadingIndicator() : null,
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(14),
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  // ============================================================================
  // HANDLERS DE AÇÃO
  // ============================================================================

  Future<String?> _executarSalvar(state_module.CombateTerrestreState state) async {
    if (kDebugMode) {
      debugPrint('💾 [TERRESTRE PAGE] Chamando state.salvar()');
    }

    return await state.salvar();
  }
}