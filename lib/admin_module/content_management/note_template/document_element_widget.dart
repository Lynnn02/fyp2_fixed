import 'package:flutter/material.dart';
import '../../models/note_content.dart';

class DocumentElementWidget extends StatelessWidget {
  final DocumentElement element;

  const DocumentElementWidget({
    Key? key,
    required this.element,
  }) : super(key: key);

  String _getFileIcon() {
    switch (element.fileType.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'ppt':
      case 'pptx':
        return '📑';
      default:
        return '📁';
    }
  }

  String _formatFileSize() {
    if (element.fileSize == null) return '';
    
    final kb = element.fileSize! / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    } else {
      final mb = kb / 1024;
      return '${mb.toStringAsFixed(1)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // File icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getFileIcon(),
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // File details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  element.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${element.fileType.toUpperCase()} ${_formatFileSize()}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Download button
          IconButton(
            icon: const Icon(Icons.download, color: Colors.orange),
            onPressed: () {
              // Open the document URL
              // In a real app, this would download or open the file
            },
            tooltip: 'Download',
          ),
        ],
      ),
    );
  }
}
