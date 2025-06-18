import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:techcity/main.dart';

class AuthProvider extends ChangeNotifier {
  Usuario? _usuario;
  bool _isLoading = false;
  String _errorMessage = '';

  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _usuario != null;

  Future<bool> login(String email, String senha) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(Duration(seconds: 2));

      if (email.isNotEmpty && senha.isNotEmpty) {
        _usuario = Usuario(
          id: '1',
          nome: 'Usuário TechCity',
          email: email,
          idade: '25',
          endereco: 'São Paulo, SP',
          criadoEm: DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Email e senha são obrigatórios';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao fazer login: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cadastrar(String nome, String email, String idade, String endereco, String senha) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(Duration(seconds: 2));

      _usuario = Usuario(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: nome,
        email: email,
        idade: idade,
        endereco: endereco,
        criadoEm: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_usuario!.id)
          .set(_usuario!.toMap());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao cadastrar: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _usuario = null;
    notifyListeners();
  }
}

class ChamadosProvider extends ChangeNotifier {
  final List<Chamado> _chamados = [];
  bool _isLoading = false;

  List<Chamado> get chamados => _chamados;
  bool get isLoading => _isLoading;

  Future<void> carregarChamados(String usuarioId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chamados')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('criadoEm', descending: true)
          .get();

      _chamados.clear();
      for (var doc in snapshot.docs) {
        _chamados.add(Chamado.fromMap(doc.data()));
      }
    } catch (e) {
      print('Erro ao carregar chamados: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> criarChamado(Chamado chamado) async {
    try {
      await FirebaseFirestore.instance
          .collection('chamados')
          .doc(chamado.id)
          .set(chamado.toMap());

      _chamados.insert(0, chamado);
      notifyListeners();
      return true;
    } catch (e) {
      print('Erro ao criar chamado: $e');
      return false;
    }
  }
}

class DadosAmbientaisProvider extends ChangeNotifier {
  DadosAmbientais? _dadosAtuais;
  bool _isLoading = false;

  DadosAmbientais? get dadosAtuais => _dadosAtuais;
  bool get isLoading => _isLoading;

  Future<void> buscarDadosAmbientais() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(seconds: 1));

      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
      );

      if (response.statusCode == 200) {
        _dadosAtuais = DadosAmbientais(
          temperatura: 22.5 + (DateTime.now().millisecond % 10),
          umidade: 65.0 + (DateTime.now().millisecond % 20),
          qualidadeAr: 85.0 + (DateTime.now().millisecond % 15),
          local: 'São Paulo, SP',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      print('Erro ao buscar dados ambientais: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
