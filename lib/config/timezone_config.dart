import 'package:flutter/foundation.dart';

/// Gerencia fusos horários de Mato Grosso
/// 
/// Mato Grosso possui 2 fusos horários:
/// - UTC-4 (Horário de Brasília): Maioria do estado
/// - UTC-5 (Horário do Amazonas): Municípios da região oeste
/// 
/// Municípios em UTC-5 (Amazonas):
/// - Juína, Aripuanã, Castanheira, Juruena, Cotriguaçu, Colniza, etc.
class TimezoneConfig {
  // ✅ Tolerância de 2 minutos (em segundos) - alinhado com Keycloak
  static const int JWT_CLOCK_SKEW_TOLERANCE = 120;
  
  // Offsets dos fusos horários de Mato Grosso
  static const int BRASILIA_OFFSET_HOURS = -4;    // UTC-4
  static const int AMAZONAS_OFFSET_HOURS = -5;    // UTC-5
  static const int UNIVERSAL_OFFSET_HOURS = 0;    // UTC 0 (Geralmente Emuladores ou Servidores)
  
  /// Detecta automaticamente o fuso horário do dispositivo
  static TimezoneInfo detectDeviceTimezone() {
    final deviceOffset = DateTime.now().timeZoneOffset;
    final offsetHours = deviceOffset.inHours;
    
    TimezoneType type;
    String name;
    
    if (offsetHours == BRASILIA_OFFSET_HOURS) {
      type = TimezoneType.brasilia;
      name = 'America/Cuiaba';
    } else if (offsetHours == AMAZONAS_OFFSET_HOURS) {
      type = TimezoneType.amazonas;
      name = 'America/Porto_Velho';
    } else if (offsetHours == UNIVERSAL_OFFSET_HOURS) {
      type = TimezoneType.universal;
      name = 'UTC';
    } else {
      // Fallback: usa o offset do dispositivo
      type = TimezoneType.other;
      name = 'Device';
      
      if (kDebugMode) {
        debugPrint('[Timezone] ⚠️ Fuso horário local não é padrão de MT (UTC$offsetHours)');
      }
    }
    
    return TimezoneInfo(
      type: type,
      name: name,
      offset: deviceOffset,
      offsetHours: offsetHours,
    );
  }
  
  /// Converte DateTime local para UTC
  static DateTime toUtc(DateTime localTime) {
    return localTime.toUtc();
  }
  
  /// Converte DateTime UTC para local
  static DateTime toLocal(DateTime utcTime) {
    return utcTime.toLocal();
  }
  
  /// Formata DateTime com informação de timezone (ISO 8601)
  /// Exemplo: 2026-02-15T14:30:00-04:00
  static String formatWithTimezone(DateTime dateTime) {
    final offset = dateTime.timeZoneOffset;
    final offsetHours = (offset.inHours).abs().toString().padLeft(2, '0');
    final offsetMinutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';
    
    final date = dateTime.toIso8601String().split('.')[0]; // Remove milissegundos
    
    return '$date$sign$offsetHours:$offsetMinutes';
  }
  
  /// Cria um DateTime com timezone específico de Mato Grosso
  static DateTime createWithTimezone({
    required int year,
    required int month,
    required int day,
    int hour = 0,
    int minute = 0,
    int second = 0,
    TimezoneType timezone = TimezoneType.brasilia,
  }) {
    int offsetHours;
    switch (timezone) {
      case TimezoneType.brasilia:
        offsetHours = BRASILIA_OFFSET_HOURS;
        break;
      case TimezoneType.amazonas:
        offsetHours = AMAZONAS_OFFSET_HOURS;
        break;
      case TimezoneType.universal:
        offsetHours = UNIVERSAL_OFFSET_HOURS;
        break;
      case TimezoneType.other:
        offsetHours = DateTime.now().timeZoneOffset.inHours;
        break;
    }
    
    final utcDateTime = DateTime.utc(year, month, day, hour, minute, second);
    final localDateTime = utcDateTime.add(Duration(hours: offsetHours));
    
    return localDateTime;
  }
  
  /// Calcula diferença entre dispositivo e servidor esperado (Brasília)
  static Duration calculateOffsetFromServer() {
    final deviceOffset = DateTime.now().timeZoneOffset;
    final brasiliaOffset = Duration(hours: BRASILIA_OFFSET_HOURS);
    
    return deviceOffset - brasiliaOffset;
  }
  
  /// Log de informações de timezone (debug)
  static void debugTimezoneInfo() {
    if (!kDebugMode) return;
    
    final now = DateTime.now();
    final info = detectDeviceTimezone();
    final serverOffset = calculateOffsetFromServer();
    
    debugPrint('[Timezone] ======= INFORMAÇÕES DE FUSO HORÁRIO =======');
    debugPrint('[Timezone] Tipo detectado: ${info.type.displayName}');
    debugPrint('[Timezone] Nome: ${info.name}');
    debugPrint('[Timezone] Offset: UTC${info.offsetHours >= 0 ? '+' : ''}${info.offsetHours}');
    debugPrint('[Timezone] Hora local: ${formatWithTimezone(now)}');
    debugPrint('[Timezone] Hora UTC: ${now.toUtc().toIso8601String()}');
    debugPrint('[Timezone] Diferença do servidor (Brasília): ${serverOffset.inMinutes}min');
    debugPrint('[Timezone] Clock skew tolerance: ${JWT_CLOCK_SKEW_TOLERANCE}s');
    debugPrint('[Timezone] ================================================');
  }
}

/// Enum dos fusos horários de Mato Grosso
enum TimezoneType {
  brasilia,  // UTC-4 (Cuiabá, Rondonópolis, Sinop, etc.)
  amazonas,  // UTC-5 (Juína, Aripuanã, etc.)
  universal, // UTC 0 (Universal)
  other;     // Outro fuso (fallback)
  
  String get displayName {
    switch (this) {
      case TimezoneType.brasilia:
        return 'Horário de Brasília (UTC-4)';
      case TimezoneType.amazonas:
        return 'Horário do Amazonas (UTC-5)';
      case TimezoneType.universal:
        return 'Universal (UTC 0)';
      case TimezoneType.other:
        return 'Outro';
    }
  }
}

/// Informações de timezone
class TimezoneInfo {
  final TimezoneType type;
  final String name;
  final Duration offset;
  final int offsetHours;
  
  const TimezoneInfo({
    required this.type,
    required this.name,
    required this.offset,
    required this.offsetHours,
  });
  
  @override
  String toString() {
    return 'TimezoneInfo(type: ${type.displayName}, name: $name, offset: UTC$offsetHours)';
  }
}