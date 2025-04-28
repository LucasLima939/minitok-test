import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:minitok_test/data/repositories/file_repository_impl.dart';
import 'package:minitok_test/infra/adapters/firebase_storage_adapter.dart';
import 'package:minitok_test/infra/adapters/image_picker_adapter.dart';
import 'package:minitok_test/infra/adapters/file_picker_adapter.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/cubits/register/register_cubit.dart';
import 'presentation/cubits/file_details/file_details_cubit.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'infra/adapters/firebase_auth_adapter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'presentation/cubits/file_list/file_list_cubit.dart';
import 'presentation/cubits/file_upload/file_upload_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final firebaseAuthAdapter = FirebaseAuthAdapterImpl(
        firebaseAuth: firebase_auth.FirebaseAuth.instance);
    final authRepository = AuthRepositoryImpl(firebaseAuthAdapter);
    final storageAdapter = FirebaseStorageAdapterImpl();
    final fileRepository =
        FileRepositoryImpl(storageAdapter, firebaseAuthAdapter);
    final imagePickerAdapter = ImagePickerAdapterImpl();
    final filePickerAdapter = FilePickerAdapterImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterCubit>(
          create: (context) => RegisterCubit(authRepository),
        ),
        BlocProvider(
          create: (context) => FileListCubit(fileRepository)..loadFiles(),
        ),
        BlocProvider(
          create: (context) => FileUploadCubit(
            fileRepository,
            imagePickerAdapter: imagePickerAdapter,
            filePickerAdapter: filePickerAdapter,
          ),
        ),
        BlocProvider(
          create: (context) => FileDetailsCubit(fileRepository),
        ),
      ],
      child: MaterialApp(
        title: 'MiniTok',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.login,
      ),
    );
  }
}
