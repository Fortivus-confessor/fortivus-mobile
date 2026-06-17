import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/widgets/combate_map_widget.dart';

/// Card genérico para localização com mapa em formulários
/// 
/// Uso básico:
/// ```dart
/// LocalizacaoMapaCard(
///   localizacaoNotifier: state.localizacaoNotifier,
///   eventoFogoGeoJson: state.eventoFogoGeoJson,
///   isOffline: state.isOffline,
/// )
/// ```
/// 
/// Uso com customização:
/// ```dart
/// LocalizacaoMapaCard(
///   localizacaoNotifier: state.localizacaoNotifier,
///   eventoFogoGeoJson: state.eventoFogoGeoJson,
///   isOffline: state.isOffline,
///   title: 'Localização da Operação',
///   enableManualInput: false,  // Desabilita digitação
///   enableDmsConverter: true,  // Habilita conversor DMS
/// )
/// ```
class LocalizacaoMapaCard extends StatelessWidget {
  /// Notifier com a localização atual
  final ValueNotifier<LatLng?> localizacaoNotifier;

  /// GeoJSON do evento de fogo (opcional)
  final String? eventoFogoGeoJson;

  /// Se está offline
  final bool isOffline;

  /// Título do card
  final String title;

  /// Ícone do card
  final IconData icon;

  /// Permite digitação manual de coordenadas
  final bool enableManualInput;

  /// Habilita conversor entre Decimal e DMS
  final bool enableDmsConverter;

  /// Texto de aviso quando não há localização
  final String? avisoSemLocalizacao;

  const LocalizacaoMapaCard({
    super.key,
    required this.localizacaoNotifier,
    this.eventoFogoGeoJson,
    required this.isOffline,
    this.title = 'Localização',
    this.icon = Icons.map,
    this.enableManualInput = true,
    this.enableDmsConverter = true,
    this.avisoSemLocalizacao,
  });

  @override
  Widget build(BuildContext context) {
    return TacticalTheme.buildCard(
      title: title,
      icon: icon,
      child: FormField<LatLng>(
        initialValue: localizacaoNotifier.value,
        validator: (v) {
          if (localizacaoNotifier.value == null) {
            return 'Localização é obrigatória';
          }
          return null;
        },
        builder: (fieldState) {
          return ValueListenableBuilder<LatLng?>(
            valueListenable: localizacaoNotifier,
            builder: (context, localizacao, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: CombateMapWidget(
                      initialLocation: localizacao,
                      eventoFogoGeoJson: eventoFogoGeoJson,
                      isOfflineExterno: isOffline,
                      onLocationSelected: (latLng) {
                        localizacaoNotifier.value = latLng;
                        fieldState.didChange(latLng);
                      },
                      enableManualInput: enableManualInput,
                      enableDmsConverter: enableDmsConverter,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
