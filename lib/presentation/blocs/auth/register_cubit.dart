import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit(this._authRepository) : super(const RegisterInitial());

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    emit(const RegisterLoading());

    final result = await _authRepository.signInWithEmailAndPassword(
      email,
      password,
    );

    result.fold(
      (failure) => emit(RegisterFailure(failure.message)),
      (user) => emit(RegisterSuccess(user)),
    );
  }

  /// Create user with email and password
  Future<void> signUp(String email, String password) async {
    emit(const RegisterLoading());

    final result = await _authRepository.createUserWithEmailAndPassword(
      email,
      password,
    );

    result.fold(
      (failure) => emit(RegisterFailure(failure.message)),
      (user) => emit(RegisterSuccess(user)),
    );
  }

  /// Reset the state to initial
  void reset() {
    emit(const RegisterInitial());
  }
}
