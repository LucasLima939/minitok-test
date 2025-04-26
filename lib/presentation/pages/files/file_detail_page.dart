import 'package:flutter/material.dart';

class FileDetailPage extends StatelessWidget {
  final String fileId;

  const FileDetailPage({super.key, required this.fileId});

  @override
  Widget build(BuildContext context) {
    // For demo purposes, we're creating dummy data based on the ID
    // In a real app, this would come from a repository
    final Map<String, dynamic> fileDetails = {
      'id': fileId,
      'name': 'File_$fileId.pdf',
      'size': '${fileId.length * 1.5} MB',
      'type': fileId.length % 3 == 0
          ? 'pdf'
          : (fileId.length % 2 == 0 ? 'image' : 'document'),
      'uploadDate': '2023-10-${15 + int.parse(fileId)}',
      'downloadUrl': 'https://example.com/files/$fileId',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(fileDetails['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Sharing functionality not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilePreview(fileDetails),
            const SizedBox(height: 24),
            _buildFileInfo(fileDetails),
            const SizedBox(height: 32),
            _buildActionButtons(context, fileDetails),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(Map<String, dynamic> fileDetails) {
    // This is a simple placeholder for file preview
    // In a real app, you would display a thumbnail or preview based on file type
    final String fileType = fileDetails['type'];

    return Center(
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            fileType == 'pdf'
                ? Icons.picture_as_pdf
                : fileType == 'image'
                    ? Icons.image
                    : Icons.insert_drive_file,
            size: 80,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildFileInfo(Map<String, dynamic> fileDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow('Name', fileDetails['name']),
        _buildInfoRow('Size', fileDetails['size']),
        _buildInfoRow('Type', fileDetails['type'].toUpperCase()),
        _buildInfoRow('Uploaded on', fileDetails['uploadDate']),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, Map<String, dynamic> fileDetails) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.download,
          label: 'Download',
          onPressed: () {
            // TODO: Implement download functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download started')),
            );
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.share,
          label: 'Share',
          onPressed: () {
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Sharing functionality not implemented yet')),
            );
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.delete,
          label: 'Delete',
          onPressed: () {
            // TODO: Implement delete functionality
            _showDeleteConfirmation(context);
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(100),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File?'),
        content: const Text(
            'Are you sure you want to delete this file? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement actual delete logic
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to file list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
