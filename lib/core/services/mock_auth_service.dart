class MockAuthService {

  // Login e senha que vamos aceitar como válidos para teste
  final String _validEmail = 'teste@teste.com';
  final String _validPassword = '123';

  // Um token JWT (JSON Web Token) falso, mas com a aparência de um real.
  final String _fakeJwtToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IlVzdS_DoXJpbyBkZSBUZXN0ZSIsImlhdCI6MTUxNjIzOTAyMn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email == _validEmail && password == _validPassword) {
      print('Mock Login: Sucesso! Retornando token falso.');
      return _fakeJwtToken;
    } else {
      print('Mock Login: Falhou! Credenciais inválidas.');
      throw Exception('Email ou senha inválidos');
    }
  }
}