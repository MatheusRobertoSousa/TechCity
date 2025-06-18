import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techcity/main.dart';
import 'package:techcity/provider.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final chamados = Provider.of<ChamadosProvider>(context, listen: false);
      final sensores = Provider.of<DadosAmbientaisProvider>(context, listen: false);

      if (auth.usuario != null) {
        chamados.carregarChamados(auth.usuario!.id);
        sensores.buscarDadosAmbientais();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard TechCity'),
        backgroundColor: Color(0xFF3B7D3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF3B7D3C),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bem-vindo, ${auth.usuario?.nome ?? 'Usuário'}!',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text('${auth.usuario?.endereco ?? ''}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Consumer<DadosAmbientaisProvider>(
              builder: (context, provider, _) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.eco, color: Color(0xFF3B7D3C)),
                            SizedBox(width: 8),
                            Text(
                              'Dados Ambientais',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            if (provider.isLoading)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: () => provider.buscarDadosAmbientais(),
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                        if (provider.dadosAtuais != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDadoAmbiental(
                                'Temperatura',
                                '${provider.dadosAtuais!.temperatura.toStringAsFixed(1)}°C',
                                Icons.thermostat,
                                Colors.orange,
                              ),
                              _buildDadoAmbiental(
                                'Umidade',
                                '${provider.dadosAtuais!.umidade.toStringAsFixed(1)}%',
                                Icons.water_drop,
                                Colors.blue,
                              ),
                              _buildDadoAmbiental(
                                'Qualidade do Ar',
                                '${provider.dadosAtuais!.qualidadeAr.toStringAsFixed(0)}',
                                Icons.air,
                                Colors.green,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Ações Rápidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildActionCard(
                  'Novo Chamado',
                  Icons.add_alert,
                  Colors.red,
                  () => Navigator.pushNamed(context, '/chamado'),
                ),
                _buildActionCard(
                  'Mapa',
                  Icons.map,
                  Colors.blue,
                  () => Navigator.pushNamed(context, '/mapa'),
                ),
                _buildActionCard(
                  'Chat Athena',
                  Icons.chat,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/chat'),
                ),
                _buildActionCard(
                  'Sensores',
                  Icons.sensors,
                  Colors.green,
                  () => Navigator.pushNamed(context, '/sensores'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Consumer<ChamadosProvider>(
              builder: (context, provider, _) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chamados Recentes',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        if (provider.isLoading)
                          Center(child: CircularProgressIndicator())
                        else if (provider.chamados.isEmpty)
                          Text('Nenhum chamado encontrado')
                        else
                          ...provider.chamados.take(3).map((chamado) => ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(chamado.status),
                                  child: Icon(Icons.report_problem, color: Colors.white),
                                ),
                                title: Text(chamado.tipo),
                                subtitle: Text(chamado.local),
                                trailing: Text(chamado.status),
                              )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF3B7D3C),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/mapa');
              break;
            case 2:
              Navigator.pushNamed(context, '/chat');
              break;
            case 3:
              Navigator.pushNamed(context, '/perfil');
              break;
          }
        },
      ),
    );
  }

  Widget _buildDadoAmbiental(String titulo, String valor, IconData icone, Color cor) {
    return Column(
      children: [
        Icon(icone, color: cor, size: 32),
        SizedBox(height: 4),
        Text(titulo, style: TextStyle(fontSize: 12)),
        Text(valor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionCard(String titulo, IconData icone, Color cor, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, color: cor, size: 32),
              SizedBox(height: 8),
              Text(titulo, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aberto':
        return Colors.red;
      case 'em andamento':
        return Colors.orange;
      case 'resolvido':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
