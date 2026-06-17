import 'package:fortivus_app/enums/tipo_resultado_incendio.dart';
import 'package:fortivus_app/widgets/anexos_foto_card.dart';
import 'package:fortivus_app/widgets/area_atuacao_card.dart';
import 'package:fortivus_app/widgets/formulario_salvar_button.dart';
import 'package:fortivus_app/widgets/historico_resultado_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/model/mobile_registro_avulso_request.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'combate_maquinario_state.dart';
import 'widgets/dados_operacionais_card.dart';
import 'widgets/producao_card.dart';
import 'widgets/avaliacao_operacional_card.dart'; 

/// Página para responder formulário de Combate Incêndio Maquinário
class ResponderCombateMaquinarioPage extends StatelessWidget {
  // ============================================================================
  // PROPRIEDADES
  // ============================================================================
  final int? registroId;
  final RegistroAvulsoTemp? dadosIniciais;

  // ============================================================================
  // CONSTANTES
  // ============================================================================
  static const String _pageTitle = 'Combate Maquinário';
  static const String _saveBtnLabel = 'SALVAR REGISTRO';

  // ============================================================================
  // CONSTRUTOR
  // ============================================================================
  const ResponderCombateMaquinarioPage({
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
      debugPrint('🏗️ [MAQUINÁRIO PAGE] Construindo');
      debugPrint('   - registroId: $registroId');
      debugPrint('   - isAvulso: ${registroId == null}');
    }
    
    return ChangeNotifierProvider(
      create: (_) {
        if (kDebugMode) debugPrint('🏗️ [MAQUINÁRIO PAGE] Criando CombateMaquinarioState');
        
        final bool isAvulso = registroId == null;
        
        return CombateMaquinarioState(
          registroId: registroId,
          dadosIniciais: dadosIniciais,
          isAvulso: isAvulso,
        );
      },
      child: const _CombateMaquinarioView(),
    );
  }
}

/// View principal - Gerencia estados de loading e navegação
class _CombateMaquinarioView extends StatefulWidget {
  const _CombateMaquinarioView();

  @override
  State<_CombateMaquinarioView> createState() => _CombateMaquinarioViewState();
}

class _CombateMaquinarioViewState extends State<_CombateMaquinarioView> {
  
  // ============================================================================
  // BUILD
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Consumer<CombateMaquinarioState>(
      builder: (context, state, _) {
        if (kDebugMode) {
          debugPrint('🔧 [MAQUINÁRIO VIEW] isLoading: ${state.isLoading}');
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

  Widget _buildFormScaffold(CombateMaquinarioState state, BuildContext context) {
    return PopScope(
      canPop: !state.isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && kDebugMode) {
          debugPrint('🔙 [MAQUINÁRIO PAGE] Voltando');
        }
      },
      child: Scaffold(
        backgroundColor: TacticalTheme.background,
        appBar: _buildAppBar(isLoading: state.isLoading),
        body: _buildFormBody(state, context),
      ),
    );
  }

  Widget _buildFormBody(CombateMaquinarioState state, BuildContext context) {
    return Form(
      key: state.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LocalizacaoMapaCard(
              localizacaoNotifier: state.localizacaoNotifier,
              eventoFogoGeoJson: state.eventoFogoGeoJson,
              isOffline: state.isOffline,
              title: 'Localização da Operação',
            ),
            const SizedBox(height: 16),
            const DadosOperacionaisCard(),
            const SizedBox(height: 16),
            const ProducaoCard(),
            const SizedBox(height: 16),
            const AvaliacaoOperacionalCard(),
            const SizedBox(height: 16),
            HistoricoResultadoCard<TipoResultadoIncendio>(
              historicoController: state.descricaoOperacaoController,
              resultadoOutroController: state.resultadoDiaController,
              resultadoSelecionado: state.tipoResultado,
              onResultadoChanged: state.setTipoResultado,
              enumValues: TipoResultadoIncendio.values,
              showResultadoOutro: state.tipoResultado == TipoResultadoIncendio.OUTRO,
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
              labelSalvar: ResponderCombateMaquinarioPage._saveBtnLabel,
              icon: Icons.check,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // BUILDERS DE COMPONENTES
  // ============================================================================

  AppBar _buildAppBar({required bool isLoading}) {
    return AppBar(
      title: const Text(
        ResponderCombateMaquinarioPage._pageTitle,
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
  Future<String?> _executarSalvar(CombateMaquinarioState state) async {
    if (kDebugMode) {
      debugPrint('💾 [MAQUINÁRIO PAGE] Chamando state.salvar()');
    }
    final erro = await state.salvar();
    return erro; 
  }
}