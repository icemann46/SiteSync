import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/env_config.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/sign_up_result.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/send_password_reset_email_use_case.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';
import '../../domain/usecases/update_password_use_case.dart';

part 'auth_provider.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

@riverpod
SupabaseAuthDataSource supabaseAuthDataSource(Ref ref) {
  return SupabaseAuthDataSource(ref.watch(supabaseClientProvider));
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return SupabaseAuthRepository(ref.watch(supabaseAuthDataSourceProvider));
}

@riverpod
class AuthController extends _$AuthController {
  @override
  Future<AppUser?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final subscription = repository.watchAuthState().listen((user) {
      state = AsyncData(user);
    });

    ref.onDispose(subscription.cancel);

    return GetCurrentUserUseCase(repository)();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final user = await SignInUseCase(ref.read(authRepositoryProvider))(
      email: email,
      password: password,
    );
    state = AsyncData(user);
  }

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    final result = await SignUpUseCase(ref.read(authRepositoryProvider))(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
    state = AsyncData(result.user);
    return result;
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return SendPasswordResetEmailUseCase(ref.read(authRepositoryProvider))(
      email: email,
    );
  }

  Future<void> updatePassword({required String password}) async {
    await UpdatePasswordUseCase(ref.read(authRepositoryProvider))(
      password: password,
    );
    final user = await GetCurrentUserUseCase(ref.read(authRepositoryProvider))();
    state = AsyncData(user);
  }

  Future<void> signOut() async {
    await SignOutUseCase(ref.read(authRepositoryProvider))();
    state = const AsyncData(null);
  }

  bool get hasPasswordResetRedirect {
    return EnvConfig.authRedirectUrl.isNotEmpty;
  }
}
