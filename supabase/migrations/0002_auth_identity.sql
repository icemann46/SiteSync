create or replace function public.handle_new_user_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  requested_role text;
  requested_display_name text;
begin
  requested_role := coalesce(new.raw_user_meta_data->>'site_sync_role', 'client');

  if requested_role not in ('gc', 'client') then
    requested_role := 'client';
  end if;

  requested_display_name := nullif(trim(coalesce(new.raw_user_meta_data->>'display_name', '')), '');

  insert into public.profiles (id, role, display_name)
  values (new.id, requested_role, requested_display_name)
  on conflict (id) do update
    set role = excluded.role,
        display_name = excluded.display_name;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created_create_profile on auth.users;

create trigger on_auth_user_created_create_profile
after insert on auth.users
for each row execute function public.handle_new_user_profile();

create or replace function public.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  claims jsonb;
  profile_role text;
begin
  claims := event->'claims';

  select role
    into profile_role
    from public.profiles
    where id = (event->>'user_id')::uuid;

  if profile_role not in ('gc', 'client') or profile_role is null then
    profile_role := 'client';
  end if;

  claims := jsonb_set(
    claims,
    '{app_metadata}',
    coalesce(claims->'app_metadata', '{}'::jsonb),
    true
  );

  claims := jsonb_set(
    claims,
    '{app_metadata,site_sync_role}',
    to_jsonb(profile_role),
    true
  );

  return jsonb_build_object('claims', claims);
end;
$$;

grant usage on schema public to supabase_auth_admin;
grant execute on function public.custom_access_token_hook(jsonb) to supabase_auth_admin;
revoke execute on function public.custom_access_token_hook(jsonb) from authenticated, anon, public;
