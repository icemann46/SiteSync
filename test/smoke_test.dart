import 'package:flutter_test/flutter_test.dart';
import 'package:site_sync/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_sync/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('App boots and redirects to login when unauthenticated', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(AuthState(AuthChangeEvent.initialSession, null))),
        ],
        child: const SiteSyncApp(),
      ),
    );
    
    // Wait for the router to complete navigation
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Login Screen Placeholder (Phase 1)'), findsOneWidget);
  });
}
