create table public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  role         text not null check (role in ('gc', 'client')),
  display_name text,
  created_at   timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- A user can read/insert/update only their own row.
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);
