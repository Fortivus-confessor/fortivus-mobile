import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/widgets/anexos_foto_card.dart';
import 'package:fortivus_app/widgets/area_atuacao_card.dart';
import 'package:fortivus_app/widgets/formulario_salvar_button.dart';
import 'package:fortivus_app/widgets/historico_resultado_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'combate_maquinario_state.dart';
import 'widgets/dados_operacionais_card.dart';
import 'widgets/producao_card.dart';
import 'widgets/avaliacao_operacional_card.dart';

class ResponderCombateMaquinarioPage extends StatelessWidget {
  final int? registroId;

  static const String _pageTitle = 'Combate Maquinário';
  static const String _saveBtnLabel = 'SALVAR REGISTRO';

  const ResponderCombateMaquinarioPage({
    super.key,
    this.registroId,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) debugPrint('🏗️ [MAQUINÁRIO PAGE] Construindo com registroId: $registroId');

    return ChangeNotifierProvider(
      create: (_) => CombateMaquinarioState(registroId: registroId),
      child: const _CombateMaquinarioView(),
    );
  }
}

class _CombateMaquinarioView extends StatefulWidget {
  const _CombateMaquinarioView();

  @override
  State<_CombateMaquinarioView> createState() => _CombateMaquinarioViewState();
}

class _CombateMaquinarioViewState extends State<_CombateMaquinarioView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CombateMaquinarioState>(
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
        ResponderCombateMaquinarioPage._pageTitle,
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
              labelSalvar: ResponderCombateMaquinarioPage._saveBtnLabel,
              icon: Icons.check,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<String?> _executarSalvar(CombateMaquinarioState state) async {
    if (kDebugMode) debugPrint('💾 [MAQUINÁRIO PAGE] Chamando state.salvar()');
    return await state.salvar();
  }
}
