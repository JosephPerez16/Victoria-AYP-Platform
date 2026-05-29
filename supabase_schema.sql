create table if not exists public.vayp_trips (
  id text primary key,
  date date not null,
  broker text,
  load text,
  shipper text,
  receiver text,
  origin text not null,
  destination text not null,
  miles numeric default 0,
  rate numeric default 0,
  status text default 'Pendiente',
  total numeric default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.vayp_expenses (
  id text primary key,
  date date not null,
  category text not null,
  description text,
  amount numeric default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);


alter table public.vayp_expenses add column if not exists partner_percent numeric;
alter table public.vayp_expenses add column if not exists partner_amount numeric;

create table if not exists public.vayp_settings (
  id text primary key default 'main',
  company_name text default 'Victoria AYP LLC',
  default_rate_per_mile numeric default 5,
  base_city text default 'Houston, TX',
  updated_at timestamptz default now()
);

create or replace function public.vayp_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists vayp_trips_touch_updated_at on public.vayp_trips;
create trigger vayp_trips_touch_updated_at
before update on public.vayp_trips
for each row execute function public.vayp_touch_updated_at();

drop trigger if exists vayp_expenses_touch_updated_at on public.vayp_expenses;
create trigger vayp_expenses_touch_updated_at
before update on public.vayp_expenses
for each row execute function public.vayp_touch_updated_at();

drop trigger if exists vayp_settings_touch_updated_at on public.vayp_settings;
create trigger vayp_settings_touch_updated_at
before update on public.vayp_settings
for each row execute function public.vayp_touch_updated_at();

alter table public.vayp_trips enable row level security;
alter table public.vayp_expenses enable row level security;
alter table public.vayp_settings enable row level security;

drop policy if exists "vayp_trips_public_select" on public.vayp_trips;
drop policy if exists "vayp_trips_public_insert" on public.vayp_trips;
drop policy if exists "vayp_trips_public_update" on public.vayp_trips;
drop policy if exists "vayp_trips_public_delete" on public.vayp_trips;
create policy "vayp_trips_public_select" on public.vayp_trips for select to anon using (true);
create policy "vayp_trips_public_insert" on public.vayp_trips for insert to anon with check (true);
create policy "vayp_trips_public_update" on public.vayp_trips for update to anon using (true) with check (true);
create policy "vayp_trips_public_delete" on public.vayp_trips for delete to anon using (true);

drop policy if exists "vayp_expenses_public_select" on public.vayp_expenses;
drop policy if exists "vayp_expenses_public_insert" on public.vayp_expenses;
drop policy if exists "vayp_expenses_public_update" on public.vayp_expenses;
drop policy if exists "vayp_expenses_public_delete" on public.vayp_expenses;
create policy "vayp_expenses_public_select" on public.vayp_expenses for select to anon using (true);
create policy "vayp_expenses_public_insert" on public.vayp_expenses for insert to anon with check (true);
create policy "vayp_expenses_public_update" on public.vayp_expenses for update to anon using (true) with check (true);
create policy "vayp_expenses_public_delete" on public.vayp_expenses for delete to anon using (true);

drop policy if exists "vayp_settings_public_select" on public.vayp_settings;
drop policy if exists "vayp_settings_public_insert" on public.vayp_settings;
drop policy if exists "vayp_settings_public_update" on public.vayp_settings;
drop policy if exists "vayp_settings_public_delete" on public.vayp_settings;
create policy "vayp_settings_public_select" on public.vayp_settings for select to anon using (true);
create policy "vayp_settings_public_insert" on public.vayp_settings for insert to anon with check (true);
create policy "vayp_settings_public_update" on public.vayp_settings for update to anon using (true) with check (true);
create policy "vayp_settings_public_delete" on public.vayp_settings for delete to anon using (true);

insert into public.vayp_settings (id, company_name, default_rate_per_mile, base_city)
values ('main', 'Victoria AYP LLC', 5, 'Houston, TX')
on conflict (id) do nothing;

do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='vayp_trips') then
    alter publication supabase_realtime add table public.vayp_trips;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='vayp_expenses') then
    alter publication supabase_realtime add table public.vayp_expenses;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='vayp_settings') then
    alter publication supabase_realtime add table public.vayp_settings;
  end if;
end $$;
