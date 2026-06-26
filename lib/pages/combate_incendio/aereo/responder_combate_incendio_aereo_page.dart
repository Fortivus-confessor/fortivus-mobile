import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/widgets/anexos_foto_card.dart';
import 'package:fortivus_app/widgets/area_atuacao_card.dart';
import 'package:fortivus_app/widgets/formulario_salvar_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import '../../../widgets/historico_resultado_card.dart' show HistoricoResultadoCard;
import 'combate_aereo_state.dart';
import 'widgets/dados_operacionais_card.dart';
import 'widgets/recursos_hidricos_card.dart';
import 'widgets/avaliacao_operacional_card.dart';

class ResponderCombateAereoPage extends StatelessWidget {
  final int? registroId;

  const ResponderCombateAereoPage({
    super.key,
    this.registroId,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) debugPrint('🏗️ [AÉREO PAGE] Construindo com registroId: $registroId');

    return ChangeNotifierProvider(
      create: (_) => CombateAereoState(registroId: registroId),
      child: const _CombateAereoView(),
    );
  }
}

class _CombateAereoView extends StatefulWidget {
  const _CombateAereoView();

  @override
  State<_CombateAereoView> createState() => _CombateAereoViewState();
}

class _CombateAereoViewState extends State<_CombateAereoView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CombateAereoState>(
      builder: (context, state, _) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: TacticalTheme.background,
            appBar: AppBar(
              title: const Text('Combate Aéreo', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: TacticalTheme.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return PopScope(
          canPop: !state.isLoading,
          child: Scaffold(
            backgroundColor: TacticalTheme.background,
            appBar: _buildAppBar(state),
            body: _buildBody(state, context),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(CombateAereoState state) {
    return AppBar(
      title: const Text('Combate Aéreo', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: TacticalTheme.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      leading: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody(CombateAereoState state, BuildContext context) {
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
            const RecursosHidricosCard(),
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
              labelSalvar: 'SALVAR REGISTRO',
              icon: Icons.check,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<String?> _executarSalvar(CombateAereoState state) async {
    if (kDebugMode) debugPrint('💾 [AÉREO PAGE] Chamando state.salvar()');
    return await state.salvar();
  }
}
