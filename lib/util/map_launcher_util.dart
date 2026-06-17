import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncherUtil {
  static Future<void> openMapsDialog(BuildContext context, double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização não disponível para este registro')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Abrir Mapa'),
          content: const Text('Escolha o aplicativo de navegação:'),
          actions: <Widget>[
            TextButton(
              child: const Text('Google Maps'),
              onPressed: () {
                _launchGoogleMaps(latitude, longitude);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Waze'),
              onPressed: () {
                _launchWaze(latitude, longitude);
                Navigator.of(context).pop();
              },
            ),
            if (Platform.isIOS)
              TextButton(
                child: const Text('Gaia GPS'),
                onPressed: () {
                  _launchGaiaGPS(context, latitude, longitude);
                  Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: const Text('AlpineQuest'),
              onPressed: () {
                Navigator.of(context).pop();
                _launchAlpineQuest(context, latitude, longitude);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> _launchGoogleMaps(double latitude, double longitude) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _launchWaze(double latitude, double longitude) async {
    final url = Uri.parse('waze://?ll=$latitude,$longitude&navigate=yes');
    final fallbackUrl = Uri.parse('https://waze.com/ul?ll=$latitude,$longitude&navigate=yes');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(fallbackUrl)) {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _launchGaiaGPS(BuildContext context, double latitude, double longitude) async {
    // Esqueleto de URL para Gaia GPS: gaiagps://ll?lat=...&lng=...
    final url = Uri.parse('gaiagps://map?lat=$latitude&lng=$longitude');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gaia GPS não está instalado ou não pôde ser aberto.')),
        );
      }
    }
  }

  static Future<void> _launchAlpineQuest(BuildContext context, double latitude, double longitude) async {
    final url = Uri.parse('geo:$latitude,$longitude');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir um aplicativo de mapa compatível.')),
        );
      }
    }
  }
}
