import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/pages/combate_incendio/terrestre/combate_terrestre_state.dart' as state_module;
import 'package:fortivus_app/pages/combate_incendio/terrestre/widgets/widgets.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/widgets/historico_resultado_card.dart';
import 'package:fortivus_app/widgets/anexos_foto_card.dart';
import 'package:fortivus_app/widgets/area_atuacao_card.dart';
import 'package:fortivus_app/widgets/formulario_salvar_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResponderCombateTerrestrePage extends StatelessWidget {
  final int? registroId;

  static const String _pageTitle = 'Combate Terrestre';
  static const String _saveBtnLabel = 'SALVAR REGISTRO';

  const ResponderCombateTerrestrePage({
    super.key,
    this.registroId,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) debugPrint('🏗️ [TERRESTRE PAGE] Construindo com registroId: $registroId');

    return ChangeNotifierProvider(
      create: (_) => state_module.CombateTerrestreState(registroId: registroId),
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
  @override
  Widget build(BuildContext context) {
    return Consumer<state_module.CombateTerrestreState>(
      builder: (context, state, _) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: TacticalTheme.background,
            appBar: _buildAppBar(isLoading: true),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return PopScope(
          canPop: !state.isLoading,
          child: Scaffold(
            backgroundColor: TacticalTheme.background,
            appBar: _buildAppBar(isLoading: state.isLoading),
            body: _buildFormBody(state, context),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar({required bool isLoading}) {
    return AppBar(
      title: const Text(
        ResponderCombateTerrestrePage._pageTitle,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: TacticalTheme.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      leading: isLoading
          ? const Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : null,
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
          HistoricoResultadoCard<ResultadoOcorrencia>(
            historicoController: state.descricaoOperacaoController,
            resultadoOutroController: state.resultadoDiaController,
            resultadoSelecionado: state.resultadoOcorrencia,
            onResultadoChanged: state.setResultadoOcorrencia,
            enumValues: ResultadoOcorrencia.values,
            showResultadoOutro: state.resultadoOcorrencia == ResultadoOcorrencia.OUTRO,
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

  Future<String?> _executarSalvar(state_module.CombateTerrestreState state) async {
    if (kDebugMode) debugPrint('💾 [TERRESTRE PAGE] Chamando state.salvar()');
    return await state.salvar();
  }
}
