import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/constants/app_strings.dart';
import '../../core/services/pdf_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../data/models/material_model.dart';
import '../../data/models/finishing_model.dart';
import '../providers/order_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/price_calculator_widget.dart';
import '../widgets/file_preview_widget.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmittingOrder = false;

  List<String> getSizesForProduct() {
    final name = widget.product.name.toLowerCase();
    // Logika untuk Stiker Vinyl dan UV Printing
    if (name.contains('stiker vinyl') || name.contains('uv printing')) {
      return ['A3', 'A4', 'A5', 'Custom'];
    }
    // Logika untuk Banner  (Hanya Custom)
    else if (name.contains('banner')) {
      return ['Custom'];
    }
    // Logika untuk Kartu Nama (Hanya Custom)
    else if (name.contains('kartu nama')) {
      return ['Custom'];
    }
    // Default untuk produk lain
    else {
      return ['Custom'];
    }
  }

  final List<String> finishings = [
    'Glossy',
    'Doff',
    'Laminating',
    'Tanpa Finishing'
  ];

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.description,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),

                        SizedBox(height: 24),

                        Text(
                          AppStrings.specification,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 16),

                        _buildSizeDropdown(orderProvider),
                        SizedBox(height: 16),

                        if (orderProvider.specification.size == 'Custom')
                          _buildCustomSizeInput(orderProvider),

                        _buildMaterialDropdown(orderProvider),
                        SizedBox(height: 16),

                        _buildFinishingDropdown(orderProvider),
                        SizedBox(height: 16),

                        _buildQuantityInput(orderProvider),
                        SizedBox(height: 16),

                        _buildNotesInput(orderProvider),
                        SizedBox(height: 24),

                        // Price Calculator Widget dengan breakdown detail
                        PriceCalculatorWidget(),
                        SizedBox(height: 24),

                        _buildUploadSection(orderProvider),
                        SizedBox(height: 24),

                        _buildDeliverySection(orderProvider),
                        SizedBox(height: 24),

                        _buildSendButton(orderProvider),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductImage() {
    // Cek apakah gambar dari internet atau lokal (assets)
    bool isNetworkImage = widget.product.imageUrl.startsWith('http');

    return isNetworkImage
        ? Image.network(
            widget.product.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: Icon(Icons.print, size: 80, color: Colors.grey),
              );
            },
          )
        : Image.asset(
            widget.product.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: Icon(Icons.print, size: 80, color: Colors.grey),
              );
            },
          );
  }

  Widget _buildSizeDropdown(OrderProvider provider) {
    final sizes = getSizesForProduct();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.chooseSize,
          style: AppTheme.headingSmall.copyWith(fontSize: 16),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: provider.specification.size,
          decoration: AppTheme.inputDecoration(
            labelText: 'Ukuran',
            prefixIcon: Icons.aspect_ratio,
          ),
          hint: Text('Pilih ukuran'),
          items: sizes.map((size) {
            return DropdownMenuItem(value: size, child: Text(size));
          }).toList(),
          onChanged: (value) {
            if (value != null) provider.setSize(value);
          },
          validator: (value) =>
              value == null ? AppStrings.errorEmptyField : null,
        ),
      ],
    );
  }

  Widget _buildCustomSizeInput(OrderProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _widthController,
                decoration: AppTheme.inputDecoration(
                  labelText: AppStrings.width,
                  hintText: 'Lebar dalam cm',
                  prefixIcon: Icons.straighten,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final width = double.tryParse(value);
                  provider.setCustomSize(
                      width, provider.specification.customHeight);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (double.tryParse(value) == null)
                    return 'Angka tidak valid';
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _heightController,
                decoration: AppTheme.inputDecoration(
                  labelText: AppStrings.height,
                  hintText: 'Tinggi dalam cm',
                  prefixIcon: Icons.height,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final height = double.tryParse(value);
                  provider.setCustomSize(
                      provider.specification.customWidth, height);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (double.tryParse(value) == null)
                    return 'Angka tidak valid';
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMaterialDropdown(OrderProvider provider) {
    final materials = mat.Material.getDummyMaterials();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.chooseMaterial,
          style: AppTheme.headingSmall.copyWith(fontSize: 16),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: provider.specification.materialId,
          decoration: AppTheme.inputDecoration(
            labelText: 'Bahan',
            prefixIcon: Icons.texture,
          ),
          isExpanded: true, // Fix overflow
          hint: Text('Pilih bahan'),
          items: materials
              .map((material) {
                // Filter materials by product ID first (safety check)
                if (material.productId != widget.product.id) {
                  return null;
                }

                // Calculate dynamic price based on product base price
                int estimatedPrice =
                    (widget.product.basePrice * material.priceMultiplier)
                        .round();

                // Determine unit suffix
                String unit = '/pcs';
                final pName = widget.product.name.toLowerCase();
                if (pName.contains('banner'))
                  unit = '/m²';
                else if (pName.contains('stiker'))
                  unit = '/lbr A3';
                else if (pName.contains('kartu')) unit = '/box';

                return DropdownMenuItem(
                  value: material.id,
                  child: Text(
                    '${material.name} (Rp ${estimatedPrice}$unit)',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 14),
                  ),
                );
              })
              .whereType<DropdownMenuItem<int>>()
              .toList(), // Filter out nulls
          onChanged: (value) {
            if (value != null) provider.setMaterial(value);
          },
          validator: (value) =>
              value == null ? AppStrings.errorEmptyField : null,
        ),
      ],
    );
  }

  Widget _buildFinishingDropdown(OrderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.chooseFinishing,
          style: AppTheme.headingSmall.copyWith(fontSize: 16),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: provider.specification.finishing,
          decoration: AppTheme.inputDecoration(
            labelText: 'Finishing',
            prefixIcon: Icons.auto_awesome,
          ),
          isExpanded: true,
          hint: Text('Pilih finishing'),
          items: Finishing.getDummyFinishings()
              .where((f) => f.productId == widget.product.id)
              .map((finishing) {
            String priceText = '';
            if (finishing.additionalPrice > 0) {
              priceText = ' (+Rp ${finishing.additionalPrice.round()})';
            }

            return DropdownMenuItem(
              value: finishing.name,
              child: Text(
                '${finishing.name}$priceText',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) provider.setFinishing(value);
          },
          validator: (value) =>
              value == null ? AppStrings.errorEmptyField : null,
        ),
      ],
    );
  }

  Widget _buildQuantityInput(OrderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.quantity,
          style: AppTheme.headingSmall.copyWith(fontSize: 16),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _quantityController,
          decoration: AppTheme.inputDecoration(
            labelText: 'Jumlah (pcs)',
            hintText: 'Masukkan jumlah',
            prefixIcon: Icons.format_list_numbered,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final qty = int.tryParse(value) ?? 1;
            provider.setQuantity(qty);
          },
          validator: (value) {
            if (value == null || value.isEmpty)
              return AppStrings.errorEmptyField;
            final qty = int.tryParse(value);
            if (qty == null || qty < 1) return AppStrings.errorMinQuantity;
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesInput(OrderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.notes,
          style: AppTheme.headingSmall.copyWith(fontSize: 16),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          decoration: AppTheme.inputDecoration(
            labelText: 'Catatan',
            hintText: AppStrings.notesHint,
            prefixIcon: Icons.note,
          ),
          maxLines: 3,
          onChanged: (value) => provider.setNotes(value),
        ),
      ],
    );
  }

  Widget _buildUploadSection(OrderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.uploadDesign,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${provider.specification.fileMetadataList.length}/3 file',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),

        SizedBox(height: 8),

        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Format: JPG, PNG, PDF | Max: 5 MB per file',
                  style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Preview files with FilePreviewWidget
        if (provider.specification.fileMetadataList.isNotEmpty) ...[
          ...provider.specification.fileMetadataList.asMap().entries.map(
                (entry) => FilePreviewWidget(
                  filePath: entry.value.path,
                  fileSize: entry.value.size,
                  webFileBytes: entry.value.webBytes,
                  onRemove: () => provider.removeFile(entry.key),
                ),
              ),
          SizedBox(height: 12),
        ],

        // Upload buttons (hide if 3 files)
        if (provider.specification.fileMetadataList.length < 3) ...[
          Column(
            children: [
              // File picker button (support PDF + images)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _pickFile(provider),
                  icon: Icon(Icons.attach_file),
                  label: Text('Pilih File (JPG, PNG, PDF)'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(provider, ImageSource.camera),
                      icon: Icon(Icons.camera_alt),
                      label: Text('Kamera'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _pickImage(provider, ImageSource.gallery),
                      icon: Icon(Icons.photo_library),
                      label: Text('Galeri'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ] else ...[
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Maksimal 3 file telah tercapai',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDeliverySection(OrderProvider provider) {
    return const SizedBox.shrink();
  }

  void _selectDeliveryDate(OrderProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 3)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 60)),
      helpText: 'Pilih Tanggal Selesai',
    );

    if (picked != null) {
      provider.setDeliveryDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildSendButton(OrderProvider provider) {
    return CustomButton(
      text: _isSubmittingOrder ? 'Memproses...' : AppStrings.sendToAdmin,
      onPressed: () {
        if (!_isSubmittingOrder) {
          _handleSendOrder(provider);
        }
      },
      backgroundColor: _isSubmittingOrder ? Colors.grey : Colors.green,
    );
  }

  // Pick file using file_picker (supports PDF + images)
  Future<void> _pickFile(OrderProvider provider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
        withData: kIsWeb, // Load bytes for web
      );

      if (result != null) {
        final file = result.files.first;
        final filePath = kIsWeb ? file.name : file.path!;

        // Add file with validation
        final error = await provider.addFile(
          filePath,
          webBytes: kIsWeb ? file.bytes : null,
        );

        if (error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File berhasil ditambahkan'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage(OrderProvider provider, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        // Read bytes for web
        final bytes = kIsWeb ? await image.readAsBytes() : null;

        // Add with validation
        final error = await provider.addFile(
          image.path,
          webBytes: bytes,
        );

        if (error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.successFileUploaded),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.errorUploadFile),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSendOrder(OrderProvider provider) async {
    // Langsung proses order tanpa perlu login
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.errorIncompleteForm)),
      );
      return;
    }

    if (provider.specification.filePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minimal upload 1 file design')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildOrderConfirmationDialog(provider),
    );

    if (confirmed != true) return;

    // Set loading state
    setState(() {
      _isSubmittingOrder = true;
    });

    try {
      // 1. SAVE TO DATABASE FIRST
      final success = await provider.createOrder(
        productId: widget.product.id,
        materialId: provider.specification.materialId!,
      );

      if (!success) {
        if (mounted) {
          setState(() {
            _isSubmittingOrder = false;
          });

          // Show detailed error message from provider
          final errorMsg = provider.orderErrorMessage ??
              'Gagal menyimpan pesanan. Silakan coba lagi.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Lihat Log',
                textColor: Colors.white,
                onPressed: () {
                  // User can check console for detailed logs
                  print('Check console for detailed error logs');
                },
              ),
            ),
          );
        }
        return;
      }

      // 2. SEND WHATSAPP MESSAGE (optional)
      final message = provider.generateWhatsAppMessage();
      final encodedMessage = Uri.encodeComponent(message);
      final phoneNumber = '6285664202185'; // Nomor WA admin
      final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';

      // 3. SHOW SUCCESS DIALOG
      if (mounted) {
        setState(() {
          _isSubmittingOrder = false;
        });

        final goToWhatsApp = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: Icon(Icons.check_circle, color: Colors.green, size: 64),
            title: const Text(
              'Pesanan Berhasil!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pesanan Anda telah tersimpan dengan nomor:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Lanjutkan ke WhatsApp untuk konfirmasi dengan admin?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Nanti Saja'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.chat, size: 18),
                label: const Text('Buka WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );

        // Launch WhatsApp if user wants
        if (goToWhatsApp == true) {
          _launchWhatsApp(whatsappUrl);
        }

        // 4. NAVIGATE TO ORDER HISTORY
        if (mounted) {
          // Reset form
          provider.reset();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('✅ Pesanan berhasil dibuat! Cek di Riwayat Pesanan'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate back to home
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmittingOrder = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildOrderConfirmationDialog(OrderProvider provider) {
    final materials = PrintMaterial.getDummyMaterials();
    final selectedMaterial = materials.firstWhere(
      (m) => m.id == provider.specification.materialId,
      orElse: () => materials.first,
    );

    return AlertDialog(
      title: const Text('Konfirmasi Pesanan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk: ${widget.product.name}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Material: ${selectedMaterial.name}'),
            Text('Kuantitas: ${provider.specification.quantity} pcs'),
            const Divider(),
            Text('Total: Rp ${_formatPrice(provider.totalPrice)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Export Invoice:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportPdf(provider, selectedMaterial),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportTxt(provider, selectedMaterial),
                    icon: const Icon(Icons.text_snippet, size: 18),
                    label: const Text('TXT', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Kirim via WhatsApp'),
        ),
      ],
    );
  }

  Future<void> _exportPdf(
      OrderProvider provider, PrintMaterial material) async {
    try {
      await PdfService.generateOrderPdf(
        productName: widget.product.name,
        materialName: material.name,
        quantity: provider.specification.quantity.toDouble(),
        basePrice: widget.product.basePrice.toDouble(),
        materialPrice: material.pricePerSqm.toDouble(),
        totalPrice: provider.totalPrice.toDouble(),
        customerName: 'Customer', // Bisa diganti dengan input form
        customerPhone: '0812XXXXXXXX', // Bisa diganti dengan input form
        notes: provider.specification.notes,
        filePaths: provider.specification.filePaths,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF berhasil dibuat!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat PDF: $e')),
      );
    }
  }

  Future<void> _exportTxt(
      OrderProvider provider, PrintMaterial material) async {
    try {
      await PdfService.generateOrderTxt(
        productName: widget.product.name,
        materialName: material.name,
        quantity: provider.specification.quantity.toDouble(),
        basePrice: widget.product.basePrice.toDouble(),
        materialPrice: material.pricePerSqm.toDouble(),
        totalPrice: provider.totalPrice.toDouble(),
        customerName: 'Customer', // Bisa diganti dengan input form
        customerPhone: '0812XXXXXXXX', // Bisa diganti dengan input form
        notes: provider.specification.notes,
        filePaths: provider.specification.filePaths,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File TXT berhasil dibuat!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat TXT: $e')),
      );
    }
  }

  Future<void> _launchWhatsApp(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak bisa membuka WhatsApp')),
      );
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
