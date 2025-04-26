import 'package:flutter/material.dart';
import '../../routes/app_router.dart';
import '../../widgets/file_card.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({super.key});

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  // Dummy data for demonstration
  final List<Map<String, dynamic>> _files = [
    {
      'id': '1',
      'name': 'Document.pdf',
      'size': '2.5 MB',
      'type': 'pdf',
      'uploadDate': '2023-10-15',
    },
    {
      'id': '2',
      'name': 'Image.jpg',
      'size': '1.8 MB',
      'type': 'image',
      'uploadDate': '2023-10-16',
    },
    {
      'id': '3',
      'name': 'Presentation.pptx',
      'size': '5.3 MB',
      'type': 'document',
      'uploadDate': '2023-10-17',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Files'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout functionality
              Navigator.of(context).pushReplacementNamed(AppRouter.login);
            },
          ),
        ],
      ),
      body: _files.isEmpty
          ? const Center(
              child: Text('No files uploaded yet'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                return FileCard(
                  fileName: file['name'],
                  fileSize: file['size'],
                  fileType: file['type'],
                  uploadDate: file['uploadDate'],
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRouter.fileDetail,
                      arguments: file['id'],
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement file upload functionality
          _showUploadOptions(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Upload Image'),
                onTap: () {
                  // TODO: Implement image upload
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Upload Document'),
                onTap: () {
                  // TODO: Implement document upload
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
