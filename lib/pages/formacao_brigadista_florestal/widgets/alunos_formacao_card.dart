import 'package:fortivus_app/enums/tipo_conclusao_alunos.dart';
import 'package:fortivus_app/pages/formacao_brigadista_florestal/formacao_brigadista_state.dart';
import 'package:fortivus_app/model/alunos_formacao_brigada.dart';
import 'package:fortivus_app/util/dropdown_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class AlunosFormacaoCard extends StatelessWidget {
  const AlunosFormacaoCard({super.key});

  void _abrirDialogoAluno(
    BuildContext context,
    FormacaoBrigadistaState state,
    FormFieldState<List<AlunosFormacaoBrigada>> fieldState, {
    AlunosFormacaoBrigada? aluno,
    int? index,
  }) {
    showDialog(
      context: context,
      builder: (context) => _DialogoAdicionarAluno(
        aluno: aluno,
        onSalvar: (novoAluno) {
          if (index != null) {
            state.atualizarAluno(index, novoAluno);
          } else {
            state.adicionarAluno(novoAluno);
          }
          fieldState.didChange(state.alunos);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormacaoBrigadistaState>(
      builder: (context, state, _) {
        return TacticalTheme.buildCard(
          title: "Alunos Matriculados",
          icon: Icons.people,
          iconColor: TacticalTheme.accentGreen,
          child: FormField<List<AlunosFormacaoBrigada>>(
            initialValue: state.alunos,
            validator: (_) {
              if (state.qtdBrigadistasFormados <= 0) {
                return 'Adicione ao menos um aluno formado';
              }
              return null;
            },
            builder: (fieldState) {
              return Column(
                children: [
                  InputDecorator(
                    decoration: InputDecoration(
                      errorText: fieldState.errorText,
                      border: fieldState.hasError
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                      enabledBorder: fieldState.hasError
                          ? const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red))
                          : InputBorder.none,
                      contentPadding: fieldState.hasError
                          ? const EdgeInsets.all(8)
                          : EdgeInsets.zero,
                    ),
                    child: Column(
                      children: [
                        // ✅ Lista de Alunos
                        if (state.alunos.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.group_add,
                                  size: 48,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhum aluno adicionado',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Clique no botão abaixo para adicionar alunos',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.alunos.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final aluno = state.alunos[index];
                              return _CardAluno(
                                aluno: aluno,
                                onEditar: () => _abrirDialogoAluno(
                                  context,
                                  state,
                                  fieldState,
                                  aluno: aluno,
                                  index: index,
                                ),
                                onRemover: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Remover Aluno'),
                                      content: Text(
                                        'Tem certeza que deseja remover ${aluno.nomeCompleto}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            state.removerAluno(index);
                                            fieldState.didChange(state.alunos);
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Remover',
                                            style: TextStyle(color: Colors.red[700]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Botão Adicionar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Adicionar Aluno'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TacticalTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () =>
                          _abrirDialogoAluno(context, state, fieldState),
                    ),
                  ),

                  // ✅ NOVO: Resumo com quantidade de formados
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TacticalTheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: TacticalTheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.alunos.length} aluno${state.alunos.length != 1 ? 's' : ''} adicionado${state.alunos.length != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${state.qtdBrigadistasFormados} formado${state.qtdBrigadistasFormados != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: TacticalTheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${state.qtdBrigadistasFormados}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: TacticalTheme.primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Conta apenas: Primeira Formação ou Reciclagem',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Card individual do aluno
class _CardAluno extends StatelessWidget {
  final AlunosFormacaoBrigada aluno;
  final VoidCallback onEditar;
  final VoidCallback onRemover;

  const _CardAluno({
    required this.aluno,
    required this.onEditar,
    required this.onRemover,
  });

  Color _getConclusaoColor() {
    switch (aluno.concludente) {
      case TipoConclusaoAlunos.PRIMEIRA_FORMACAO:
        return TacticalTheme.accentGreen;
      case TipoConclusaoAlunos.RECICLAGEM:
        return TacticalTheme.accentGreen;
      case TipoConclusaoAlunos.DESISTENTE:
        return Colors.red[700]!;
      case null:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Nome e Status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aluno.nomeCompleto,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      aluno.cpf,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              if (aluno.concludente != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConclusaoColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    aluno.concludente!.descricao,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getConclusaoColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          // ✅ Contatos
          if (aluno.email != null || aluno.telefone != null) ...[
            const SizedBox(height: 8),
            if (aluno.email != null)
              Row(
                children: [
                  Icon(Icons.email, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      aluno.email!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (aluno.telefone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    aluno.telefone!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],

          // ✅ Ações
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar'),
                style: TextButton.styleFrom(
                  foregroundColor: TacticalTheme.primary,
                ),
                onPressed: onEditar,
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Remover'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[700],
                ),
                onPressed: onRemover,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Diálogo para adicionar/editar aluno
class _DialogoAdicionarAluno extends StatefulWidget {
  final AlunosFormacaoBrigada? aluno;
  final Function(AlunosFormacaoBrigada) onSalvar;

  const _DialogoAdicionarAluno({
    this.aluno,
    required this.onSalvar,
  });

  @override
  State<_DialogoAdicionarAluno> createState() => _DialogoAdicionarAlunoState();
}

class _DialogoAdicionarAlunoState extends State<_DialogoAdicionarAluno> {
  late TextEditingController nomeController;
  late TextEditingController cpfController;
  late TextEditingController emailController;
  late TextEditingController telefoneController;
  late TipoConclusaoAlunos? concludente;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.aluno?.nomeCompleto ?? '');
    cpfController = TextEditingController(text: widget.aluno?.cpf ?? '');
    emailController = TextEditingController(text: widget.aluno?.email ?? '');
    telefoneController = TextEditingController(text: widget.aluno?.telefone ?? '');
    concludente = widget.aluno?.concludente;
  }

  @override
  void dispose() {
    nomeController.dispose();
    cpfController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    super.dispose();
  }

  String _formatarCPF(String cpf) {
    final digitos = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (digitos.length <= 3) return digitos;
    if (digitos.length <= 6) return '${digitos.substring(0, 3)}.${digitos.substring(3)}';
    if (digitos.length <= 9) {
      return '${digitos.substring(0, 3)}.${digitos.substring(3, 6)}.${digitos.substring(6)}';
    }
    return '${digitos.substring(0, 3)}.${digitos.substring(3, 6)}.${digitos.substring(6, 9)}-${digitos.substring(9)}';
  }

  String _formatarTelefone(String telefone) {
    final digitos = telefone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitos.length <= 2) return digitos;
    if (digitos.length <= 7) {
      return '(${digitos.substring(0, 2)}) ${digitos.substring(2)}';
    }
    return '(${digitos.substring(0, 2)}) ${digitos.substring(2, 7)}-${digitos.substring(7)}';
  }

  String? _validarCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    return null;
  }

  String? _validarTelefone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    final telefone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (telefone.length != 11) {
      return 'Telefone deve ter 11 dígitos';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(value)) {
        return 'Email inválido';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.aluno == null ? 'Adicionar Aluno' : 'Editar Aluno'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                  labelStyle: TextStyle(color: Colors.grey[700]),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (v.trim().length < 3) {
                    return 'Nome deve ter no mínimo 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: cpfController,
                decoration: InputDecoration(
                  labelText: 'CPF *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.badge),
                  hintText: '000.000.000-00',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                onChanged: (value) {
                  final formatado = _formatarCPF(value);
                  if (formatado != value) {
                    cpfController.value = TextEditingValue(
                      text: formatado,
                      selection: TextSelection.collapsed(offset: formatado.length),
                    );
                  }
                },
                validator: _validarCPF,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                  labelStyle: TextStyle(color: Colors.grey[700]),
                ),
                validator: _validarEmail,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: telefoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  hintText: '(00) 00000-0000',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                onChanged: (value) {
                  final formatado = _formatarTelefone(value);
                  if (formatado != value) {
                    telefoneController.value = TextEditingValue(
                      text: formatado,
                      selection: TextSelection.collapsed(offset: formatado.length),
                    );
                  }
                },
                validator: _validarTelefone,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<TipoConclusaoAlunos>(
                value: concludente,
                isExpanded: true,
                itemHeight: null,
                decoration: InputDecoration(
                  labelText: 'Status de Conclusão',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.check_circle),
                  labelStyle: TextStyle(color: Colors.grey[700]),
                ),
                items: DropdownUtil.buildItems<TipoConclusaoAlunos>(
                  TipoConclusaoAlunos.values,
                  (e) => e.descricao,
                ),
                selectedItemBuilder: (context) => DropdownUtil.buildSelectedItems<TipoConclusaoAlunos>(
                  TipoConclusaoAlunos.values,
                  (e) => e.descricao,
                ),
                onChanged: (value) {
                  setState(() => concludente = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Salvar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: TacticalTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final novoAluno = AlunosFormacaoBrigada(
                id: widget.aluno?.id,
                nomeCompleto: nomeController.text.trim(),
                cpf: cpfController.text.replaceAll(RegExp(r'[^\d]'), ''),
                email: emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                telefone: telefoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
                concludente: concludente,
              );
              widget.onSalvar(novoAluno);
            }
          },
        ),
      ],
    );
  }
}
