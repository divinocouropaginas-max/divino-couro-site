-- Executar SOMENTE em um projeto Supabase exclusivo da Divino Couro.
create table if not exists public.admins(user_id uuid primary key references auth.users(id) on delete cascade);
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(),
 reference text not null unique,
 name text not null,
 description text not null default '',
 image_url text,
 sort_order integer not null default 0,
 available boolean not null default true,
 active boolean not null default true,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
alter table public.admins enable row level security;
alter table public.products enable row level security;
create policy "Admins veem propria permissao" on public.admins for select to authenticated using (user_id=(select auth.uid()));
create policy "Publico ve produtos publicados" on public.products for select to anon,authenticated using (active=true or exists(select 1 from public.admins a where a.user_id=(select auth.uid())));
create policy "Admin cadastra produtos" on public.products for insert to authenticated with check (exists(select 1 from public.admins a where a.user_id=(select auth.uid())));
create policy "Admin altera produtos" on public.products for update to authenticated using (exists(select 1 from public.admins a where a.user_id=(select auth.uid()))) with check (exists(select 1 from public.admins a where a.user_id=(select auth.uid())));
create policy "Admin exclui produtos" on public.products for delete to authenticated using (exists(select 1 from public.admins a where a.user_id=(select auth.uid())));
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values ('catalog','catalog',true,8388608,array['image/jpeg','image/png','image/webp']) on conflict(id) do nothing;
create policy "Fotos catalogo publicas" on storage.objects for select to anon, authenticated using (bucket_id='catalog');
create policy "Admin adiciona fotos" on storage.objects for insert to authenticated with check (bucket_id='catalog' and exists(select 1 from public.admins a where a.user_id=(select auth.uid())));
create policy "Admin altera fotos" on storage.objects for update to authenticated using (bucket_id='catalog' and exists(select 1 from public.admins a where a.user_id=(select auth.uid()))) with check (bucket_id='catalog' and exists(select 1 from public.admins a where a.user_id=(select auth.uid())));
-- Após cadastrar o usuário pelo Supabase Auth, autorize com o UUID real:
-- insert into public.admins(user_id) values ('UUID-REAL-DO-USUARIO');
-- Produtos iniciais: ajustar fotos e títulos após a revisão com a Letícia.
