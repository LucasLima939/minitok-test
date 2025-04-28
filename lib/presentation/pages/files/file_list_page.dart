import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../routes/app_router.dart';
import '../../widgets/file_card.dart';
import '../../../domain/repositories/file_repository.dart';
import '../../../domain/entities/file_item.dart';
import '../../../infra/adapters/firebase_storage_adapter.dart';
import '../../../infra/adapters/firebase_auth_adapter.dart';
import '../../../data/repositories/file_repository_impl.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({super.key});

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  late final FileRepository _fileRepository;
  late final FirebaseAuthAdapter _authAdapter;
  List<FileItem>? _files;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize repository with adapters
    final storageAdapter = FirebaseStorageAdapterImpl();
    _authAdapter = FirebaseAuthAdapterImpl();
    _fileRepository = FileRepositoryImpl(storageAdapter, _authAdapter);

    // Load files
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _fileRepository.getFiles();

    setState(() {
      _isLoading = false;
      result.fold(
        (failure) => _errorMessage = failure.message,
        (files) => _files = files,
      );
    });
  }

  // Helper to format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Helper to format date
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Helper to determine file type from content type
  String _getFileType(String contentType) {
    if (contentType.startsWith('image/')) return 'image';
    if (contentType.startsWith('application/pdf')) return 'pdf';
    if (contentType.contains('spreadsheet') || contentType.contains('excel'))
      return 'spreadsheet';
    if (contentType.contains('presentation') ||
        contentType.contains('powerpoint')) return 'presentation';
    if (contentType.contains('document') || contentType.contains('word'))
      return 'document';
    return 'file';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Files'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement file upload functionality
          _showUploadOptions(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFiles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_files == null || _files!.isEmpty) {
      return const Center(
        child: Text('No files uploaded yet'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFiles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _files!.length,
        itemBuilder: (context, index) {
          final file = _files![index];
          return FileCard(
            fileName: file.name,
            fileSize: _formatFileSize(file.size),
            fileType: _getFileType(file.contentType),
            uploadDate: _formatDate(file.createdAt),
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRouter.fileDetail,
                arguments: file.id,
              );
            },
          );
        },
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

  Future<void> _logout(BuildContext context) async {
    try {
      await _authAdapter.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }
}
