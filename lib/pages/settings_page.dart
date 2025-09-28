import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_settings_tile.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../services/auth/login_ou_register.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDeleting = false;

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? '
          'Esta ação é permanente e não pode ser desfeita. '
          'Todos os seus dados, posts e informações serão perdidos.',
        ),
        actions: [
          TextButton(
            onPressed: _isDeleting ? null : () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: themeData().colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: _isDeleting ? null : () => _deleteAccount(context),
            child: _isDeleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Excluir',
                    style: TextStyle(color: Colors.red),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final userLogin = await authService.getCurrentUserLogin();
      
      if (userLogin == null) {
        throw Exception('Não foi possível identificar o usuário');
      }

      
      await apiService.deleteAccount(userLogin);
      
      
      await authService.logout();
      
 
      if (mounted) Navigator.pop(context);
      
  
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginOrRegister()),
          (route) => false,
        );
        
      
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
    
      if (mounted) Navigator.pop(context);
      
     
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir conta: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData().colorScheme.surface,
      appBar: AppBar(
        title: const Text("C O N F I G U R A Ç Õ E S"),
        foregroundColor: themeData().colorScheme.primary,
        backgroundColor: themeData().colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          MySettingsTile(
            title: "Editar Perfil",
            action: IconButton(
              onPressed: () {
                
              },
              icon: Icon(Icons.chevron_right, color: themeData().colorScheme.primary),
            ),
          ),
          const SizedBox(height: 20),
         
          Container(
            margin: const EdgeInsets.only(left: 25, right: 25, top: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              title: Text(
                "Excluir Conta",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Excluir permanentemente sua conta e todos os dados",
                style: TextStyle(
                  color: Colors.red.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              trailing: _isDeleting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.chevron_right,
                      color: Colors.red,
                    ),
              onTap: _isDeleting ? null : () => _showDeleteAccountDialog(context),
            ),
          ),
        ],
      ),
    );
  }
}