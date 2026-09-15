import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String? currentAvatarUrl;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    this.currentAvatarUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final user = supabase.auth.currentUser;

    if (user == null) return;
    if (name.isEmpty) {
      _showSnackBar('O nome não pode ficar em branco');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? avatarUrl = widget.currentAvatarUrl;

      // 1. Fazer upload da imagem via Bytes (compatível com Web e Mobile)
      if (_selectedImage != null && _imageBytes != null) {
        final imageExtension = _selectedImage!.name.split('.').last;
        final imagePath = '${user.id}/avatar.$imageExtension';

        await supabase.storage
            .from('avatars')
            .uploadBinary(
              imagePath,
              _imageBytes!,
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'image/png',
              ),
            );

        // Gera a URL pública da imagem com parâmetro para evitar cache estático
        final rawUrl = supabase.storage.from('avatars').getPublicUrl(imagePath);
        avatarUrl = '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      }

      // 2. Atualizar a tabela 'profiles' no Supabase
      await supabase.from('profiles').upsert({
        'id': user.id,
        'name': name,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        _showSnackBar('Perfil atualizado com sucesso!', isError: false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar('Erro ao salvar perfil: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFFF2D55) : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (_imageBytes != null) {
      imageProvider = MemoryImage(_imageBytes!);
    } else if (widget.currentAvatarUrl != null) {
      imageProvider = NetworkImage(widget.currentAvatarUrl!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121217),
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF2D55),
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check, color: Color(0xFFFF2D55)),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF1C1C22),
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF2D55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nome de exibição',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade800),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFF2D55)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
