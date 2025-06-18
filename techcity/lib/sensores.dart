import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techcity/provider.dart';

class SensoresPage extends StatefulWidget {
  @override
  _SensoresPageState createState() => _SensoresPageState();
}

class _SensoresPageState extends State<SensoresPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 30), (_) {
      Provider.of<DadosAmbientaisProvider>(context, listen: false).buscarDadosAmbientais();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DadosAmbientaisProvider>(context, listen: false).buscarDadosAmbientais();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensores Ambientais'),
        backgroundColor: Color(0xFF3B7D3C),
        foregroundColor: Colors.white,
      ),
      body: Consumer<DadosAmbientaisProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.buscarDadosAmbientais,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: provider.isLoading ? Colors.orange : Colors.green,
                      child: Icon(
                        provider.isLoading ? Icons.sync : Icons.check,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('Status da Rede'),
                    subtitle: Text(provider.isLoading ? 'Sincronizando...' : 'Conectado'),
                    trailing: Text(
                      provider.dadosAtuais != null
                          ? 'Atualizado: ${provider.dadosAtuais!.timestamp.hour}:${provider.dadosAtuais!.timestamp.minute.toString().padLeft(2, '0')}'
                          : '',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (provider.dadosAtuais != null) ...[
                  _buildSensorCard(
                    'Temperatura',
                    '${provider.dadosAtuais!.temperatura.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    Colors.orange,
                    provider.dadosAtuais!.temperatura,
                    15.0,
                    35.0,
                  ),
                  _buildSensorCard(
                    'Umidade do Ar',
                    '${provider.dadosAtuais!.umidade.toStringAsFixed(1)}%',
                    Icons.water_drop,
                    Colors.blue,
                    provider.dadosAtuais!.umidade,
                    30.0,
                    70.0,
                  ),
                  _buildSensorCard(
                    'Qualidade do Ar (IQA)',
                    provider.dadosAtuais!.qualidadeAr.toStringAsFixed(0),
                    Icons.air,
                    Colors.green,
                    provider.dadosAtuais!.qualidadeAr,
                    0.0,
                    100.0,
                  ),
                ] else if (!provider.isLoading) ...[
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Dados não disponíveis',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Verifique sua conexão e tente novamente',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16),
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Alertas Ambientais',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (provider.dadosAtuais != null) ...[
                          if (provider.dadosAtuais!.temperatura > 30)
                            Text('⚠️ Temperatura elevada detectada'),
                          if (provider.dadosAtuais!.umidade < 40)
                            Text('⚠️ Baixa umidade do ar'),
                          if (provider.dadosAtuais!.qualidadeAr < 50)
                            Text('⚠️ Qualidade do ar abaixo do ideal'),
                          if (provider.dadosAtuais!.temperatura <= 30 &&
                              provider.dadosAtuais!.umidade >= 40 &&
                              provider.dadosAtuais!.qualidadeAr >= 50)
                            Text('✅ Todos os parâmetros dentro da normalidade'),
                        ] else
                          Text('Aguardando dados dos sensores...'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSensorCard(
    String titulo,
    String valor,
    IconData icone,
    Color cor,
    double valorNumerico,
    double minimo,
    double maximo,
  ) {
    double progresso = (valorNumerico - minimo) / (maximo - minimo);
    progresso = progresso.clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: cor, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        valor,
                        style: TextStyle(fontSize: 24, color: cor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: progresso,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(cor),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${minimo.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey)),
                Text('${maximo.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
