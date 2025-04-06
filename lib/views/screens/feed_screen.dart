import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/feed_viewmodel.dart';
import '../../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FeedViewModel>(
      create: (_) => FeedViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text("FrameHub"), centerTitle: true),
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
                return PostCard(post: post);
              },
            );
          },
        ),
      ),
    );
  }
}
