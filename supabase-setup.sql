-- Blue House Café · ตั้งค่า Supabase สำหรับหน้า admin
-- สิ่งที่ไฟล์นี้สร้าง (ใหม่ทั้งหมด ใช้ชื่อเฉพาะ ไม่แก้ ไม่ลบ ไม่อ่านของเดิม):
--   • ตาราง  public.bluehouse_site_config
--   • bucket รูป  bluehouse-site  (ถ้าชื่อนี้มีอยู่แล้ว จะไม่แก้ค่าของมัน)
--   • policy ชื่อขึ้นต้นด้วย "bluehouse" 5 ตัว (ผูกกับตารางและ bucket ข้างบนเท่านั้น)
-- ไม่แตะ: ตารางอื่น, bucket อื่น, ผู้ใช้/การตั้งค่า Auth ของแอปอื่นในโปรเจกต์เดียวกัน
--
-- วิธีใช้: SQL Editor → วางทั้งไฟล์ → แทนที่ OWNER_EMAIL ทุกจุดด้วยอีเมลแอดมิน → Run
-- (ใช้บัญชีที่มีอยู่แล้วในโปรเจกต์ได้ หรือสร้างใหม่ที่ Authentication → Users)

-- 1) ตารางเก็บข้อมูลหน้าเว็บ
create table if not exists public.bluehouse_site_config (
  key        text primary key,
  value      jsonb not null,
  updated_at timestamptz not null default now()
);
alter table public.bluehouse_site_config enable row level security;

drop policy if exists "bluehouse config public read" on public.bluehouse_site_config;
create policy "bluehouse config public read" on public.bluehouse_site_config
  for select to anon, authenticated using (true);

drop policy if exists "bluehouse config owner write" on public.bluehouse_site_config;
create policy "bluehouse config owner write" on public.bluehouse_site_config
  for all to authenticated
  using      ((auth.jwt() ->> 'email') = 'OWNER_EMAIL')
  with check ((auth.jwt() ->> 'email') = 'OWNER_EMAIL');

-- 2) ที่เก็บรูป (อ่านได้สาธารณะ เฉพาะรูป ไม่เกิน 5 MB)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('bluehouse-site', 'bluehouse-site', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists "bluehouse images owner insert" on storage.objects;
create policy "bluehouse images owner insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'bluehouse-site' and (auth.jwt() ->> 'email') = 'OWNER_EMAIL');

drop policy if exists "bluehouse images owner update" on storage.objects;
create policy "bluehouse images owner update" on storage.objects
  for update to authenticated
  using      (bucket_id = 'bluehouse-site' and (auth.jwt() ->> 'email') = 'OWNER_EMAIL')
  with check (bucket_id = 'bluehouse-site' and (auth.jwt() ->> 'email') = 'OWNER_EMAIL');

drop policy if exists "bluehouse images owner delete" on storage.objects;
create policy "bluehouse images owner delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'bluehouse-site' and (auth.jwt() ->> 'email') = 'OWNER_EMAIL');

-- 3) ผู้ใช้แอดมิน: ต้องมีผู้ใช้ที่อีเมลตรงกับ OWNER_EMAIL ใน Authentication → Users
--    (ไม่จำเป็นต้องปิดการสมัครสมาชิก ถ้าแอปอื่นของคุณใช้อยู่ ปล่อยไว้ได้
--     เพราะสิทธิ์เขียนผูกกับอีเมลนี้อีเมลเดียว ใช้รหัสผ่านยาว ๆ และเปิด Confirm email ไว้)
--
-- ===== ถอนทั้งหมด (ถ้าอยากลบสิ่งที่ไฟล์นี้สร้าง) — เอา -- ออกแล้วรัน =====
-- drop policy if exists "bluehouse images owner delete" on storage.objects;
-- drop policy if exists "bluehouse images owner update" on storage.objects;
-- drop policy if exists "bluehouse images owner insert" on storage.objects;
-- delete from storage.objects where bucket_id = 'bluehouse-site';
-- delete from storage.buckets where id = 'bluehouse-site';
-- drop table if exists public.bluehouse_site_config;
