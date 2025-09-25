import 'package:papa_capim/core/services/secure_storage_service.dart';

class AuthService {
  final SecureStorageService _storageService = SecureStorageService();

  // --- Mock Data (Para Testes) ---
  final String _validEmail = 'teste@teste.com';
  final String _validPassword = '123';
  final String _fakeJwtToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IlVzdS_DoXJpbyBkZSBUZXN0ZSIsImlhdCI6MTUxNjIzOTAyMn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email == _validEmail && password == _validPassword) {
      await _storageService.writeToken(_fakeJwtToken);
      print('Mock Login: Sucesso! Token de teste foi salvo.');
    } else {
      print('Mock Login: Falhou! Credenciais inválidas.');
      throw Exception('Email ou senha inválidos');
    }
  }

  // <<< NOVO MÉTODO DE REGISTRO >>>
  Future<void> register(String name, String email, String password) async {
    // Simula a espera da API
    await Future.delayed(const Duration(seconds: 2));

    // Simula uma validação: não permite registrar um email que já "existe"
    if (email == _validEmail) {
      print('Mock Register: Falhou! Email já cadastrado.');
      throw Exception('Este email já está em uso.');
    }

    // Se o email for novo, o registro é um "sucesso".
    // Para simplificar, um registro bem-sucedido já faz o login automaticamente.
    await _storageService.writeToken(_fakeJwtToken);
    print('Mock Register: Sucesso para o usuário $name! Token de teste foi salvo.');
  }


  Future<void> logout() async {
    await _storageService.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storageService.readToken();
    return token != null;
  }
}