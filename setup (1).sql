-- الصقي الملف ده كله في Supabase: SQL Editor > New query > Run

-- جدول الذكريات
create table if not exists public.memories (
  id         text primary key,
  month      int  not null check (month between 1 and 12),
  date       text not null default '',
  text       text not null default '',
  media      jsonb not null default '[]'::jsonb,
  created_at bigint not null
);

alter table public.memories enable row level security;

-- أي حد يقدر يشوف الذكريات
drop policy if exists "everyone can read memories" on public.memories;
create policy "everyone can read memories"
  on public.memories for select
  to anon, authenticated
  using (true);

-- المسجّلة بس (صاحبة الدفتر) تضيف وتحذف
drop policy if exists "owner can add memories" on public.memories;
create policy "owner can add memories"
  on public.memories for insert
  to authenticated
  with check (true);

drop policy if exists "owner can delete memories" on public.memories;
create policy "owner can delete memories"
  on public.memories for delete
  to authenticated
  using (true);

-- مكان الصور والفيديوهات (عام للمشاهدة)
insert into storage.buckets (id, name, public)
values ('memories', 'memories', true)
on conflict (id) do update set public = true;

drop policy if exists "owner can upload files" on storage.objects;
create policy "owner can upload files"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'memories');

drop policy if exists "owner can delete files" on storage.objects;
create policy "owner can delete files"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'memories');
