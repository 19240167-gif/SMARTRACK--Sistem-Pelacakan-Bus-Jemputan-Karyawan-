# 🔐 Cara Membuat Akun Admin

## ⚠️ PENTING
Akun admin **TIDAK dibuat otomatis**. Anda harus buat manual di Firebase Console.

---

## 📝 Step-by-Step

### 1️⃣ Buka Firebase Console
- URL: https://console.firebase.google.com
- Login dengan akun Google Anda
- Pilih project: **SMARTRACK**

### 2️⃣ Buat User di Authentication
1. Klik **"Authentication"** di sidebar kiri
2. Klik tab **"Users"**
3. Klik tombol **"Add user"**
4. Isi form:
   - **Email**: `admin@smartrack.com` (atau email Anda)
   - **Password**: `admin123` (minimal 6 karakter)
   - **User UID**: (otomatis generate)
5. Klik **"Add user"**
6. **Copy UID** user yang baru dibuat (Anda akan butuh ini)

### 3️⃣ Set Role di Firestore
1. Klik **"Firestore Database"** di sidebar
2. Cari collection **`users`**
   - Jika belum ada: Klik **"Start collection"** → Beri nama `users`
3. Klik **"Add document"**
4. **Document ID**: Paste **UID** dari step 2
5. Tambahkan fields:

| Field Name | Type | Value |
|------------|------|-------|
| `email` | string | `admin@smartrack.com` |
| `nama` | string | `Administrator` |
| `role` | string | `admin` |
| `is_active` | boolean | `true` |
| `created_at` | timestamp | (klik "Set timestamp") |
| `bus_id` | (kosongkan) | |
| `titik_jemput_id` | (kosongkan) | |
| `photo_url` | (kosongkan) | |

6. Klik **"Save"**

### 4️⃣ Test Login
1. Buka aplikasi SMARTRACK
2. Login dengan:
   - **Email**: `admin@smartrack.com`
   - **Password**: `admin123`
3. Seharusnya redirect ke **Dashboard Admin** ✅

---

## 🎯 Contoh Data Firestore

```json
// Collection: users
// Document ID: [UID dari Authentication, contoh: "abc123xyz"]
{
  "email": "admin@smartrack.com",
  "nama": "Administrator",
  "role": "admin",
  "is_active": true,
  "created_at": Timestamp(now),
  "bus_id": null,
  "titik_jemput_id": null,
  "photo_url": null
}
```

---

## 🔑 Credentials untuk Testing

Setelah dibuat, gunakan:

```
Email: admin@smartrack.com
Password: admin123
```

**CATATAN**: Ganti password ini untuk production!

---

## 🐛 Troubleshooting

### Error: "Email tidak terdaftar"
- Pastikan user sudah dibuat di **Authentication > Users**
- Cek email yang diinput, harus sama persis

### Error: "Password salah"
- Pastikan password minimal 6 karakter
- Cek di Firebase Console, bisa reset password

### Login berhasil tapi error / tidak redirect
- Pastikan document di **Firestore > users** sudah dibuat
- Pastikan field `role` = `"admin"` (lowercase)
- Pastikan `is_active` = `true`

### Tidak ada collection "users"
- Buat manual: Firestore Database → Start collection → Nama: `users`
- Atau login sekali sebagai user biasa untuk auto-create collection

---

## 📊 Struktur Role

| Role | Access | Dashboard |
|------|--------|-----------|
| `admin` | Full access (CRUD semua) | Dashboard Admin |
| `driver` | Update GPS tracking | Dashboard Driver |
| `karyawan` | View tracking only | Dashboard Karyawan |

---

## ⚡ Quick Commands

**Buat user via Firebase Console:**
1. Authentication → Add user
2. Email: `admin@smartrack.com`, Password: `admin123`
3. Copy UID
4. Firestore → users → Add doc dengan UID tersebut
5. Fields: email, nama, role="admin", is_active=true

**Test login:**
- Email: `admin@smartrack.com`
- Password: `admin123`

Done! ✅
