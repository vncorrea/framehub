import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/feed_viewmodel.dart';
import '../../models/post_model.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  // Widget para exibir cada post
  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Exibe a imagem do post
          Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            height: 300,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              post.caption,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              post.timestamp.toLocal().toString(),
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

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
                return _buildPostCard(post);
              },
            );
          },
        ),
      ),
    );
  }
}