// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            const SizedBox(height: 8),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      user.profilePictureUrl != null
                          ? NetworkImage(user.profilePictureUrl!)
                          : null,
                  child:
                      user.profilePictureUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProfileEditScreen(userId: user.id),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '@${user.username}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(user.phone, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(userId: userId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Perfil"),
          actions: [
            Consumer<ProfileViewModel>(
              builder: (context, viewModel, _) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileEditScreen(userId: userId),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoadingProfile || viewModel.isLoadingPosts) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorProfile != null) {
              return Center(
                child: Text("Erro no perfil: ${viewModel.errorProfile}"),
              );
            }

            AppUser user = viewModel.userProfile!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(context, user),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Meus Posts",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
