import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/post_detail_viewmodel.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailViewModel>(
      create: (_) => PostDetailViewModel(postId: widget.postId),
      child: Consumer<PostDetailViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (viewModel.errorMessage != null) {
            return Scaffold(
              body: Center(child: Text("Erro: ${viewModel.errorMessage}")),
            );
          }
          final post = viewModel.post!;
          if (!viewModel.isEditing) {
            _captionController.text = post.caption;
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text("Detalhes do Post"),
              actions: [
                if (viewModel.isCurrentUserPost)
                  IconButton(
                    icon: Icon(viewModel.isEditing ? Icons.close : Icons.edit),
                    onPressed: () {
                      if (viewModel.isEditing) {
                        viewModel.cancelEditing();
                      } else {
                        viewModel.startEditing();
                      }
                    },
                  ),
                if (viewModel.isEditing)
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () async {
                      viewModel.updateCaption(_captionController.text);
                      await viewModel.saveEdit();
                      // Garante que o modo de edição será fechado após salvar
                      if (mounted) setState(() {});
                    },
                  ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: viewModel.isEditing
                        ? TextField(
                            controller: _captionController,
                            decoration: const InputDecoration(
                              hintText: "Digite a nova descrição",
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          )
                        : Text(
                            post.caption,
                            style: const TextStyle(fontSize: 18.0),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      DateFormat("dd MMM yyyy, HH:mm").format(post.timestamp),
                      style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}