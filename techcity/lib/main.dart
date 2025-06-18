import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:techcity/chamado.dart';
import 'package:techcity/chat.dart';
import 'package:techcity/dashboard.dart';
import 'package:techcity/login.dart';
import 'package:techcity/mapa.dart';
import 'package:techcity/perfil.dart';
import 'dart:convert';
import 'dart:async';

import 'package:techcity/provider.dart';
import 'package:techcity/sensores.dart';

class Usuario {
  final String id;
  final String nome;
  final String email;
  final String idade;
  final String endereco;
  final DateTime criadoEm;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.idade,
    required this.endereco,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'idade': idade,
      'endereco': endereco,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      idade: map['idade'] ?? '',
      endereco: map['endereco'] ?? '',
      criadoEm: DateTime.parse(map['criadoEm']),
    );
  }
}

class Chamado {
  final String id;
  final String tipo;
  final String local;
  final String descricao;
  final String anexo;
  final DateTime criadoEm;
  final String status;
  final String usuarioId;
  final double? latitude;
  final double? longitude;

  Chamado({
    required this.id,
    required this.tipo,
    required this.local,
    required this.descricao,
    required this.anexo,
    required this.criadoEm,
    required this.status,
    required this.usuarioId,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'local': local,
      'descricao': descricao,
      'anexo': anexo,
      'criadoEm': criadoEm.toIso8601String(),
      'status': status,
      'usuarioId': usuarioId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Chamado.fromMap(Map<String, dynamic> map) {
    return Chamado(
      id: map['id'] ?? '',
      tipo: map['tipo'] ?? '',
      local: map['local'] ?? '',
      descricao: map['descricao'] ?? '',
      anexo: map['anexo'] ?? '',
      criadoEm: DateTime.parse(map['criadoEm']),
      status: map['status'] ?? 'Aberto',
      usuarioId: map['usuarioId'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }
}

class DadosAmbientais {
  final double temperatura;
  final double umidade;
  final double qualidadeAr;
  final String local;
  final DateTime timestamp;

  DadosAmbientais({
    required this.temperatura,
    required this.umidade,
    required this.qualidadeAr,
    required this.local,
    required this.timestamp,
  });

  factory DadosAmbientais.fromJson(Map<String, dynamic> json) {
    return DadosAmbientais(
      temperatura: json['temperatura']?.toDouble() ?? 0.0,
      umidade: json['umidade']?.toDouble() ?? 0.0,
      qualidadeAr: json['qualidadeAr']?.toDouble() ?? 0.0,
      local: json['local'] ?? '',
      timestamp: DateTime.now(),
    );
  }
}

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await _messaging.requestPermission();
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida: ${message.notification?.title}');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> sendLocalNotification(String title, String body) async {
    print('Notificação: $title - $body');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Mensagem em background: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChamadosProvider()),
        ChangeNotifierProvider(create: (_) => DadosAmbientaisProvider()),
      ],
      child: MaterialApp(
        title: 'TechCity Smart HAS',
        theme: ThemeData(
          primaryColor: Color(0xFF3B7D3C),
          scaffoldBackgroundColor: Color(0xFFFFF5CC),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF3B7D3C),
            background: Color(0xFFFFF5CC),
          ),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated ? DashboardPage() : LoginPage();
          },
        ),
        routes: {
          '/dashboard': (context) => DashboardPage(),
          '/perfil': (context) => PerfilPage(),
          '/chamado': (context) => ChamadoPage(),
          '/chat': (context) => ChatPage(),
          '/creditos': (context) => CreditosPage(),
          '/mapa': (context) => MapaPage(),
          '/sensores': (context) => SensoresPage(),
        },
      ),
    );
  }
}

class CreditosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créditos'),
      ),
      body: Center(
        child: Text('Página de Créditos'),
      ),
    );
  }
}


