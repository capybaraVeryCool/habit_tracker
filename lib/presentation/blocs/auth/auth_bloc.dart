import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:habeats/data/repositories/auth_repository.dart';
import 'package:habeats/domain/models/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unauthenticated()) {
    _userSubscription = _authRepository.user.listen(
      (user) => add(AuthUserChanged(user)),
    );

    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthState.authenticated(event.user!));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      await _authRepository.signOut();
      emit(const AuthState.signUpSuccess());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      print('Before log in attept!!!!');
      final user_id = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      print('After log in attempt');
      final currentUser = _authRepository.currentUser;
      print(currentUser);
      if (currentUser != null) {
        emit(AuthState.authenticated(currentUser));
        print("Authenticated!!!!!!!!!!!1");
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
