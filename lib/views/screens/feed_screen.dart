import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/feed_viewmodel.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';

/// Função auxiliar para formatar o timestamp de forma agradável
String formatTimestamp(DateTime timestamp) {
  return DateFormat("dd MMM yyyy, HH:mm").format(timestamp);
}

/// Função auxiliar para buscar os dados do usuário a partir do userId
Future<AppUser> getUserData(String userId) async {
  DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();
  if (doc.exists && doc.data() != null) {
    return AppUser.fromMap(doc.data()!, doc.id);
  } else {
    // Retorna dados padrão caso não encontre
    return AppUser(
      id: userId,
      name: "Desconhecido",
      email: "",
      phone: "",
      profilePictureUrl: null,
    );
  }
}

/// Widget para exibir o card do post com header (foto, nome, timestamp), imagem e legenda
Widget buildPostCard(Post post) {
  return FutureBuilder<AppUser>(
    future: getUserData(post.userId),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final user = snapshot.data!;
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: exibe foto de perfil, nome do usuário e timestamp formatado
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: user.profilePictureUrl != null
                        ? NetworkImage(user.profilePictureUrl!)
                        : null,
                    child: user.profilePictureUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    formatTimestamp(post.timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Imagem do post
            Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              height: 300,
            ),
            // Legenda
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                post.caption,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FeedViewModel>(
      create: (_) => FeedViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("FrameHub"),
          centerTitle: true,
        ),
        body: Consumer<FeedViewModel>(
          builder: (context, feedViewModel, _) {
            if (feedViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (feedViewModel.errorMessage != null) {
              return Center(child: Text("Erro: ${feedViewModel.errorMessage}"));
            }
            if (feedViewModel.posts.isEmpty) {
              return const Center(child: Text("Nenhum post encontrado."));
            }
            return ListView.builder(
              itemCount: feedViewModel.posts.length,
              itemBuilder: (context, index) {
                final post = feedViewModel.posts[index];
                return buildPostCard(post);
              },
            );
          },
        ),
      ),
    );
  }
}