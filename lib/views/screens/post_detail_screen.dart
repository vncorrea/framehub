import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/post_detail_viewmodel.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat("dd MMM yyyy, HH:mm").format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailViewModel>(
      create: (_) => PostDetailViewModel(postId: postId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Detalhes do Post"),
        ),
        body: Consumer<PostDetailViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.errorMessage != null) {
              return Center(child: Text("Erro: ${viewModel.errorMessage}"));
            }
            final post = viewModel.post!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Exibe a imagem do post em tamanho maior
                  Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  // Exibe a caption com um padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      post.caption,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Exibe o timestamp formatado
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _formatTimestamp(post.timestamp),
                      style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}