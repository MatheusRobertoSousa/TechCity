import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:techcity/main.dart';
import 'package:techcity/provider.dart';

class ChamadoPage extends StatefulWidget {
  @override
  _ChamadoPageState createState() => _ChamadoPageState();
}

class _ChamadoPageState extends State<ChamadoPage> {
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController localController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController anexoController = TextEditingController();
  
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      _currentPosition = await LocationService.getCurrentLocation();
    } catch (e) {
      print('Erro ao obter localização: $e');
    }

    setState(() {
      _isLoadingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Chamado'),
        backgroundColor: Color(0xFF3B7D3C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: tipoController,
              decoration: InputDecoration(
                labelText: 'Tipo do Problema',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: localController,
              decoration: InputDecoration(
                labelText: 'Local',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descricaoController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descrição do Problema',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: anexoController,
              decoration: InputDecoration(
                labelText: 'Anexos (URLs de imagens)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_file),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gps_fixed, color: Color(0xFF3B7D3C)),
                        SizedBox(width: 8),
                        Text('Localização', style: TextStyle(fontWeight: FontWeight.bold)),
                        Spacer(),
                        if (_isLoadingLocation)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: _getCurrentLocation,
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_currentPosition != null)
                      Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\n'
                        'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    else
                      Text('Localização não disponível', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (tipoController.text.isEmpty || localController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Preencha os campos obrigatórios')),
                    );
                    return;
                  }

                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final chamados = Provider.of<ChamadosProvider>(context, listen: false);
                  
                  final novoChamado = Chamado(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    tipo: tipoController.text,
                    local: localController.text,
                    descricao: descricaoController.text,
                    anexo: anexoController.text,
                    criadoEm: DateTime.now(),
                    status: 'Aberto',
                    usuarioId: auth.usuario?.id ?? '',
                    latitude: _currentPosition?.latitude,
                    longitude: _currentPosition?.longitude,
                  );

                  final success = await chamados.criarChamado(novoChamado);
                  
                  if (success) {
                    await NotificationService.sendLocalNotification(
                      'Chamado Criado',
                      'Seu chamado foi registrado com sucesso!',
                    );
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chamado criado com sucesso!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao criar chamado')),
                    );
                  }
                },
                child: Text('Relatar Problema'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
