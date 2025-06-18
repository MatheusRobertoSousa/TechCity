import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:techcity/main.dart';
import 'package:techcity/provider.dart';

class MapaPage extends StatefulWidget {
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  GoogleMapController? _controller;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      _currentPosition = await LocationService.getCurrentLocation();
      await _loadChamadosMarkers();
      _addSmartDevicesMarkers();
    } catch (e) {
      print('Erro ao inicializar mapa: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadChamadosMarkers() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chamados = Provider.of<ChamadosProvider>(context, listen: false);

    await chamados.carregarChamados(auth.usuario?.id ?? '');

    for (var chamado in chamados.chamados) {
      if (chamado.latitude != null && chamado.longitude != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(chamado.id),
            position: LatLng(chamado.latitude!, chamado.longitude!),
            infoWindow: InfoWindow(
              title: chamado.tipo,
              snippet: chamado.local,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }
  }

  void _addSmartDevicesMarkers() {
    final dispositivos = [
      {'nome': 'Sensor de Qualidade do Ar #1', 'lat': -23.550520, 'lng': -46.633308, 'tipo': 'sensor'},
      {'nome': 'Câmera de Segurança #1', 'lat': -23.551520, 'lng': -46.634308, 'tipo': 'camera'},
      {'nome': 'Estação Meteorológica #1', 'lat': -23.549520, 'lng': -46.632308, 'tipo': 'weather'},
      {'nome': 'Sensor de Ruído #1', 'lat': -23.552520, 'lng': -46.635308, 'tipo': 'noise'},
      {'nome': 'Ponto de Coleta Inteligente', 'lat': -23.548520, 'lng': -46.631308, 'tipo': 'waste'},
    ];

    for (var dispositivo in dispositivos) {
      Color cor = Colors.blue;
      BitmapDescriptor icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

      switch (dispositivo['tipo']) {
        case 'sensor':
          cor = Colors.green;
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
          break;
        case 'camera':
          cor = Colors.purple;
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
          break;
        case 'weather':
          cor = Colors.orange;
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
          break;
        case 'noise':
          cor = Colors.yellow;
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
          break;
        case 'waste':
          cor = Colors.brown;
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
          break;
      }

      _markers.add(
        Marker(
          markerId: MarkerId(dispositivo['nome'] as String),
          position: LatLng(dispositivo['lat'] as double, dispositivo['lng'] as double),
          infoWindow: InfoWindow(
            title: dispositivo['nome'] as String,
            snippet: 'Dispositivo Smart City',
          ),
          icon: icon,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mapa Smart City'),
          backgroundColor: Color(0xFF3B7D3C),
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa Smart City'),
        backgroundColor: Color(0xFF3B7D3C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildLegendItem('Chamados', Colors.red),
                  _buildLegendItem('Sensores', Colors.green),
                  _buildLegendItem('Câmeras', Colors.purple),
                  _buildLegendItem('Meteorologia', Colors.orange),
                  _buildLegendItem('Ruído', Colors.yellow),
                  _buildLegendItem('Coleta', Colors.brown),
                ],
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : LatLng(-23.550520, -46.633308),
                zoom: 15,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_currentPosition != null) {
            await _controller?.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              ),
            );
          }
        },
        backgroundColor: Color(0xFF3B7D3C),
        child: Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
