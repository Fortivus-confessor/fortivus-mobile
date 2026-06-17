import 'package:fortivus_app/pages/combate_incendio/terrestre/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/model/mobile_registro_avulso_request.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'ronda_state.dart';
import 'widgets/dados_atividade_card.dart';

/// Página para responder formulário de Ronda
class ResponderRondaPage extends StatelessWidget {
  final int? registroId;
  final RegistroAvulsoTemp? dadosIniciais;

  const ResponderRondaPage({
    super.key,
    this.registroId,
    this.dadosIniciais,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🏗️ [RONDA PAGE] Construindo com registroId: $registroId');
    }
    
    return ChangeNotifierProvider(
      create: (_) {
        if (kDebugMode) {
          debugPrint('🏗️ [RONDA PAGE] Criando RondaState');
        }
        return RondaState(
          registroId: registroId,
          dadosIniciais: dadosIniciais,
        );
      },
      child: const _RondaView(),
    );
  }
}

/// View principal do formulário
class _RondaView extends StatefulWidget {
  const _RondaView();

  @override
  State<_RondaView> createState() => _RondaViewState();
}

class _RondaViewState extends State<_RondaView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RondaState>(
      builder: (context, state, _) {
        if (kDebugMode) {
          debugPrint('🔧 [RONDA VIEW] isLoading: ${state.isLoading}, idRegistroAtual: ${state.idRegistroAtual}');
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

  Widget _buildFormScaffold(RondaState state, BuildContext context) {
    return PopScope(
      canPop: !state.isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && kDebugMode) {
          debugPrint('🔙 [RONDA PAGE] Voltando');
        }
      },
      child: Scaffold(
        backgroundColor: TacticalTheme.background,
        appBar: _buildAppBar(isLoading: state.isLoading),
        body: _buildFormBody(state, context),
      ),
    );
  }

  AppBar _buildAppBar({required bool isLoading}) {
    return AppBar(
      title: const Text(
        'Registro de Ronda',
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

  Widget _buildFormBody(RondaState state, BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
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
              
              const DadosAtividadeCard(),
              const SizedBox(height: 16),
              
              AnexosFotoCard(
                arquivosNotifier: state.arquivosNotifier, 
                picker: state.picker,
              ),
              const SizedBox(height: 24),

              // ✅ AQUI: O botão usa a chamada enxuta (Clean Code)
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
      ),
    );
  }

  Future<String?> _executarSalvar(RondaState state) async {
    if (kDebugMode) {
      debugPrint('💾 [RONDA PAGE] Chamando state.salvar()');
    }

    return await state.salvar();
  }
}