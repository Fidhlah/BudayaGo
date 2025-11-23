import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../providers/profile_provider.dart';
import '../../services/karya_service.dart';
import '../../config/supabase_config.dart';
import '../../widgets/custom_app_bar.dart';

class UploadKaryaScreen extends StatefulWidget {
  const UploadKaryaScreen({Key? key}) : super(key: key);

  @override
  State<UploadKaryaScreen> createState() => _UploadKaryaScreenState();
}

class _UploadKaryaScreenState extends State<UploadKaryaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedTag;
  String? _selectedUmkm;
  File? _imageFile;
  bool _isUploading = false;

  final List<String> _tags = [
    'Batik',
    'Furniture',
    'Keramik',
    'Anyaman',
    'Tenun',
    'Wayang',
  ];

  final List<String> _umkmCategories = [
    'Batik Nusantara',
    'Kerajinan Kayu',
    'Gerabah Tradisional',
    'Anyaman Bambu',
    'Tenun Ikat',
    'Wayang Kulit',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitKarya() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih tag untuk karya'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedUmkm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih kategori UMKM'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User tidak terautentikasi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload image to Supabase Storage
      String? imageUrl;
      if (_imageFile != null) {
        try {
          debugPrint('📤 Uploading image to Supabase Storage...');
          
          // Create unique filename: userId/timestamp_originalname.jpg
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final extension = _imageFile!.path.split('.').last;
          final fileName = '$userId/${timestamp}_karya.$extension';

          debugPrint('   File: $fileName');

          // Upload to storage bucket 'karya-images'
          await SupabaseConfig.client.storage
              .from('karya-images')
              .upload(fileName, _imageFile!);

          // Get public URL
          imageUrl = SupabaseConfig.client.storage
              .from('karya-images')
              .getPublicUrl(fileName);

          debugPrint('✅ Image uploaded: $imageUrl');
        } catch (uploadError) {
          debugPrint('❌ Error uploading image: $uploadError');
          // Continue without image if upload fails
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ Gambar gagal diupload: $uploadError'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      }

      // Map tag to color and icon
      final tagColorMap = {
        'Batik': {
          'color': AppColors.blueLight.value,
          'icon': Icons.auto_awesome.codePoint,
        },
        'Furniture': {
          'color': AppColors.brownLight.value,
          'icon': Icons.table_restaurant.codePoint,
        },
        'Keramik': {
          'color': AppColors.orange300.value,
          'icon': Icons.local_florist.codePoint,
        },
        'Anyaman': {
          'color': AppColors.greenLight.value,
          'icon': Icons.shopping_bag.codePoint,
        },
        'Tenun': {
          'color': AppColors.purpleLight.value,
          'icon': Icons.texture.codePoint,
        },
        'Wayang': {
          'color': AppColors.redLight.value,
          'icon': Icons.person.codePoint,
        },
      };

      final tagData =
          tagColorMap[_selectedTag] ??
          {'color': AppColors.batik700.value, 'icon': Icons.star.codePoint};

      // Upload to database
      final result = await KaryaService.uploadKarya(
        creatorId: userId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        tag: _selectedTag!,
        umkmCategory: _selectedUmkm!,
        imageUrl: imageUrl,
        color: tagData['color'] as int,
        iconCodePoint: tagData['icon'] as int,
      );

      if (result != null && mounted) {
        // Update profile provider
        final profileProvider = Provider.of<ProfileProvider>(
          context,
          listen: false,
        );
        await profileProvider.addUploadedKarya(result['id']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Karya berhasil diupload!'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pop(context, true); // Return true to indicate success
      } else {
        throw Exception('Failed to upload karya');
      }
    } catch (e) {
      debugPrint('❌ Error uploading karya: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupload karya: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orange50,
      appBar: CustomGradientAppBar(title: 'Upload Karya'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.paddingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(
                      color: AppColors.grey300,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child:
                      _imageFile == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: AppDimensions.iconXL,
                                color: AppColors.grey400,
                              ),
                              SizedBox(height: AppDimensions.spaceS),
                              Text(
                                'Tap untuk upload foto',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                          : Center(
                            child: Text(
                              '✓ Foto dipilih',
                              style: AppTextStyles.h6.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceM),

              // Nama Karya
              Text(
                'Nama Karya',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.spaceXS),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Batik Kawung Premium',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama karya tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.spaceM),

              // Deskripsi
              Text(
                'Deskripsi',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.spaceXS),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ceritakan tentang karya ini...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceM),

              // Tag
              Text(
                'Tag',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.spaceXS),
              Wrap(
                spacing: AppDimensions.spaceS,
                runSpacing: AppDimensions.spaceS,
                children:
                    _tags.map((tag) {
                      final isSelected = _selectedTag == tag;
                      return ChoiceChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTag = selected ? tag : null;
                          });
                        },
                        selectedColor: AppColors.batik300,
                        backgroundColor: AppColors.grey100,
                        labelStyle: AppTextStyles.bodyMedium.copyWith(
                          color:
                              isSelected
                                  ? AppColors.background
                                  : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
              ),
              SizedBox(height: AppDimensions.spaceM),

              // Kategori UMKM
              Text(
                'Kategori UMKM',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.spaceXS),
              DropdownButtonFormField<String>(
                value: _selectedUmkm,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                hint: Text('Pilih kategori UMKM'),
                items:
                    _umkmCategories.map((umkm) {
                      return DropdownMenuItem(value: umkm, child: Text(umkm));
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUmkm = value;
                  });
                },
              ),
              SizedBox(height: AppDimensions.spaceXL),

              // Submit Button
              ElevatedButton(
                onPressed: _submitKarya,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.batik700,
                  foregroundColor: AppColors.background,
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
                child: Text('Upload Karya', style: AppTextStyles.button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
