import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _usarToken = false;
  bool _senhaVisivel = false;
  String? _erro;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _senhaCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      if (_usarToken) {
        await _authService.loginComToken(_tokenCtrl.text.trim());
      } else {
        await _authService.loginComCredenciais(
          login: _loginCtrl.text.trim(),
          senha: _senhaCtrl.text,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // Logo / Header
                _buildHeader()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2),

                const SizedBox(height: 48),

                // Toggle Login / Token
                _buildToggle()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Campos
                if (_usarToken) ...[
                  _buildTokenField().animate().fadeIn(duration: 300.ms),
                ] else ...[
                  _buildLoginField().animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 16),
                  _buildSenhaField().animate().fadeIn(delay: 100.ms, duration: 300.ms),
                ],

                if (_erro != null) ...[
                  const SizedBox(height: 16),
                  _buildErro(),
                ],

                const SizedBox(height: 32),

                // Botão entrar
                _buildBotaoEntrar()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 24),

                _buildDica()
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, Color(0xFF4FC3F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Meus Holerites',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Acesse e acompanhe seus contracheques\nde forma automática e organizada',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _usarToken = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_usarToken ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Login e Senha',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_usarToken ? Colors.white : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _usarToken = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _usarToken ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Token de API',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _usarToken ? Colors.white : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginField() {
    return TextFormField(
      controller: _loginCtrl,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Login / CPF / E-mail',
        prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Informe o login' : null,
    );
  }

  Widget _buildSenhaField() {
    return TextFormField(
      controller: _senhaCtrl,
      obscureText: !_senhaVisivel,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            _senhaVisivel ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.textSecondary,
          ),
          onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Informe a senha' : null,
    );
  }

  Widget _buildTokenField() {
    return TextFormField(
      controller: _tokenCtrl,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Token de API',
        prefixIcon: Icon(Icons.key, color: AppTheme.textSecondary),
        hintText: 'Cole seu token aqui',
      ),
      validator: (v) => v == null || v.isEmpty ? 'Informe o token' : null,
    );
  }

  Widget _buildErro() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.negative.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.negative.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.negative, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _erro!,
              style: const TextStyle(color: AppTheme.negative, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoEntrar() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _loading ? null : _entrar,
        child: _loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Entrar'),
      ),
    );
  }

  Widget _buildDica() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Use as mesmas credenciais do site\nfitcard.app.questorpublico.com.br',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
