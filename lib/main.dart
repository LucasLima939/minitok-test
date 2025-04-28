import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/blocs/auth/register_cubit.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'infra/adapters/firebase_auth_adapter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

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

    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterCubit>(
          create: (context) => RegisterCubit(authRepository),
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
