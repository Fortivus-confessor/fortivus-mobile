import 'dart:convert';
import 'dart:async';
import 'package:fortivus_app/enums/coordenadas_mt.dart';
import 'package:fortivus_app/enums/municipios_mato_grosso.dart';
import 'package:fortivus_app/widgets/municipio_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class CombateMapWidget extends StatefulWidget {
  final LatLng? initialLocation;
  final String? eventoFogoGeoJson;
  final List<LatLng>? mtBorderPoints;
  final bool? isOfflineExterno;
  final bool enableManualInput;
  final bool enableDmsConverter;
  final Function(LatLng) onLocationSelected;

  const CombateMapWidget({
    super.key,
    this.initialLocation,
    this.eventoFogoGeoJson,
    this.mtBorderPoints,
    this.isOfflineExterno,
    this.enableManualInput = true,
    this.enableDmsConverter = true,
    required this.onLocationSelected,
  });

  @override
  State<CombateMapWidget> createState() => _CombateMapWidgetState();
}

class _CombateMapWidgetState extends State<CombateMapWidget> {
  final MapController _mapController = MapController();
  bool _isSatellite = true;
  bool _isOfflineLocal = false;
  bool _isCheckingConnectivity = true;
  bool _obtendoGps = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final LatLng _centerMap = const LatLng(-12.645, -55.867);
  final double _currentZoom = 6.0;
  LatLng? _selectedMarker;
  List<Polygon> _poligonosFogo = [];
  List<LatLng> _bordaMatoGrosso = [];

  bool _isModoDMS = false;

  // Controllers para Decimal
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  // Controllers para DMS
  final _latDegController = TextEditingController();
  final _latMinController = TextEditingController();
  final _latSecController = TextEditingController();
  final _lonDegController = TextEditingController();
  final _lonMinController = TextEditingController();
  final _lonSecController = TextEditingController();
  bool _latIsSul = true;
  bool _lonIsOeste = true;

  bool get _isOffline => widget.isOfflineExterno ?? _isOfflineLocal;

  @override
  void initState() {
    super.initState();
    if (widget.mtBorderPoints != null && widget.mtBorderPoints!.isNotEmpty) {
      _bordaMatoGrosso = widget.mtBorderPoints!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivity();
      _connectivitySubscription =
          Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
      _inicializarDados(isInit: true);
      if (_bordaMatoGrosso.isEmpty) {
        _baixarFronteiraMatoGrosso();
      }
    });
  }

  void _limparSnackBars() {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  Future<void> _baixarFronteiraMatoGrosso() async {
    if (_isOffline) return;

    try {
      final url = Uri.parse(
          'https://raw.githubusercontent.com/codeforamerica/click_that_hood/master/public/data/brazil-states.geojson');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List;

        final matoGrosso = features.firstWhere(
            (f) => f['properties']['name'] == "Mato Grosso",
            orElse: () => null);

        if (matoGrosso != null) {
          final geometry = matoGrosso['geometry'];
          final coordinates = geometry['coordinates'];
          List<LatLng> pontos = [];

          void extrairPontos(List dynamicCoords) {
            for (var item in dynamicCoords) {
              if (item is List &&
                  item.length == 2 &&
                  (item[0] is num || item[0] is double)) {
                pontos.add(LatLng(item[1].toDouble(), item[0].toDouble()));
              } else if (item is List) {
                extrairPontos(item);
              }
            }
          }

          extrairPontos(coordinates);

          if (mounted && pontos.isNotEmpty) {
            setState(() {
              _bordaMatoGrosso = pontos;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Erro ao baixar mapa MT: $e");
    }
  }

  Future<void> _abrirBuscaMunicipio() async {
    final municipio = await showSearch<MunicipiosMT?>(
      context: context,
      delegate: MunicipioSearchDelegate(),
    );
    if (municipio != null && mounted) {
      final coords = coordenadasMunicipios[municipio];
      if (coords == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coordenadas de ${municipio.nome} não disponíveis'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      debugPrint('🏙️ Município selecionado: ${municipio.nome}');
      debugPrint('📍 Coordenadas: $coords');
      _safeMoveMap(coords, 13.0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.location_city, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mapa centralizado em ${municipio.nome}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 80,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _latController.dispose();
    _longController.dispose();
    _latDegController.dispose();
    _latMinController.dispose();
    _latSecController.dispose();
    _lonDegController.dispose();
    _lonMinController.dispose();
    _lonSecController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (_) {}
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (!mounted) return;
    final isNowOffline = result.contains(ConnectivityResult.none);
    
    setState(() {
      _isOfflineLocal = isNowOffline;
      _isCheckingConnectivity = false;
    });
  }

  @override
  void didUpdateWidget(covariant CombateMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.eventoFogoGeoJson != widget.eventoFogoGeoJson) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _inicializarDados(isInit: false));
    }

    if (widget.initialLocation != null &&
        widget.initialLocation != _selectedMarker) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedMarker = widget.initialLocation;
          _atualizarInputsTexto(widget.initialLocation!);
        });
        if (!_isOffline) {
          _safeMoveMap(widget.initialLocation!, 15.0);
        }
      });
    }
  }

  void _inicializarDados({bool isInit = false}) {
    if (!mounted) return;

    if (widget.eventoFogoGeoJson != null &&
        widget.eventoFogoGeoJson!.isNotEmpty) {
      _processarGeoJsonFogo(widget.eventoFogoGeoJson!);
    }

    LatLng? pontoFoco;
    double? zoomFoco;

    if (widget.initialLocation != null) {
      pontoFoco = widget.initialLocation!;
      zoomFoco = 15.0;
      _selectedMarker = pontoFoco;
      _atualizarInputsTexto(pontoFoco);
    } else if (_poligonosFogo.isNotEmpty) {
      if (_poligonosFogo.first.points.isNotEmpty) {
        pontoFoco = _poligonosFogo.first.points.first;
        zoomFoco = 13.0;
      }
      _selectedMarker = null;
    } else {
      pontoFoco = _centerMap;
      zoomFoco = 6.0;
      _selectedMarker = null;
    }

    if (pontoFoco != null && !_isOffline) {
      _safeMoveMap(pontoFoco, zoomFoco ?? 13.0);
    }

    setState(() {});
  }

  void _processarGeoJsonFogo(String geoJsonString) {
    try {
      final decoded = jsonDecode(geoJsonString);
      final List<dynamic> coordinates = decoded['coordinates'];
      List<Polygon> lista = [];

      void extrairPoligonos(List coords) {
        if (coords.isEmpty) return;
        if (coords[0] is List && coords[0].length == 2 && coords[0][0] is num) {
          List<LatLng> anel = coords
              .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();
          lista.add(Polygon(
            points: anel,
            color: Colors.red.withValues(alpha: 0.3),
            borderColor: Colors.red,
            borderStrokeWidth: 2,
          ));
        } else {
          for (var item in coords) {
            if (item is List) extrairPoligonos(item);
          }
        }
      }

      if (decoded['type'] == 'Polygon' || decoded['type'] == 'MultiPolygon') {
        extrairPoligonos(coordinates);
      } else if (decoded['type'] == 'FeatureCollection') {
        for (var feature in decoded['features']) {
          if (feature['geometry'] != null) {
            extrairPoligonos(feature['geometry']['coordinates']);
          }
        }
      }

      _poligonosFogo = lista;
    } catch (e) {
      debugPrint("❌ Erro ao processar GeoJSON: $e");
    }
  }

  void _safeMoveMap(LatLng center, double zoom) {
    if (!mounted) return;

    if (!_coordenadasValidas(center)) {
      debugPrint("⚠️ Coordenadas inválidas: $center");
      return;
    }

    try {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _mapController.move(center, zoom);
        }
      });
    } catch (e) {
      debugPrint("❌ Erro ao mover mapa: $e");
    }
  }

  bool _coordenadasValidas(LatLng location) {
    return location.latitude >= -90 &&
        location.latitude <= 90 &&
        location.longitude >= -180 &&
        location.longitude <= 180;
  }

  void _atualizarInputsTexto(LatLng point) {
    if (!mounted) return;

    if (_isModoDMS) {
      _decimalParaDMS(point.latitude, point.longitude);
    } else {
      String lat = point.latitude.toStringAsFixed(6);
      String long = point.longitude.toStringAsFixed(6);

      if (_latController.text != lat) _latController.text = lat;
      if (_longController.text != long) _longController.text = long;
    }
  }

  void _decimalParaDMS(double lat, double lon) {
    _latIsSul = lat < 0;
    double absLat = lat.abs();
    int latDeg = absLat.floor();
    double latMinDecimal = (absLat - latDeg) * 60;
    int latMin = latMinDecimal.floor();
    double latSec = (latMinDecimal - latMin) * 60;

    _latDegController.text = latDeg.toString();
    _latMinController.text = latMin.toString();
    _latSecController.text = latSec.toStringAsFixed(2);

    _lonIsOeste = lon < 0;
    double absLon = lon.abs();
    int lonDeg = absLon.floor();
    double lonMinDecimal = (absLon - lonDeg) * 60;
    int lonMin = lonMinDecimal.floor();
    double lonSec = (lonMinDecimal - lonMin) * 60;

    _lonDegController.text = lonDeg.toString();
    _lonMinController.text = lonMin.toString();
    _lonSecController.text = lonSec.toStringAsFixed(2);
  }

  void _onInteracaoUsuario(LatLng point) {
    if (!mounted) return;
    _limparSnackBars();
    setState(() {
      _selectedMarker = point;
      _atualizarInputsTexto(point);
    });

    widget.onLocationSelected(point);

    if (!_isOffline) {
      _safeMoveMap(point, 15.0);
    }
  }

  void _onInputDecimalChanged() {
    String latText = _latController.text.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.\-]'), '');
    String longText = _longController.text.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.\-]'), '');

    final lat = double.tryParse(latText);
    final long = double.tryParse(longText);

    if (lat != null && long != null) {
      final newLocation = LatLng(lat, long);
      
      if (_coordenadasValidas(newLocation)) {
        setState(() => _selectedMarker = newLocation);
        widget.onLocationSelected(newLocation);
        
        if (!_isOffline) {
          _safeMoveMap(newLocation, 15.0);
        }
      } else {
        setState(() => _selectedMarker = null);
      }
    } else {
      setState(() => _selectedMarker = null);
    }
  }

  void _onInputDMSChanged() {
    double? lat = _dmsParaDecimal(
      _latDegController.text,
      _latMinController.text,
      _latSecController.text,
      _latIsSul,
    );

    double? lon = _dmsParaDecimal(
      _lonDegController.text,
      _lonMinController.text,
      _lonSecController.text,
      _lonIsOeste,
    );

    if (lat != null && lon != null) {
      setState(() => _selectedMarker = LatLng(lat, lon));
      widget.onLocationSelected(LatLng(lat, lon));
      if (!_isOffline) _safeMoveMap(LatLng(lat, lon), 15.0);
    }
  }

  double? _dmsParaDecimal(String deg, String min, String sec, bool isNegative) {
    final d = double.tryParse(deg);
    final m = double.tryParse(min);
    final s = double.tryParse(sec);

    if (d == null) return null;

    double decimal = d + ((m ?? 0) / 60) + ((s ?? 0) / 3600);
    return isNegative ? -decimal : decimal;
  }

  void _alternarModo() {
    setState(() {
      if (_isModoDMS) {
        double? lat = _dmsParaDecimal(
          _latDegController.text,
          _latMinController.text,
          _latSecController.text,
          _latIsSul,
        );
        double? lon = _dmsParaDecimal(
          _lonDegController.text,
          _lonMinController.text,
          _lonSecController.text,
          _lonIsOeste,
        );

        if (lat != null && lon != null) {
          _latController.text = lat.toStringAsFixed(6);
          _longController.text = lon.toStringAsFixed(6);
        }

        _isModoDMS = false;
      } else {
        final lat = double.tryParse(_latController.text.replaceAll(',', '.'));
        final lon = double.tryParse(_longController.text.replaceAll(',', '.'));

        if (lat != null && lon != null) {
          _decimalParaDMS(lat, lon);
        }

        _isModoDMS = true;
      }
    });
  }

  Future<void> _obterGps() async {
    setState(() => _obtendoGps = true);
    try {
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.denied ||
          p == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permissão de localização negada")),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (mounted) {
        _onInteracaoUsuario(LatLng(position.latitude, position.longitude));
      }
    } catch (e) {
      debugPrint("❌ Erro ao obter GPS: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao obter GPS")),
        );
      }
    } finally {
      if (mounted) setState(() => _obtendoGps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          clipBehavior: Clip.antiAlias,
          child: _isCheckingConnectivity
              ? const Center(child: CircularProgressIndicator())
              : (_isOffline ? _buildOfflineWarning() : _buildOnlineMap()),
        ),
        if (_selectedMarker == null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Defina a localização clicando no mapa ou usando o GPS',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _isModoDMS ? "Coordenadas DMS" : "Coordenadas Geográficas",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  if (widget.enableDmsConverter && widget.enableManualInput)
                    ElevatedButton.icon(
                      onPressed: _alternarModo,
                      icon: Icon(_isModoDMS ? Icons.numbers : Icons.calculate,
                          size: 16),
                      label: Text(
                        _isModoDMS ? 'Decimal' : 'DMS',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _isModoDMS ? _buildCamposDMS() : _buildCamposDecimais(),
            ],
          ),
        ),
      ],
    );
  }

 Widget _buildCamposDecimais() {
    final bool podeEditar = widget.enableManualInput || _isOffline;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _latController,
            enabled: podeEditar,
            decoration: InputDecoration(
              labelText: 'Latitude',
              hintText: '-12.97',
              isDense: true,
              border: const OutlineInputBorder(),
              filled: !podeEditar,
              fillColor: !podeEditar ? Colors.grey[200] : null,
              prefixIcon: const Icon(Icons.swap_vert, size: 16),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), 
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
            ],
            onChanged: podeEditar ? (_) => _onInputDecimalChanged() : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _longController,
            enabled: podeEditar,
            decoration: InputDecoration(
              labelText: 'Longitude',
              hintText: '-55.51',
              isDense: true,
              border: const OutlineInputBorder(),
              filled: !podeEditar,
              fillColor: !podeEditar ? Colors.grey[200] : null,
              prefixIcon: const Icon(Icons.swap_horiz, size: 16),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
            ],
            onChanged: podeEditar ? (_) => _onInputDecimalChanged() : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCamposDMS() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 60,
              child:
                  Text('Lat:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: TextField(
                controller: _latDegController,
                decoration: const InputDecoration(
                  labelText: '°',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _onInputDMSChanged(),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _latMinController,
                decoration: const InputDecoration(
                  labelText: "'",
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _onInputDMSChanged(),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _latSecController,
                decoration: const InputDecoration(
                  labelText: '"',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _onInputDMSChanged(),
              ),
            ),
            const SizedBox(width: 4),
            ToggleButtons(
              isSelected: [_latIsSul, !_latIsSul],
              onPressed: (idx) {
                setState(() => _latIsSul = idx == 0);
                _onInputDMSChanged();
              },
              constraints: const BoxConstraints(minHeight: 40, minWidth: 32),
              borderRadius: BorderRadius.circular(8),
              children: const [
                Text('S', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('N', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(
              width: 60,
              child:
                  Text('Lon:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: TextField(
                controller: _lonDegController,
                decoration: const InputDecoration(
                  labelText: '°',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _onInputDMSChanged(),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _lonMinController,
                decoration: const InputDecoration(
                  labelText: "'",
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _onInputDMSChanged(),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _lonSecController,
                decoration: const InputDecoration(
                  labelText: '"',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _onInputDMSChanged(),
              ),
            ),
            const SizedBox(width: 4),
            ToggleButtons(
              isSelected: [_lonIsOeste, !_lonIsOeste],
              onPressed: (idx) {
                setState(() => _lonIsOeste = idx == 0);
                _onInputDMSChanged();
              },
              constraints: const BoxConstraints(minHeight: 40, minWidth: 32),
              borderRadius: BorderRadius.circular(8),
              children: const [
                Text('W', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('E', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOfflineWarning() {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 64, color: Colors.grey[500]),
          const SizedBox(height: 16),
          Text(
            "Mapa indisponível Offline",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          const Text(
            "Sem conexão com a internet. O mapa visual não pode ser carregado.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _obtendoGps ? null : _obterGps,
              icon: _obtendoGps
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: Colors.white),
              label: Text(
                _obtendoGps ? 'Buscando satélites...' : 'Pegar Minha Localização (GPS)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200)),
            child: const Text(
              "✅ Use o GPS ou insira as coordenadas nos campos abaixo.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _centerMap,
            initialZoom: _currentZoom,
            minZoom: 3.0,
            maxZoom: 18.0,
            onTap: (_, point) => _onInteracaoUsuario(point),
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture) {
                _limparSnackBars();
              }
            },
            cameraConstraint: CameraConstraint.unconstrained(),
          ),
          children: [
            TileLayer(
              maxNativeZoom: 17,
              urlTemplate: _isSatellite
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'br.gov.mt.fortivus',
            ),
            if (_bordaMatoGrosso.isNotEmpty)
              PolygonLayer(polygons: [
                Polygon(
                  points: _bordaMatoGrosso,
                  color: Colors.transparent,
                  borderColor: Colors.red,
                  borderStrokeWidth: 3.0,
                  pattern: const StrokePattern.dotted(),
                ),
              ]),
            if (_poligonosFogo.isNotEmpty)
              PolygonLayer(polygons: _poligonosFogo),
            if (_selectedMarker != null)
              MarkerLayer(markers: [
                Marker(
                  point: _selectedMarker!,
                  width: 40,
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.location_on,
                      color: Colors.blue, size: 40),
                )
              ]),
          ],
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: "searchMunicipioBtn",
                backgroundColor: Colors.white,
                tooltip: "Buscar município do MT",
                onPressed: _abrirBuscaMunicipio,
                child: const Icon(Icons.search, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: "layerBtnWidget",
                backgroundColor: Colors.white,
                tooltip:
                    _isSatellite ? "Mudar para Ruas" : "Mudar para Satélite",
                onPressed: () => setState(() => _isSatellite = !_isSatellite),
                child: Icon(_isSatellite ? Icons.layers : Icons.layers_clear,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: "gpsBtnMap",
                backgroundColor: Colors.blue[700],
                tooltip: "Centralizar no meu GPS",
                onPressed: _obtendoGps ? null : _obterGps,
                child: _obtendoGps
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
