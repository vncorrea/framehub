import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  // Função para formatar o timestamp
  String _formatTimestamp(DateTime timestamp) {
    return DateFormat("dd MMM yyyy, HH:mm").format(timestamp);
  }

  // Função para buscar os dados do usuário baseado no userId do post
  Future<AppUser> _getUserData(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromMap(doc.data()!, doc.id);
    } else {
      // Retorna dados padrão se o usuário não for encontrado
      return AppUser(
        id: userId,
        name: "Desconhecido",
        email: "",
        phone: "",
        profilePictureUrl: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser>(
      future: _getUserData(post.userId),
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
              // Header: foto de perfil, nome do usuário e timestamp formatado
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
                      _formatTimestamp(post.timestamp),
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
              // Legenda (caption)
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
}