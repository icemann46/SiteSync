import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/project_input.dart';
import '../../domain/entities/project_status.dart';
import '../../domain/errors/project_failure.dart';

class SupabaseProjectsDataSource {
  const SupabaseProjectsDataSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchProjects() async {
    final userId = _requireCurrentUserId();
    final response = await _client
        .from('projects')
        .select()
        .eq('gc_id', userId)
        .neq('status', ProjectStatus.archived.id)
        .order('created_at');

    return _mapsFromResponse(response);
  }

  Future<Map<String, dynamic>?> fetchProjectById(String id) async {
    final userId = _requireCurrentUserId();
    final response = await _client
        .from('projects')
        .select()
        .eq('id', id)
        .eq('gc_id', userId)
        .maybeSingle();

    return response == null ? null : Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> createProject(ProjectInput input) async {
    final userId = _requireCurrentUserId();
    final response = await _client
        .from('projects')
        .insert({
          'gc_id': userId,
          ..._fieldsFromInput(input),
        })
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> updateProject({
    required String id,
    required ProjectInput input,
  }) async {
    final userId = _requireCurrentUserId();
    final response = await _client
        .from('projects')
        .update(_fieldsFromInput(input))
        .eq('id', id)
        .eq('gc_id', userId)
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<void> archiveProject(String id) async {
    final userId = _requireCurrentUserId();
    await _client
        .from('projects')
        .update({'status': ProjectStatus.archived.id})
        .eq('id', id)
        .eq('gc_id', userId);
  }

  String _requireCurrentUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const ProjectFailure('You must be logged in to manage projects.');
    }

    return userId;
  }

  Map<String, dynamic> _fieldsFromInput(ProjectInput input) {
    return {
      'name': input.name.trim(),
      'address': input.address.trim().isEmpty ? null : input.address.trim(),
      'start_date': input.startDate == null ? null : _dateOnly(input.startDate!),
      'status': input.status.id,
    };
  }
}

List<Map<String, dynamic>> _mapsFromResponse(Object? response) {
  if (response is! List) {
    return const [];
  }

  return response.map((row) => Map<String, dynamic>.from(row as Map)).toList();
}

String _dateOnly(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return normalized.toIso8601String().split('T').first;
}
