import 'package:fortivus_app/util/dropdown_util.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:fortivus_app/model/propriedade_apoio.dart';
import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/widgets/combate_map_widget.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class PropriedadeDialog extends StatefulWidget {
  final PropriedadeApoio? existente;
  final LatLng? localizacaoInicial;
  final String? eventoFogoGeoJson;

  const PropriedadeDialog({
    super.key,
    this.existente,
    this.localizacaoInicial,
    this.eventoFogoGeoJson,
  });

  @override
  State<PropriedadeDialog> createState() => _PropriedadeDialogState();
}

class _PropriedadeDialogState extends State<PropriedadeDialog> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _respCtrl;
  late final TextEditingController _foneCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _longCtrl;
  late final TextEditingController _maqCtrl;
  late final TextEditingController _maoCtrl;
  late final TextEditingController _apoioOutroCtrl;
  late final TextEditingController _motivoOutroCtrl;
  late final MaskTextInputFormatter _maskFone;

  TipoInteracaoPropriedade? _tipoInteracao;
  TipoMotivoRecusa? _motivoRecusa;

  @override
  void initState() {
    super.initState();
    final existente = widget.existente;

    _nomeCtrl = TextEditingController(text: existente?.nomePropriedade);
    _respCtrl = TextEditingController(text: existente?.nomeProprietario);
    _foneCtrl = TextEditingController(text: existente?.contato);
    _latCtrl = TextEditingController(text: existente?.latitude?.toString());
    _longCtrl = TextEditingController(text: existente?.longitude?.toString());
    _maqCtrl = TextEditingController(text: existente?.quantidadeMaquinario?.toString());
    _maoCtrl = TextEditingController(text: existente?.quantidadeMaoObra?.toString());
    _apoioOutroCtrl = TextEditingController(text: existente?.apoioOutro);
    _motivoOutroCtrl = TextEditingController(text: existente?.motivoOutro);

    _maskFone = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
    );

    _tipoInteracao = existente?.tipoInteracao;
    _motivoRecusa = existente?.motivoRecusa;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _respCtrl.dispose();
    _foneCtrl.dispose();
    _latCtrl.dispose();
    _longCtrl.dispose();
    _maqCtrl.dispose();
    _maoCtrl.dispose();
    _apoioOutroCtrl.dispose();
    _motivoOutroCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_tipoInteracao == null || _nomeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios')),
      );
      return;
    }

    if (_tipoInteracao == TipoInteracaoPropriedade.RECUSA) {
      if (_motivoRecusa == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione o motivo da recusa')),
        );
        return;
      }
      if (_motivoRecusa == TipoMotivoRecusa.OUTRO && _motivoOutroCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Descreva o motivo "Outro"')),
        );
        return;
      }
    }

    final nova = PropriedadeApoio(
      id: widget.existente?.id,
      nomePropriedade: _nomeCtrl.text.trim(),
      nomeProprietario: _respCtrl.text.trim().isEmpty ? null : _respCtrl.text.trim(),
      contato: _foneCtrl.text.trim().isEmpty ? null : _foneCtrl.text.trim(),
      latitude: double.tryParse(_latCtrl.text),
      longitude: double.tryParse(_longCtrl.text),
      tipoInteracao: _tipoInteracao,
      quantidadeMaquinario: _tipoInteracao == TipoInteracaoPropriedade.APOIO
          ? int.tryParse(_maqCtrl.text)
          : null,
      quantidadeMaoObra: _tipoInteracao == TipoInteracaoPropriedade.APOIO
          ? int.tryParse(_maoCtrl.text)
          : null,
      apoioOutro: _tipoInteracao == TipoInteracaoPropriedade.APOIO && _apoioOutroCtrl.text.trim().isNotEmpty
          ? _apoioOutroCtrl.text.trim()
          : null,
      motivoRecusa: _tipoInteracao == TipoInteracaoPropriedade.RECUSA
          ? _motivoRecusa
          : null,
      motivoOutro: (_tipoInteracao == TipoInteracaoPropriedade.RECUSA &&
              _motivoRecusa == TipoMotivoRecusa.OUTRO &&
              _motivoOutroCtrl.text.trim().isNotEmpty)
          ? _motivoOutroCtrl.text.trim()
          : null,
    );

    Navigator.pop(context, nova);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.85;

    LatLng? localInicial;
    if (widget.existente?.latitude != null && widget.existente?.longitude != null) {
      localInicial = LatLng(widget.existente!.latitude!, widget.existente!.longitude!);
    } else if (widget.localizacaoInicial != null) {
      localInicial = widget.localizacaoInicial;
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER FIXO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: TacticalTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.agriculture, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.existente == null ? 'Nova Propriedade' : 'Editar Propriedade',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // CONTEÚDO SCROLLÁVEL
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CombateMapWidget(
                          initialLocation: localInicial,
                          eventoFogoGeoJson: widget.eventoFogoGeoJson,
                          enableManualInput: true,
                          onLocationSelected: (ponto) {
                            _latCtrl.text = ponto.latitude.toStringAsFixed(8);
                            _longCtrl.text = ponto.longitude.toStringAsFixed(8);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nome
                    TextField(
                      controller: _nomeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Propriedade *',
                        prefixIcon: Icon(Icons.home, size: 18),
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Responsável e Telefone
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _respCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Responsável',
                              prefixIcon: Icon(Icons.person, size: 18),
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _foneCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Telefone',
                              prefixIcon: Icon(Icons.phone, size: 18),
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_maskFone],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tipo de Interação
                    DropdownButtonFormField<TipoInteracaoPropriedade>(
                      value: _tipoInteracao,
                      isExpanded: true,
                      itemHeight: null,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Interação *',
                        prefixIcon: Icon(Icons.handshake, size: 18),
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                      items: DropdownUtil.buildItems<TipoInteracaoPropriedade>(
                        TipoInteracaoPropriedade.values,
                        (e) => e.descricao,
                      ),
                      selectedItemBuilder: (context) => DropdownUtil.buildSelectedItems<TipoInteracaoPropriedade>(
                        TipoInteracaoPropriedade.values,
                        (e) => e.descricao,
                      ),
                      onChanged: (v) {
                        setState(() {
                          _tipoInteracao = v;
                          if (v == TipoInteracaoPropriedade.APOIO) {
                            _motivoRecusa = null;
                            _motivoOutroCtrl.clear();
                          } else {
                            _maqCtrl.clear();
                            _maoCtrl.clear();
                            _apoioOutroCtrl.clear();
                          }
                        });
                      },
                    ),

                    // Seção Apoio
                    if (_tipoInteracao == TipoInteracaoPropriedade.APOIO) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Recursos Disponibilizados",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _maqCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Maquinário',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _maoCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Mão de Obra',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _apoioOutroCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Outro apoio',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Seção Recusa
                    if (_tipoInteracao == TipoInteracaoPropriedade.RECUSA) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Detalhes da Recusa",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<TipoMotivoRecusa>(
                              value: _motivoRecusa,
                              isExpanded: true,
                              itemHeight: null,
                              decoration: const InputDecoration(
                                labelText: 'Motivo da Recusa *',
                                border: OutlineInputBorder(),
                                fillColor: Colors.white,
                                filled: true,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              ),
                              items: DropdownUtil.buildItems<TipoMotivoRecusa>(
                                TipoMotivoRecusa.values,
                                (e) => e.descricao,
                              ),
                              selectedItemBuilder: (context) => DropdownUtil.buildSelectedItems<TipoMotivoRecusa>(
                                TipoMotivoRecusa.values,
                                (e) => e.descricao,
                              ),
                              onChanged: (v) {
                                setState(() {
                                  _motivoRecusa = v;
                                  if (v != TipoMotivoRecusa.OUTRO) {
                                    _motivoOutroCtrl.clear();
                                  }
                                });
                              },
                            ),
                            if (_motivoRecusa == TipoMotivoRecusa.OUTRO) ...[
                              const SizedBox(height: 8),
                              TextField(
                                controller: _motivoOutroCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Descreva o motivo *',
                                  border: OutlineInputBorder(),
                                  fillColor: Colors.white,
                                  filled: true,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ACTIONS FIXO
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _salvar,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text("Salvar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TacticalTheme.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
