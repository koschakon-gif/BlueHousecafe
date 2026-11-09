# Blue House Café — เว็บไซต์

เว็บหน้าร้านแบบไฟล์นิ่ง (static) + หน้า admin + Supabase + ไกด์ AI (Gemini)

## โครงสร้าง
| ไฟล์ | หน้าที่ |
|---|---|
| `index.html` | หน้าหลัก (แผนที่ 3D, เค้ก, เมนูใหม่, สินค้า, กิจกรรม, มุมสูง) |
| `admin.html` | หน้าแอดมิน (ล็อกอินด้วย Supabase) |
| `tour-3d.html` | แผนที่ + ไกด์แบบดึงสดจาก OpenStreetMap |
| `trail-banna-doem.html` | เทรลริมคลอง (วาดเส้นทางที่ `#edit`) |
| `supabase-setup.sql` | ตาราง/ที่เก็บรูป/นโยบายความปลอดภัย (ใช้ชื่อเฉพาะ `bluehouse_*`) |
| `functions/bluehouse-guide/` | Supabase Edge Function ของไกด์ AI |
| `media/` | วิดีโอมุมสูง (ล้างพิกัดแล้ว) และรูปการ์ดแชร์ |
| `vercel.json` | หัวข้อความปลอดภัย/แคช เมื่อโฮสต์บน Vercel |
| `DEPLOY.md` | ขั้นตอนติดตั้งทั้งหมด |

## ความปลอดภัย (อ่านก่อน push)
- ใน `index.html` และ `admin.html` มี **Supabase URL และ anon key** ซึ่งออกแบบให้เปิดเผยได้ ความปลอดภัยอยู่ที่ RLS ในฐานข้อมูล
- **ห้าม** commit: `service_role` key, `GEMINI_API_KEY`, รหัสผ่านแอดมิน, ไฟล์ `.env` (อยู่ใน `.gitignore` แล้ว) ความลับเหล่านี้ตั้งใน Supabase → Secrets เท่านั้น
- ถ้าโปรเจกต์ Supabase เป็นตัวเดียวกับระบบ POS ให้ตรวจ RLS ของทุกตารางก่อน และตั้ง repo เป็น **Private** จนกว่าจะตรวจเสร็จ (ดู DEPLOY.md)
- ไฟล์ต้นฉบับจากโดรน (`DJI_*`) มีพิกัด ห้ามใส่ในโปรเจกต์

## Push ขึ้น GitHub
```bash
# 1) สร้าง repo เปล่าบน github.com (แนะนำ Private) แล้ว
git remote add origin https://github.com/<ผู้ใช้>/<ชื่อ-repo>.git
git branch -M main
git push -u origin main
```
