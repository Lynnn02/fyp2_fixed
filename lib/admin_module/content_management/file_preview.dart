import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FilePreview extends StatelessWidget {
  final File file;
  final VoidCallback onUpload;
  final VoidCallback onCancel;

  const FilePreview({
    Key? key,
    required this.file,
    required this.onUpload,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fileName = path.basename(file.path);
    final fileExtension = path.extension(file.path).replaceAll('.', '').toLowerCase();
    final fileSize = _formatFileSize(file.lengthSync());

    return AlertDialog(
      title: const Text('File Preview'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File icon and details
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getColorForFileType(fileExtension).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getColorForFileType(fileExtension)),
                ),
                child: Center(
                  child: Icon(
                    _getIconForFileType(fileExtension),
                    color: _getColorForFileType(fileExtension),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fileExtension.toUpperCase()} • $fileSize',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Preview content
          _buildPreviewContent(fileExtension),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onUpload,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getColorForFileType(fileExtension),
            foregroundColor: Colors.white,
          ),
          child: const Text('Upload'),
        ),
      ],
    );
  }

  Widget _buildPreviewContent(String fileExtension) {
    switch (fileExtension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            height: 200,
            fit: BoxFit.contain,
          ),
        );
      case 'pdf':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PDF document preview not available. Click Upload to continue.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        );
      case 'doc':
      case 'docx':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.description, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Word document preview not available. Click Upload to continue.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        );
      case 'mp3':
      case 'wav':
      case 'm4a':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.audiotrack, color: Colors.purple[700]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Audio preview not available. Click Upload to continue.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.insert_drive_file, color: Colors.grey[700]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'File preview not available. Click Upload to continue.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Color _getColorForFileType(String fileExtension) {
    switch (fileExtension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green;
      case 'pdf':
        return Colors.orange;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green[700]!;
      case 'ppt':
      case 'pptx':
        return Colors.red;
      case 'mp3':
      case 'wav':
      case 'm4a':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForFileType(String fileExtension) {
    switch (fileExtension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'mp3':
      case 'wav':
      case 'm4a':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }
}
