import 'package:flutter/material.dart';
import 'package:framehub/views/screens/main_screen.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _onLogin(AuthViewModel authViewModel) async {
    if (_formKey.currentState!.validate()) {
      bool success = await authViewModel.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(user: authViewModel.user!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? "Erro no login"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: ChangeNotifierProvider(
        create: (_) => AuthViewModel(),
        child: Consumer<AuthViewModel>(
          builder: (context, authViewModel, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Exibe a imagem local do logo (substituindo o FlutterLogo)
                    Container(
                      margin: const EdgeInsets.only(bottom: 32.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 300,
                      ),
                    ),
                    // Campo de Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira seu email";
                        }
                        if (!value.contains('@')) {
                          return "Insira um email válido";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Campo de Senha
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: "Senha",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira sua senha";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Botão de Login ou indicador de carregamento
                    authViewModel.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => _onLogin(authViewModel),
                            child: const Text("Entrar"),
                          ),
                    const SizedBox(height: 16),
                    // Opções adicionais: Cadastro e Esqueceu a Senha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text("Cadastrar"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: const Text("Esqueceu a senha?"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}