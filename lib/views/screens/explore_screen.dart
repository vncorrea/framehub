import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/explore_viewmodel.dart';
import '../../models/tag_model.dart';
import '../../widgets/post_card.dart';

/// Mapa local para converter a string do Firestore em IconData
final Map<String, IconData> iconMap = {
  "restaurant": Icons.restaurant,
  "travel": Icons.flight,
  "beach_access": Icons.beach_access,
  "camera_alt": Icons.camera_alt,
  // Adicione aqui outras opções de ícones conforme suas tags
};

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  // Exibe cada tag como um ChoiceChip, com ícone e texto
  Widget _buildTagChip(Tag tag, bool isSelected, void Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        avatar: Icon(iconMap[tag.icon] ?? Icons.help),
        label: Text(tag.name),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExploreViewModel>(
      create: (_) => ExploreViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Explorar"),
          centerTitle: true,
        ),
        body: Consumer<ExploreViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção de Tags
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: viewModel.isLoadingTags
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.tags.length + 1, // +1 para a opção "Todos"
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              bool isSelected = viewModel.selectedTag == null;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ChoiceChip(
                                  avatar: const Icon(Icons.all_inclusive),
                                  label: const Text("Todos"),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    viewModel.updateSelectedTag(null);
                                  },
                                ),
                              );
                            } else {
                              Tag tag = viewModel.tags[index - 1];
                              bool isSelected = viewModel.selectedTag == tag.name;
                              return _buildTagChip(tag, isSelected, () {
                                viewModel.updateSelectedTag(tag.name);
                              });
                            }
                          },
                        ),
                ),
                const Divider(),
                // Seção de Posts usando o componente PostCard
                Expanded(
                  child: viewModel.isLoadingPosts
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.posts.isEmpty
                          ? const Center(child: Text("Nenhum post encontrado."))
                          : ListView.builder(
                              itemCount: viewModel.posts.length,
                              itemBuilder: (context, index) {
                                final post = viewModel.posts[index];
                                return PostCard(post: post);
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}