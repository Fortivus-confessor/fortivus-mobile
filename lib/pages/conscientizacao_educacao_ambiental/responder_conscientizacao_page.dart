import 'package:fortivus_app/enums/tipo_acao_coscientizacao.dart';
import 'package:fortivus_app/pages/conscientizacao_educacao_ambiental/conscientizacao_state.dart';
import 'package:fortivus_app/pages/conscientizacao_educacao_ambiental/widgets/localizacao_conscientizacao_card.dart';
import 'package:fortivus_app/pages/conscientizacao_educacao_ambiental/widgets/acao_conscientizacao_card.dart';
import 'package:fortivus_app/widgets/anexos_foto_card.dart';
import 'package:fortivus_app/widgets/formulario_salvar_button.dart';
import 'package:fortivus_app/widgets/historico_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/model/mobile_registro_avulso_request.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'widgets/publico_conscientizacao_card.dart';
import 'package:fortivus_app/widgets/localizacao_generico_card.dart';

class ResponderConscientizacaoPage extends StatelessWidget {
  // ============================================================================
  // PROPRIEDADES
  // ============================================================================
  final int? registroId;
  final RegistroAvulsoTemp? dadosIniciais;
  final double? latitudeRo;
  final double? longitudeRo;
  final TipoAcaoConscientizacao? acaoDespacho;
  final DateTime? dataInicialDespacho;
  final DateTime? dataFinalDespacho;

  // ============================================================================
  // CONSTANTES
  // ============================================================================
  static const String _pageTitle = 'Registro de Conscientização';
  static const String _saveBtnLabel = 'SALVAR REGISTRO';
  static const String _localizacaoTitle = 'Localização da Atividade';
  static const String _localizacaoSubtitle =
      'Selecione a localização onde a conscientização foi realizada';

  // ============================================================================
  // CONSTRUTOR
  // ============================================================================
  const ResponderConscientizacaoPage({
    super.key,
    this.registroId,
    this.dadosIniciais,
    this.latitudeRo,
    this.longitudeRo,
    this.acaoDespacho,
    this.dataInicialDespacho,
    this.dataFinalDespacho,
  });

  // ============================================================================
  // BUILD
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🏗️ [CONSCIENTIZACAO PAGE] Construindo');
      debugPrint('   - registroId: $registroId');
      debugPrint('   - isAvulso: ${registroId == null}');
      debugPrint('   - latitudeRo: $latitudeRo');
      debugPrint('   - longitudeRo: $longitudeRo');
    }

    return ChangeNotifierProvider(
      create: (_) {
        if (kDebugMode) {
          debugPrint('🏗️ [CONSCIENTIZACAO PAGE] Criando ConscientizacaoState');
        }

        final bool isAvulso = registroId == null;

        return ConscientizacaoState(
          registroId: registroId,
          dadosIniciais: dadosIniciais,
          latitudeRegistroOcorrencia: latitudeRo,
          longitudeRegistroOcorrencia: longitudeRo,
          acaoPrevistaDespacho: acaoDespacho,
          dataInicialDespacho: dataInicialDespacho,
          dataFinalDespacho: dataFinalDespacho,
          isAvulso: isAvulso,
        );
      },
      child: const _ConscientizacaoView(),
    );
  }
}

/// View principal - Gerencia estados de loading e navegação
class _ConscientizacaoView extends StatefulWidget {
  const _ConscientizacaoView();

  @override
  State<_ConscientizacaoView> createState() => _ConscientizacaoViewState();
}

class _ConscientizacaoViewState extends State<_ConscientizacaoView> {
  // ============================================================================
  // BUILD
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Consumer<ConscientizacaoState>(
      builder: (context, state, _) {
        if (kDebugMode) {
          debugPrint('🔧 [CONSCIENTIZACAO VIEW] isLoading: ${state.isLoading}');
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

  Widget _buildFormScaffold(
    ConscientizacaoState state,
    BuildContext context,
  ) {
    return PopScope(
      canPop: !state.isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && kDebugMode) {
          debugPrint('🔙 [CONSCIENTIZAÇÃO PAGE] Voltando');
        }
      },
      child: Scaffold(
        backgroundColor: TacticalTheme.background,
        appBar: _buildAppBar(isLoading: state.isLoading),
        body: _buildFormBody(state, context),
      ),
    );
  }

  Widget _buildFormBody(
    ConscientizacaoState state,
    BuildContext context,
  ) {
    return Form(
      key: state.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (state.isAvulso)
              _buildLocalizacaoAvulso(state)
            else
              _buildLocalizacaoResposta(),
            const SizedBox(height: 16),

            if (state.isAvulso)
              const AcaoConscientizacaoCard(),
            if (state.isAvulso) const SizedBox(height: 16),

            const PublicoConscientizacaoCard(),
            const SizedBox(height: 16),

            HistoricoDescritivoCard(
              historicoController: state.historicoController,
              title: 'Histórico',
              labelHistorico: 'Relato da Ocorrência *',
            ),
            const SizedBox(height: 16),

            AnexosFotoCard(
              arquivosNotifier: state.arquivosNotifier,
              picker: state.picker,
            ),
            const SizedBox(height: 24),

            // ✅ AQUI: O botão usa a chamada enxuta
            FormularioSalvarButton(
              isLoading: state.isLoading,
              onSalvar: ({onSucessoAntesDeFechar}) => _executarSalvar(state),
              labelSalvar: ResponderConscientizacaoPage._saveBtnLabel,
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
        ResponderConscientizacaoPage._pageTitle,
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

  Widget _buildLocalizacaoAvulso(ConscientizacaoState state) {
    return LocalizacaoGenericoCard(
      title: ResponderConscientizacaoPage._localizacaoTitle,
      subtitle: ResponderConscientizacaoPage._localizacaoSubtitle,
      mostrarVerificacaoDespacho: false,
      localizacaoNotifier: state.localizacaoNotifier,
      isOffline: state.isOffline,
      onLocationSelected: (latLng) {
        state.setLocalizacao(latLng);
      },
      deslocamentoInicial: state.deslocamentoInicial,
      deslocamentoFinal: state.deslocamentoFinal,
      onDeslocamentoInicialChanged: state.setDeslocamentoInicial,
      onDeslocamentoFinalChanged: state.setDeslocamentoFinal,
    );
  }

  Widget _buildLocalizacaoResposta() {
    return const LocalizacaoConscientizacaoCard();
  }

  // ============================================================================
  // HANDLERS DE AÇÃO
  // ============================================================================

  /// ✅ NOVO: Função enxuta para coordenar salvamento.
  /// A UI e fechamento da tela são controlados pelo `FormularioSalvarButton`.
  Future<String?> _executarSalvar(ConscientizacaoState state) async {
    if (kDebugMode) {
      debugPrint('💾 [CONSCIENTIZACAO PAGE] Chamando state.salvar()');
    }

    // Chama o método salvar do state.
    return await state.salvar();
  }
}