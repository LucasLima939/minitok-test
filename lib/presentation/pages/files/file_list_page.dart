import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../routes/app_router.dart';
import '../../widgets/file_card.dart';
import '../../cubits/file_list/file_list_cubit.dart';
import '../../cubits/file_list/file_list_state.dart';
import '../../cubits/file_upload/file_upload_cubit.dart';
import '../../cubits/file_upload/file_upload_state.dart';
import '../../cubits/register/register_cubit.dart';
import '../../cubits/register/register_state.dart';
import '../../cubits/file_details/file_details_cubit.dart';
import '../../cubits/file_details/file_details_state.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/file_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileListPage extends StatelessWidget {
  const FileListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Files'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FileListCubit>().loadFiles(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<RegisterCubit>().logout();
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FileUploadCubit, FileUploadState>(
            listener: (context, state) {
              if (state is FileUploadLoading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Uploading file...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else if (state is FileUploadSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File uploaded successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh the file list
                context.read<FileListCubit>().loadFiles();
              } else if (state is FileUploadFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Upload failed: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<RegisterCubit, RegisterState>(
            listener: (context, state) {
              if (state is RegisterFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is RegisterInitial) {
                Navigator.of(context).pushReplacementNamed(AppRouter.login);
              }
            },
          ),
          BlocListener<FileDetailsCubit, FileDetailsState>(
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
                // Refresh the file list
                context.read<FileListCubit>().loadFiles();
              } else if (state is FileOperationFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('${state.operation} failed: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<FileListCubit, FileListState>(
          builder: (context, state) {
            if (state is FileListLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is FileListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<FileListCubit>().loadFiles(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is FileListLoaded) {
              final files = state.files;

              if (files.isEmpty) {
                return const Center(
                  child: Text('No files uploaded yet'),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<FileListCubit>().refreshFiles(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return GestureDetector(
                      onLongPress: () => _showFileOptions(context, file),
                      child: FileCard(
                        fileName: file.name,
                        fileSize: DateFormatter.formatFileSize(file.size),
                        fileType: FileUtils.getFileType(file.contentType),
                        uploadDate:
                            DateFormatter.formatShortDate(file.createdAt),
                        iconUrl: file.url,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.fileDetail,
                            arguments: file,
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            }

            // FileListInitial state or any other state
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
                  Navigator.pop(context);
                  context.read<FileUploadCubit>().pickAndUploadImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Upload Document'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<FileUploadCubit>().pickAndUploadDocument();
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

  void _showFileOptions(BuildContext context, dynamic file) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.file_open),
                title: Text('Open ${file.name}'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(
                    AppRouter.fileDetail,
                    arguments: file,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<FileDetailsCubit>().downloadFile(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<FileDetailsCubit>().shareFile(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, file);
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

  void _showDeleteConfirmation(BuildContext context, dynamic file) {
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
