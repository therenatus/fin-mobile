import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? currentImageUrl;
  final Function(File) onImageSelected;
  final VoidCallback? onImageRemoved;
  final double size;
  final bool isCircle;
  final IconData placeholderIcon;
  final String? label;

  const ImagePickerWidget({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.onImageRemoved,
    this.size = 120,
    this.isCircle = false,
    this.placeholderIcon = Icons.add_photo_alternate_outlined,
    this.label,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedFile;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
        });
        widget.onImageSelected(_selectedFile!);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Камера'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.secondary),
                ),
                title: const Text('Галерея'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_hasImage && widget.onImageRemoved != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                  title: const Text('Удалить'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedFile = null;
                    });
                    widget.onImageRemoved?.call();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasImage => _selectedFile != null || widget.currentImageUrl != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: _showPickerOptions,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: context.surfaceVariantColor,
              borderRadius: BorderRadius.circular(widget.isCircle ? widget.size / 2 : 16),
              border: Border.all(
                color: context.borderColor,
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_selectedFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            _selectedFile!,
            fit: BoxFit.cover,
          ),
          _buildEditOverlay(),
        ],
      );
    }

    if (widget.currentImageUrl != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: widget.currentImageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (context, url, error) => _buildPlaceholder(),
          ),
          _buildEditOverlay(),
        ],
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          widget.placeholderIcon,
          size: widget.size * 0.3,
          color: context.textSecondaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          'Добавить',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEditOverlay() {
    return Positioned(
      right: 8,
      bottom: 8,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

/// Avatar picker with circular shape
class AvatarPickerWidget extends StatelessWidget {
  final String? currentImageUrl;
  final Function(File) onImageSelected;
  final VoidCallback? onImageRemoved;
  final double size;

  const AvatarPickerWidget({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.onImageRemoved,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ImagePickerWidget(
      currentImageUrl: currentImageUrl,
      onImageSelected: onImageSelected,
      onImageRemoved: onImageRemoved,
      size: size,
      isCircle: true,
      placeholderIcon: Icons.person_add_outlined,
    );
  }
}

/// Model image picker with square/rounded shape
class ModelImagePickerWidget extends StatelessWidget {
  final String? currentImageUrl;
  final Function(File) onImageSelected;
  final VoidCallback? onImageRemoved;
  final double size;

  const ModelImagePickerWidget({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.onImageRemoved,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return ImagePickerWidget(
      currentImageUrl: currentImageUrl,
      onImageSelected: onImageSelected,
      onImageRemoved: onImageRemoved,
      size: size,
      isCircle: false,
      placeholderIcon: Icons.checkroom_outlined,
      label: 'Фото модели',
    );
  }
}
