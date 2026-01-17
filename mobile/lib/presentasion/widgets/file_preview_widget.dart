import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:mime/mime.dart';

class FilePreviewWidget extends StatelessWidget {
  final String filePath;
  final VoidCallback onRemove;
  final int? fileSize;
  final Uint8List? webFileBytes;

  const FilePreviewWidget({
    Key? key,
    required this.filePath,
    required this.onRemove,
    this.fileSize,
    this.webFileBytes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fileName = filePath.split('/').last.split('\\').last;
    final fileExtension = fileName.split('.').last.toLowerCase();
    final mimeType = lookupMimeType(fileName);
    final isImage = mimeType?.startsWith('image/') ?? false;
    final isPdf = fileExtension == 'pdf';

    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Preview thumbnail
          _buildPreviewThumbnail(isImage, isPdf, fileExtension),
          
          // File info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(fileExtension).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          fileExtension.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getTypeColor(fileExtension),
                          ),
                        ),
                      ),
                      if (fileSize != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatFileSize(fileSize!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Berhasil di-upload',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Remove button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: onRemove,
            tooltip: 'Hapus file',
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewThumbnail(bool isImage, bool isPdf, String extension) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: isImage
            ? _buildImagePreview()
            : _buildFileIcon(isPdf, extension),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (kIsWeb && webFileBytes != null) {
      return Image.memory(
        webFileBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFileIcon(false, ''),
      );
    } else if (!kIsWeb) {
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFileIcon(false, ''),
      );
    }
    return _buildFileIcon(false, '');
  }

  Widget _buildFileIcon(bool isPdf, String extension) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
            size: 40,
            color: _getTypeColor(extension),
          ),
          const SizedBox(height: 4),
          Text(
            extension.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getTypeColor(extension),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
