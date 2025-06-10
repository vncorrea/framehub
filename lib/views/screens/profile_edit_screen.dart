import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../viewmodels/profile_edit_viewmodel.dart';

class ProfileEditScreen extends StatefulWidget {
  final String userId;

  const ProfileEditScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Controllers serão inicializados quando o perfil for carregado
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile(ProfileEditViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      bool success = await viewModel.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (_selectedImage != null) {
        success = await viewModel.updateProfilePicture(_selectedImage!);
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado com sucesso!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(viewModel.errorMessage ?? 'Erro ao atualizar perfil')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileEditViewModel>(
      create: (_) => ProfileEditViewModel(userId: widget.userId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Perfil'),
          actions: [
            Consumer<ProfileEditViewModel>(
              builder: (context, viewModel, _) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: viewModel.isLoading ? null : () => _saveProfile(viewModel),
                );
              },
            ),
          ],
        ),
        body: Consumer<ProfileEditViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading && viewModel.userProfile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.userProfile != null) {
              if (_nameController.text.isEmpty) {
                _nameController.text = viewModel.userProfile!.name;
              }
              if (_phoneController.text.isEmpty) {
                _phoneController.text = viewModel.userProfile!.phone;
              }
              if (_usernameController.text.isEmpty) {
                _usernameController.text = viewModel.userProfile!.username ?? '';
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (viewModel.userProfile?.profilePictureUrl != null
                                    ? NetworkImage(viewModel.userProfile!.profilePictureUrl!)
                                    : null) as ImageProvider?,
                            child: (_selectedImage == null &&
                                    viewModel.userProfile?.profilePictureUrl == null)
                                ? const Icon(Icons.person, size: 60)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                      onChanged: (value) => viewModel.username = value.trim(),
                    ),
                    if (viewModel.errorMessage != null &&
                        viewModel.errorMessage!.contains('usuário já está em uso'))
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira seu telefone';
                        }
                        return null;
                      },
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