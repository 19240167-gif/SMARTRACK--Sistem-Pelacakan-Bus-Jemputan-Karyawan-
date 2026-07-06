# 🔥 Hot Reload DENGAN Extensions - SOLVED!

## 🎯 Problem
Anda butuh:
- ✅ Hot Reload (untuk development)
- ✅ Edge Extensions (untuk testing fitur tertentu)

Masalahnya:
- `flutter run -d edge` → Hot Reload ✅ tapi Edge tanpa extension ❌
- `build + server` → Extension ✅ tapi tidak ada Hot Reload ❌

## ✨ SOLUSI: Flutter Web Server Mode

Flutter punya mode `web-server` yang:
- ✅ Jalankan dev server di localhost
- ✅ Anda buka Edge **manual** dengan profile biasa
- ✅ Hot Reload tetap berfungsi!

---

## 🚀 Cara Menggunakan (SIMPLE)

### Method 1: PowerShell Script (RECOMMENDED) ⭐

**Step 1**: Buka PowerShell di folder project

**Step 2**: Jalankan script:
```powershell
# Izinkan eksekusi script (sekali saja)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Jalankan
.\start_dev_server.ps1
```

**Step 3**: Tunggu hingga muncul "SERVER RUNNING"

**Step 4**: Edge akan **otomatis terbuka** dengan profile Anda (extensions aktif!)

**Step 5**: Edit code, lalu **tekan 'r'** di PowerShell untuk Hot Reload

---

### Method 2: Manual (jika script error)

**Terminal 1** - Start Flutter Server:
```bash
flutter run -d web-server --web-port=8080
```

**Tunggu** hingga muncul:
```
Launching lib\main.dart on Web Server in debug mode...
```

**Terminal 2 / Browser**:
- Buka **Microsoft Edge** (yang biasa Anda pakai)
- Akses: **http://localhost:8080**
- Extensions akan aktif!

**Hot Reload**:
- Edit code di VS Code/editor
- Kembali ke **Terminal 1**
- Tekan **'r'** untuk reload
- Lihat perubahan di Edge!

---

## 📝 Commands di Terminal

Setelah server berjalan, di terminal bisa:
- **`r`** - Hot Reload (reload code changes)
- **`R`** - Restart app from scratch
- **`h`** - Show help
- **`q`** - Quit / Stop server

---

## 🎮 Workflow Development

### Setup Awal (sekali):
```bash
cd C:\Users\Zulfirman\Documents\websemuadisini\backtrack\smartrack
flutter pub get
```

### Setiap Development Session:

**Option A - PowerShell Script**:
```powershell
.\start_dev_server.ps1
```

**Option B - Manual**:
```bash
# Terminal
flutter run -d web-server --web-port=8080

# Browser
# Buka Edge → http://localhost:8080
```

### Saat Edit Code:
1. Edit file di VS Code
2. **Save** (Ctrl+S)
3. Kembali ke terminal
4. Tekan **'r'**
5. Lihat perubahan di Edge (refresh F5 jika perlu)

---

## 🔍 Perbandingan Lengkap

| Method | Hot Reload | Extensions | Auto Open | Speed |
|--------|------------|------------|-----------|-------|
| `flutter run -d edge` | ✅ | ❌ | ✅ | ⚠️ Slow |
| `web-server + PowerShell` | ✅ | ✅ | ✅ | ⚠️ Slow |
| `web-server manual` | ✅ | ✅ | ❌ | ⚠️ Slow |
| `build + python server` | ❌ | ✅ | ❌ | ✅ Fast |

**Kesimpulan**: Pakai `web-server + PowerShell` untuk best of both worlds!

---

## ⚠️ Catatan Penting

### 1. Hot Reload vs Full Build
**Hot Reload** (tekan 'r'):
- ✅ Cepat (1-2 detik)
- ✅ Preserve state (data tidak hilang)
- ⚠️ Kadang perlu refresh browser manual (F5)

**Full Restart** (tekan 'R'):
- ⚠️ Lebih lambat (5-10 detik)
- ❌ Reset state (data hilang)
- ✅ Pasti update semua

### 2. Kapan Butuh Manual Refresh (F5)?
Hot reload kadang tidak update visual changes. Jika setelah tekan 'r' tidak berubah:
- Tekan **F5** di browser
- Atau tekan **'R'** di terminal (full restart)

### 3. Port 8080 Bentrok?
Jika port 8080 sudah dipakai, ganti:
```bash
flutter run -d web-server --web-port=8081
# Lalu buka: http://localhost:8081
```

### 4. PowerShell Script Error?
Jika dapat error "script tidak bisa dijalankan":
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 🐛 Troubleshooting

### Edge tidak auto open?
- Buka manual: `http://localhost:8080`
- Pastikan Edge sudah terinstall di default path

### Hot Reload tidak berfungsi?
1. Pastikan Anda tekan 'r' di **terminal yang menjalankan flutter**
2. Jika tidak ada response, coba:
   - Refresh browser (F5)
   - Atau restart dengan 'R'

### Server error "Port already in use"?
- Stop proses lain yang pakai port 8080
- Atau ganti port: `--web-port=8081`

### Changes tidak muncul?
1. Pastikan file sudah di-save (Ctrl+S)
2. Tekan 'r' di terminal
3. Wait 1-2 seconds
4. Jika masih tidak muncul → refresh browser (F5)

---

## 📊 Files yang Dibuat

```
run_hot_reload_with_extensions.bat   (Windows batch script)
start_dev_server.ps1                  (PowerShell script - RECOMMENDED)
```

**Pilih yang mana?**
- **PowerShell** (.ps1) → Auto open Edge, colored output, lebih canggih ⭐
- **Batch** (.bat) → Simple, tapi tidak auto open Edge

---

## ✅ Summary

**SOLUSI TERBAIK untuk Anda:**

```powershell
# Jalankan ini setiap development:
.\start_dev_server.ps1

# Atau manual:
flutter run -d web-server --web-port=8080
# Lalu buka Edge → http://localhost:8080
```

**Result:**
- ✅ Hot Reload: Tekan 'r' di terminal
- ✅ Extensions: Aktif di Edge
- ✅ Development: Lancar!

**Workflow:**
1. Run script PowerShell
2. Edge auto open dengan extensions
3. Edit code → Save → Tekan 'r' → Lihat perubahan
4. Repeat step 3

Selamat coding! 🚀
