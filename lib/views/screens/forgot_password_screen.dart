import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _onForgotPassword(AuthViewModel authViewModel) async {
    if (_formKey.currentState!.validate()) {
      bool success = await authViewModel.forgotPassword(
        _emailController.text.trim(),
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email de recuperação enviado!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authViewModel.errorMessage ?? "Erro ao enviar e-mail",
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar Senha")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AuthViewModel>(
          builder: (context, authViewModel, _) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 24),
                  authViewModel.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: () => _onForgotPassword(authViewModel),
                        child: const Text("Enviar e-mail de recuperação"),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
