import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techcity/provider.dart';

class PerfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Color(0xFF3B7D3C),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFF3B7D3C),
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.person, color: Color(0xFF3B7D3C)),
                          title: Text('Nome'),
                          subtitle: Text(auth.usuario?.nome ?? 'Não informado'),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.email, color: Color(0xFF3B7D3C)),
                          title: Text('Email'),
                          subtitle: Text(auth.usuario?.email ?? 'Não informado'),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.cake, color: Color(0xFF3B7D3C)),
                          title: Text('Idade'),
                          subtitle: Text('${auth.usuario?.idade ?? 'Não informado'} anos'),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.location_on, color: Color(0xFF3B7D3C)),
                          title: Text('Endereço'),
                          subtitle: Text(auth.usuario?.endereco ?? 'Não informado'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.settings, color: Color(0xFF3B7D3C)),
                        title: Text('Configurações'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(context, '/configuracoes');
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.help, color: Color(0xFF3B7D3C)),
                        title: Text('Ajuda'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(context, '/ajuda');
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.info, color: Color(0xFF3B7D3C)),
                        title: Text('Sobre'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () => Navigator.pushNamed(context, '/creditos'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text('Sair', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Confirmar Saída'),
                              content: Text('Deseja realmente sair do aplicativo?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    auth.logout();
                                  },
                                  child: Text(
                                    'Sair',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/editar-perfil');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3B7D3C),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Editar Perfil',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
