import 'package:flutter/material.dart';
import '../enums/municipios_mato_grosso.dart';
import '../enums/coordenadas_mt.dart';

class MunicipioSearchDelegate extends SearchDelegate<MunicipiosMT?> {
  @override
  String get searchFieldLabel => 'Buscar município do MT...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: 'Limpar busca',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Voltar',
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildMunicipiosList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildMunicipiosList(context);
  }

  /// ✅ Remove acentos de uma string para busca
  String _removerAcentos(String texto) {
    const comAcento = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const semAcento = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';
    
    String resultado = texto;
    for (int i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado;
  }

  Widget _buildMunicipiosList(BuildContext context) {
    // Filtra municípios com coordenadas disponíveis
    final municipiosComCoordenadas = MunicipiosMT.values
        .where((m) => coordenadasMunicipios.containsKey(m))
        .toList();

    // ✅ Aplica filtro de busca SEM ACENTO
    final filtrados = query.isEmpty
        ? municipiosComCoordenadas
        : municipiosComCoordenadas.where((municipio) {
            final nomeSemAcento = _removerAcentos(municipio.nome.toLowerCase());
            final buscaSemAcento = _removerAcentos(query.toLowerCase());
            return nomeSemAcento.contains(buscaSemAcento);
          }).toList();

    // Ordena alfabeticamente
    filtrados.sort((a, b) => a.nome.compareTo(b.nome));

    if (filtrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum município encontrado',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente: "Cuiaba", "Sinop", "Rondonopolis"',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header com contador
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue[50],
          child: Row(
            children: [
              Icon(Icons.location_city, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                '${filtrados.length} município${filtrados.length != 1 ? 's' : ''} encontrado${filtrados.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
        ),

        // Lista de municípios
        Expanded(
          child: ListView.separated(
            itemCount: filtrados.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final municipio = filtrados[index];
              final coords = coordenadasMunicipios[municipio]!;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[700],
                  child: Text(
                    municipio.nome[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  municipio.nome,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Lat: ${coords.latitude.toStringAsFixed(4)}, '
                  'Lng: ${coords.longitude.toStringAsFixed(4)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                onTap: () => close(context, municipio),
              );
            },
          ),
        ),
      ],
    );
  }
}