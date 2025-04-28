import 'package:flutter/material.dart';

class FileCard extends StatelessWidget {
  final String iconUrl;
  final String fileName;
  final String fileSize;
  final String fileType;
  final String uploadDate;
  final VoidCallback onTap;

  const FileCard({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.uploadDate,
    required this.onTap,
    required this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildFileIcon(iconUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$fileSize • Uploaded on $uploadDate',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(String iconUrl) {
    IconData iconData;
    Color iconColor;
    String? imageUrl;

    switch (fileType.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
        imageUrl = iconUrl;
        iconData = Icons.image;
        iconColor = Colors.blue;
        break;
      case 'document':
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.lightBlue;
        break;
      case 'spreadsheet':
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart;
        iconColor = Colors.green;
        break;
      case 'presentation':
      case 'ppt':
      case 'pptx':
        iconData = Icons.slideshow;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return Container(
      height: 34,
      width: 34,
      decoration: BoxDecoration(
        color: iconColor.withAlpha(100),
        shape: BoxShape.circle,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl != null
          ? null
          : Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
    );
  }
}
