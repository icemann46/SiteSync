create table public.projects (
  id         uuid primary key default gen_random_uuid(),
  gc_id      uuid not null references public.profiles (id) on delete cascade,
  name       text not null,
  address    text,
  start_date date,
  status     text not null default 'active' check (status in ('active', 'pending', 'completed', 'archived')),
  created_at timestamptz not null default now()
);

alter table public.projects enable row level security;

create index projects_gc_status_created_idx
  on public.projects (gc_id, status, created_at desc);

create policy "projects_select_gc_own"
  on public.projects
  for select
  using (
    gc_id = auth.uid()
    and auth.jwt()->'app_metadata'->>'site_sync_role' = 'gc'
  );

create policy "projects_insert_gc_own"
  on public.projects
  for insert
  with check (
    gc_id = auth.uid()
    and auth.jwt()->'app_metadata'->>'site_sync_role' = 'gc'
  );

create policy "projects_update_gc_own"
  on public.projects
  for update
  using (
    gc_id = auth.uid()
    and auth.jwt()->'app_metadata'->>'site_sync_role' = 'gc'
  )
  with check (
    gc_id = auth.uid()
    and auth.jwt()->'app_metadata'->>'site_sync_role' = 'gc'
  );

create policy "projects_delete_gc_own"
  on public.projects
  for delete
  using (
    gc_id = auth.uid()
    and auth.jwt()->'app_metadata'->>'site_sync_role' = 'gc'
  );
