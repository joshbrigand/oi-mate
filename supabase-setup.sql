-- Oi Mate: run this ONCE in Supabase (SQL Editor > New query > paste > Run).

-- 1. One saved project per signed-in owner
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  owner uuid not null unique references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.projects enable row level security;

drop policy if exists "owner reads own project" on public.projects;
drop policy if exists "owner inserts own project" on public.projects;
drop policy if exists "owner updates own project" on public.projects;
drop policy if exists "owner deletes own project" on public.projects;

create policy "owner reads own project"   on public.projects for select to authenticated using (auth.uid() = owner);
create policy "owner inserts own project" on public.projects for insert to authenticated with check (auth.uid() = owner);
create policy "owner updates own project" on public.projects for update to authenticated using (auth.uid() = owner) with check (auth.uid() = owner);
create policy "owner deletes own project" on public.projects for delete to authenticated using (auth.uid() = owner);

-- 2. What a tradie sees after scanning a sticker: ONE room, plus tradie names and trades only
--    (no phone numbers or emails), found by the room's long random id.
create or replace function public.get_room_public(p_room text)
returns jsonb
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  d jsonb;
  rm jsonb;
begin
  select p.data, r into d, rm
  from public.projects p,
       jsonb_array_elements(coalesce(p.data->'rooms', '[]'::jsonb)) r
  where r->>'id' = p_room
  limit 1;

  if rm is null then
    return null;
  end if;

  return jsonb_build_object(
    'room', rm,
    'tradies', coalesce((
      select jsonb_agg(jsonb_build_object('id', t->>'id', 'name', t->>'name', 'trade', t->>'trade'))
      from jsonb_array_elements(coalesce(d->'tradies', '[]'::jsonb)) t
    ), '[]'::jsonb)
  );
end;
$$;

grant execute on function public.get_room_public(text) to anon, authenticated;

-- 3. Attachments (plans, spec sheets): anyone with a file's link can open it,
--    only the signed-in owner can add or remove files in their own folder.
insert into storage.buckets (id, name, public)
values ('attachments', 'attachments', true)
on conflict (id) do update set public = true;

drop policy if exists "owners upload own files" on storage.objects;
drop policy if exists "owners update own files" on storage.objects;
drop policy if exists "owners delete own files" on storage.objects;

create policy "owners upload own files" on storage.objects for insert to authenticated
  with check (bucket_id = 'attachments' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "owners update own files" on storage.objects for update to authenticated
  using (bucket_id = 'attachments' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "owners delete own files" on storage.objects for delete to authenticated
  using (bucket_id = 'attachments' and (storage.foldername(name))[1] = auth.uid()::text);
