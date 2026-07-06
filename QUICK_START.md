# 🚀 QUICK START - TEST PERBAIKAN LOGIKA

## ⚡ CARA CEPAT TEST APLIKASI

### STEP 1: HOT RESTART
```
1. Klik di terminal yang running
2. Tekan 'R' (huruf besar R)
3. Tunggu aplikasi restart (~10 detik)
```

### STEP 2: BUAT DATA DUMMY DI FIRESTORE

Buka Firebase Console: https://console.firebase.google.com

#### A. Buat Bus
```
Collection: bus
Document ID: [Auto-generate]

Data:
{
  "nomor_bus": "Bus A-01",
  "plat_nomor": "B 1234 XYZ",
  "driver_id": null,
  "driver_nama": null,
  "kapasitas": 40,
  "status": "aktif",
  "created_at": [Pilih Timestamp → Now]
}

Klik Save!
COPY Document ID → Simpan untuk step berikutnya
```

#### B. Buat Perusahaan
```
Collection: perusahaan
Document ID: [Auto-generate]

Data:
{
  "nama": "PT. Industri Jaya",
  "alamat": "Kawasan Industri MM2100, Bekasi",
  "telepon": "021-88888888",
  "email": "info@industrijaya.com",
  "latitude": -6.2088,
  "longitude": 106.8456,
  "is_active": true,
  "created_at": [Pilih Timestamp → Now]
}

Klik Save!
COPY Document ID → Simpan untuk step berikutnya
```

#### C. Buat Titik Jemput
```
Collection: titik_jemput
Document ID: [Auto-generate]

Data:
{
  "nama": "Gerbang Utama",
  "alamat": "Jl. Industri Raya No. 123, Bekasi",
  "latitude": -6.2088,
  "longitude": 106.8456,
  "perusahaan_id": "[PASTE PERUSAHAAN_ID dari Step B]",
  "jam_jemput": "07:00",
  "urutan_jemput": 1,
  "is_active": true,
  "created_at": [Pilih Timestamp → Now]
}

Klik Save!
COPY Document ID → Simpan untuk step berikutnya
```

### STEP 3: REGISTER KARYAWAN BARU

```
1. Buka aplikasi di Edge browser
2. Klik "Daftar" di login screen
3. Isi form:
   - Email: test@karyawan.com
   - Password: 123456
   - Nama: John Doe
   - Role: karyawan
4. Klik Register
5. INGAT: User UID akan di-generate otomatis
```

### STEP 4: UPDATE USER DI FIRESTORE

```
Collection: users
Document: [CARI user dengan email test@karyawan.com]

Klik Edit, tambahkan field:
{
  "bus_id": "[PASTE BUS_ID dari Step A]",
  "titik_jemput_id": "[PASTE TITIK_JEMPUT_ID dari Step C]",
  "perusahaan_id": "[PASTE PERUSAHAAN_ID dari Step B]"
}

Klik Update!
```

### STEP 5: LOGIN & CEK DASHBOARD

```
1. Logout dari aplikasi (jika sudah login)
2. Login dengan:
   - Email: test@karyawan.com
   - Password: 123456
3. Cek Dashboard Karyawan:
   ✅ "Bus Anda" sekarang tampil: "Bus A-01"
   ✅ "Titik Jemput" sekarang tampil: "Gerbang Utama"
   ✅ "Jam Berangkat" sekarang tampil: "07:00 WIB"
   ✅ "Perusahaan" sekarang tampil: "PT. Industri Jaya"
```

---

## 🎉 HASIL YANG DIHARAPKAN

### SEBELUM PERBAIKAN:
```
Bus Anda: Bus A-01          ❌ HARDCODED
Titik Jemput: Gerbang Utama ❌ HARDCODED
Jam Berangkat: 07:00 WIB    ❌ HARDCODED
Perusahaan: PT. Industri    ❌ HARDCODED
```

### SETELAH PERBAIKAN:
```
Bus Anda: Bus A-01          ✅ FROM FIRESTORE
Titik Jemput: Gerbang Utama ✅ FROM FIRESTORE
Jam Berangkat: 07:00 WIB    ✅ FROM FIRESTORE
Perusahaan: PT. Industri Jaya ✅ FROM FIRESTORE
```

### JIKA DATA BELUM DI-ASSIGN:
```
Bus Anda: Belum Ditentukan          ✅ FALLBACK TEXT
Titik Jemput: Belum Ditentukan      ✅ FALLBACK TEXT
Jam Berangkat: Belum Ditentukan     ✅ FALLBACK TEXT
Perusahaan: Belum Ditentukan        ✅ FALLBACK TEXT
```

---

## 🔧 TROUBLESHOOTING

### Problem: "Belum Ditentukan" terus muncul
**Solusi:**
1. Cek apakah user sudah punya field `bus_id`, `titik_jemput_id`, `perusahaan_id`
2. Cek apakah Document ID sudah benar (case-sensitive!)
3. Refresh browser atau hot restart aplikasi

### Problem: Loading terus
**Solusi:**
1. Cek koneksi internet
2. Cek Firebase Console apakah data sudah tersimpan
3. Cek browser console (F12) untuk error message

### Problem: "Error" muncul
**Solusi:**
1. Cek Firestore Security Rules
2. Cek apakah user sudah login
3. Cek browser console (F12) untuk error detail

---

## 📊 DATA STRUCTURE REFERENCE

```
users (collection)
  └── [user_uid] (document)
      ├── email: "test@karyawan.com"
      ├── nama: "John Doe"
      ├── role: "karyawan"
      ├── bus_id: "[BUS_DOC_ID]"           ← LINK KE BUS
      ├── titik_jemput_id: "[TITIK_DOC_ID]" ← LINK KE TITIK JEMPUT
      └── perusahaan_id: "[PERUSAHAAN_DOC_ID]" ← LINK KE PERUSAHAAN

bus (collection)
  └── [bus_doc_id] (document)
      ├── nomor_bus: "Bus A-01"
      ├── plat_nomor: "B 1234 XYZ"
      └── status: "aktif"

titik_jemput (collection)
  └── [titik_doc_id] (document)
      ├── nama: "Gerbang Utama"
      ├── alamat: "Jl. Industri..."
      ├── jam_jemput: "07:00"
      └── perusahaan_id: "[PERUSAHAAN_DOC_ID]"

perusahaan (collection)
  └── [perusahaan_doc_id] (document)
      ├── nama: "PT. Industri Jaya"
      └── alamat: "Kawasan Industri..."
```

---

## ✅ CHECKLIST

Sebelum test, pastikan:
- [ ] Flutter app masih running di Edge
- [ ] Firebase Console sudah dibuka
- [ ] Sudah buat data: bus, perusahaan, titik_jemput
- [ ] Sudah assign data ke user (bus_id, titik_jemput_id, perusahaan_id)
- [ ] Sudah hot restart aplikasi (tekan R)

---

**GOOD LUCK! 🚀**
