import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../providers/profile_provider.dart';

class UploadKaryaScreen extends StatefulWidget {
  const UploadKaryaScreen({Key? key}) : super(key: key);

  @override
  State<UploadKaryaScreen> createState() => _UploadKaryaScreenState();
}

class _UploadKaryaScreenState extends State<UploadKaryaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedTag;
  String? _selectedUmkm;
  String? _imagePath;

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
    // TODO: Implement image picker
    setState(() {
      _imagePath = 'mock_image_path.jpg';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fitur upload foto akan segera tersedia'),
        backgroundColor: AppColors.info,
      ),
    );
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

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    // TODO: Upload to Supabase
    await Future.delayed(const Duration(seconds: 1));

    // Mock karya ID
    final karyaId = 'karya_${DateTime.now().millisecondsSinceEpoch}';
    profileProvider.addUploadedKarya(karyaId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Karya berhasil diupload!'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Karya')),
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
                      _imagePath == null
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
