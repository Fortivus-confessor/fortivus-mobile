import 'package:fortivus_app/pages/formacao_brigadista_florestal/formacao_brigadista_state.dart';
import 'package:fortivus_app/pages/formacao_brigadista_florestal/widgets/localizacao_formacao.dart';
import 'package:fortivus_app/widgets/anexos_foto_card.dart';
import 'package:fortivus_app/widgets/historico_card.dart';
import 'package:fortivus_app/widgets/localizacao_generico_card.dart';
import 'package:fortivus_app/pages/formacao_brigadista_florestal/widgets/capacitacao_formacao_card.dart';
import 'package:fortivus_app/pages/formacao_brigadista_florestal/widgets/acidentes_formacao_card.dart';
import 'package:fortivus_app/pages/formacao_brigadista_florestal/widgets/alunos_formacao_card.dart';
import 'package:fortivus_app/pages/formacao_brigadista_florestal/widgets/qts_novo_card.dart';
import 'package:fortivus_app/widgets/formulario_salvar_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/model/mobile_registro_avulso_request.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class ResponderFormacaoPage extends StatelessWidget {
  final int? registroId;
  final RegistroAvulsoTemp? dadosIniciais;
  final double? latitudeRo;
  final double? longitudeRo;
  final DateTime? dataInicialDespacho;
  final DateTime? dataFinalDespacho;

  static const String _pageTitle = 'Formação de Brigadista';
  static const String _saveBtnLabel = 'SALVAR FORMAÇÃO';
  static const String _localizacaoTitle = 'Localização da Atividade';
  static const String _localizacaoSubtitle =
      'Selecione a localização onde a formação foi realizada';

  const ResponderFormacaoPage({
    super.key,
    this.registroId,
    this.dadosIniciais,
    this.latitudeRo,
    this.longitudeRo,
    this.dataInicialDespacho,
    this.dataFinalDespacho,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvulso = registroId == null;

    if (kDebugMode) {
      debugPrint('🏗️ [FORMACAO PAGE] Construindo');
      debugPrint('   - registroId: $registroId');
      debugPrint('   - isAvulso: $isAvulso');
      debugPrint('   - latitudeRo: $latitudeRo');
      debugPrint('   - longitudeRo: $longitudeRo');
      debugPrint('   - dataInicialDespacho: $dataInicialDespacho');
      debugPrint('   - dataFinalDespacho: $dataFinalDespacho');
    }

    return ChangeNotifierProvider(
      create: (_) {
        if (kDebugMode) {
          debugPrint('🏗️ [FORMACAO PAGE] Criando FormacaoBrigadistaState');
          debugPrint('   - Passando dados de despacho: ${!isAvulso}');
        }

        return FormacaoBrigadistaState(
          registroId: registroId,
          dadosIniciais: dadosIniciais,
          latitudeDespacho: isAvulso ? null : latitudeRo,
          longitudeDespacho: isAvulso ? null : longitudeRo,
          deslocamentoInicialDespacho: isAvulso ? null : dataInicialDespacho,
          deslocamentoFinalDespacho: isAvulso ? null : dataFinalDespacho,
          isAvulso: isAvulso,
        );
      },
      child: const _FormacaoView(),
    );
  }
}

class _FormacaoView extends StatefulWidget {
  const _FormacaoView();

  @override
  State<_FormacaoView> createState() => _FormacaoViewState();
}

class _FormacaoViewState extends State<_FormacaoView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FormacaoBrigadistaState>(
      builder: (context, state, _) {
        if (kDebugMode) {
          debugPrint('🔧 [FORMACAO VIEW] isLoading: ${state.isLoading}');
        }

        if (state.isLoading) {
          return _buildLoadingScaffold();
        }

        return _buildFormScaffold(state, context);
      },
    );
  }

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
    FormacaoBrigadistaState state,
    BuildContext context,
  ) {
    return PopScope(
      canPop: !state.isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && kDebugMode) {
          debugPrint('🔙 [FORMAÇÃO PAGE] Voltando');
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
    FormacaoBrigadistaState state,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: state.formKey,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            return false;
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (state.isAvulso)
                  _buildLocalizacaoAvulso(state)
                else
                  _buildLocalizacaoResposta(),
                const SizedBox(height: 16),

                const CapacitacaoFormacaoCard(),
                const SizedBox(height: 16),

                const AcidentesFormacaoCard(),
                const SizedBox(height: 16),

                HistoricoDescritivoCard(
                  historicoController: state.historicoController,
                  title: 'Histórico',
                  labelHistorico: 'Relato da Ocorrência *',
                ),
                const SizedBox(height: 16),

                const AlunosFormacaoCard(),
                const SizedBox(height: 16),

                const QtsNovoCard(),
                const SizedBox(height: 16),

                AnexosFotoCard(
                  arquivosNotifier: state.arquivosNotifier,
                  picker: state.picker,
                ),
                const SizedBox(height: 24),

                // ✅ AQUI: Chamada enxuta
                FormularioSalvarButton(
                  isLoading: state.isLoading,
                  onSalvar: ({onSucessoAntesDeFechar}) => _executarSalvar(state),
                  labelSalvar: ResponderFormacaoPage._saveBtnLabel,
                  icon: Icons.check,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar({required bool isLoading}) {
    return AppBar(
      title: const Text(
        ResponderFormacaoPage._pageTitle,
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

  Widget _buildLocalizacaoAvulso(FormacaoBrigadistaState state) {
    return LocalizacaoGenericoCard(
      title: ResponderFormacaoPage._localizacaoTitle,
      subtitle: ResponderFormacaoPage._localizacaoSubtitle,
      mostrarVerificacaoDespacho: false,
      localizacaoNotifier: state.localizacaoNotifier,
      isOffline: state.isOffline,
      onLocationSelected: (latLng) {
        state.setLocalizacao(latLng);
      },
      deslocamentoInicial: state.deslocamentoInicialGuarnicao,
      deslocamentoFinal: state.deslocamentoFinalGuarnicao,
      onDeslocamentoInicialChanged: state.setDeslocamentoInicial,
      onDeslocamentoFinalChanged: state.setDeslocamentoFinal,
    );
  }

  Widget _buildLocalizacaoResposta() {
    return const LocalizacaoFormacaoCard();
  }

  Future<String?> _executarSalvar(FormacaoBrigadistaState state) async {
    if (kDebugMode) {
      debugPrint('💾 [FORMACAO PAGE] Chamando state.salvar()');
    }

    return await state.salvar();
  }
}