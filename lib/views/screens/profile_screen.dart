// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  Widget _buildProfileHeader(AppUser user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user.profilePictureUrl != null
              ? NetworkImage(user.profilePictureUrl!)
              : null,
          child: user.profilePictureUrl == null
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          user.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.phone,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(userId: userId),
      child: Scaffold(
        appBar: AppBar(title: const Text("Perfil")),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoadingProfile || viewModel.isLoadingPosts) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorProfile != null) {
              return Center(child: Text("Erro no perfil: ${viewModel.errorProfile}"));
            }

            AppUser user = viewModel.userProfile!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(user),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Meus Posts",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  viewModel.userPosts.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("Nenhum post ainda."),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewModel.userPosts.length,
                          itemBuilder: (context, index) {
                            Post post = viewModel.userPosts[index];
                            return PostCard(post: post);
                          },
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
