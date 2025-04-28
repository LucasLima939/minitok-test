import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minitok_test/domain/entities/file_item.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/utils/file_utils.dart';
import '../../../core/utils/date_formatter.dart';
import '../../cubits/file_details/file_details_cubit.dart';
import '../../cubits/file_details/file_details_state.dart';
import '../../cubits/file_list/file_list_cubit.dart';

class FileDetailPage extends StatelessWidget {
  final FileItem file;

  const FileDetailPage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FileDetailsCubit, FileDetailsState>(
      listener: (context, state) {
        if (state is FileDownloadSuccess) {
          _handleDownloadSuccess(context, state.file);
        } else if (state is FileShareSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File shared successfully')),
          );
        } else if (state is FileDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File deleted successfully')),
          );
          // Refresh the file list and navigate back
          context.read<FileListCubit>().loadFiles();
          Navigator.of(context).pop();
        } else if (state is FileOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.operation} failed: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(file.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                context.read<FileDetailsCubit>().shareFile(file);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilePreview(file),
              const SizedBox(height: 24),
              _buildFileInfo(file),
              const SizedBox(height: 32),
              _buildActionButtons(context, file),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(FileItem file) {
    // This is a simple placeholder for file preview
    // In a real app, you would display a thumbnail or preview based on file type
    final String fileType = FileUtils.getFileType(file.contentType);

    return Center(
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          image: fileType == 'image'
              ? DecorationImage(
                  image: NetworkImage(file.url),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Center(
          child: Icon(
            fileType == 'pdf'
                ? Icons.picture_as_pdf
                : fileType == 'image'
                    ? null
                    : Icons.insert_drive_file,
            size: 80,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildFileInfo(FileItem file) {
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
        _buildInfoRow('Name', file.name),
        _buildInfoRow('Size', DateFormatter.formatFileSize(file.size)),
        _buildInfoRow('Type', file.contentType),
        _buildInfoRow(
            'Uploaded on', DateFormatter.formatDateTime(file.createdAt)),
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

  Widget _buildActionButtons(BuildContext context, FileItem file) {
    return BlocBuilder<FileDetailsCubit, FileDetailsState>(
      builder: (context, state) {
        // Show loading indicators based on state
        final bool isDownloading = state is FileDownloadLoading;
        final bool isSharing = state is FileShareLoading;
        final bool isDeleting = state is FileDeleteLoading;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context: context,
              icon: isDownloading ? Icons.hourglass_empty : Icons.download,
              label: isDownloading ? 'Downloading...' : 'Download',
              onPressed: isDownloading
                  ? null
                  : () {
                      context.read<FileDetailsCubit>().downloadFile(file);
                    },
            ),
            _buildActionButton(
              context: context,
              icon: isSharing ? Icons.hourglass_empty : Icons.share,
              label: isSharing ? 'Sharing...' : 'Share',
              onPressed: isSharing
                  ? null
                  : () {
                      context.read<FileDetailsCubit>().shareFile(file);
                    },
            ),
            _buildActionButton(
              context: context,
              icon: isDeleting ? Icons.hourglass_empty : Icons.delete,
              label: isDeleting ? 'Deleting...' : 'Delete',
              onPressed: isDeleting
                  ? null
                  : () {
                      _showDeleteConfirmation(context);
                    },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: onPressed == null
                  ? Colors.grey.withAlpha(100)
                  : Theme.of(context).primaryColor.withAlpha(100),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: onPressed == null
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
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
              Navigator.pop(context); // Close dialog
              context.read<FileDetailsCubit>().deleteFile(file);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleDownloadSuccess(BuildContext context, File downloadedFile) async {
    try {
      // Create a copy in the application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = downloadedFile.path.split('/').last;
      final savedFile = await downloadedFile.copy('${appDir.path}/$fileName');

      // Open the file
      final result = await OpenFile.open(savedFile.path);

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: ${result.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File downloaded and opened successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error handling file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
