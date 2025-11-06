# Panduan Pengguna Aplikasi Monitoring Kesegaran Daging Sapi

## Daftar Isi
1. [Pendahuluan](#pendahuluan)
2. [Instalasi dan Persiapan](#instalasi-dan-persiapan)
3. [Memulai Aplikasi](#memulai-aplikasi)
4. [Fitur Utama](#fitur-utama)
5. [Panduan Penggunaan](#panduan-penggunaan)
6. [Penjelasan Sensor dan Status](#penjelasan-sensor-dan-status)
7. [Penyelesaian Masalah](#penyelesaian-masalah)
8. [FAQ](#faq)
9. [Kontak Dukungan](#kontak-dukungan)

## Pendahuluan

Selamat datang di **Sistem Monitoring Kesegaran Daging Sapi**, sebuah aplikasi mobile berbasis Flutter yang dirancang untuk memantau kesegaran daging sapi secara real-time menggunakan teknologi IoT (Internet of Things) dan Machine Learning. Aplikasi ini terintegrasi dengan Firebase untuk penyimpanan data dan autentikasi pengguna.

### Tujuan Aplikasi
- Memantau parameter lingkungan penyimpanan daging sapi (suhu, kelembapan, gas pembusukan).
- Menentukan status kesegaran daging secara otomatis (Layak/Tidak Layak).
- Memberikan notifikasi real-time jika ada indikasi pembusukan.
- Menyediakan analisis data sensor melalui grafik dan riwayat.

### Persyaratan Sistem
- **Perangkat**: Smartphone Android atau iOS dengan versi terbaru.
- **Sistem Operasi**: Android 8.0+ atau iOS 12.0+.
- **Koneksi Internet**: Diperlukan untuk sinkronisasi data real-time.
- **Sensor IoT**: ESP32 atau perangkat IoT yang terhubung ke Firebase (opsional untuk pengguna akhir).

## Instalasi dan Persiapan

### 1. Instalasi Flutter
1. Kunjungi situs resmi Flutter: [flutter.dev](https://flutter.dev).
2. Ikuti panduan instalasi untuk sistem operasi Anda (Windows, macOS, Linux).
3. Pastikan Flutter SDK terinstal dengan menjalankan perintah:
   ```
   flutter doctor
   ```
4. Instal Android Studio atau Xcode untuk emulator.

### 2. Mengunduh dan Menjalankan Aplikasi
1. Clone repositori aplikasi dari GitHub (jika tersedia) atau salin file proyek ke komputer Anda.
2. Buka terminal di direktori proyek (`my_app/`).
3. Jalankan perintah berikut untuk mengunduh dependensi:
   ```
   flutter pub get
   ```
4. Konfigurasi Firebase:
   - Buat proyek baru di [Firebase Console](https://console.firebase.google.com).
   - Aktifkan Authentication (Email/Password) dan Firestore Database.
   - Unduh file `google-services.json` (Android) atau `GoogleService-Info.plist` (iOS) dan tempatkan di folder yang sesuai.
   - Pastikan file `firebase_options.dart` sudah dikonfigurasi dengan benar.

5. Jalankan aplikasi di emulator atau perangkat fisik:
   ```
   flutter run
   ```

### 3. Konfigurasi Awal
- Pastikan perangkat IoT (ESP32) terhubung ke Firebase dan mengirim data sensor secara berkala.
- Jika tidak ada sensor fisik, gunakan fitur "Seed Dummy Data" di aplikasi untuk testing.

## Memulai Aplikasi

### Registrasi dan Login
1. **Buka Aplikasi**: Luncurkan aplikasi di perangkat Anda.
2. **Registrasi Akun Baru**:
   - Klik "Daftar disini" di layar login.
   - Masukkan email dan password yang valid (minimal 6 karakter).
   - Klik "Daftar" untuk membuat akun.
3. **Login**:
   - Masukkan email dan password yang sudah terdaftar.
   - Klik "Masuk" untuk masuk ke dashboard.

### Dashboard Utama
Setelah login, Anda akan diarahkan ke dashboard yang menampilkan:
- Status kesegaran daging (Layak/Tidak Layak).
- Kartu sensor dengan nilai terkini.
- Grafik tren sensor.
- Penjelasan status dan rekomendasi.

## Fitur Utama

- **Autentikasi Pengguna**: Login dan registrasi dengan Firebase Authentication.
- **Monitoring Real-Time**: Data sensor diperbarui secara otomatis dari Firestore.
- **Penentuan Status**: Algoritma otomatis berdasarkan threshold sensor.
- **Detail Sensor**: Halaman khusus untuk setiap sensor dengan riwayat dan penjelasan.
- **Notifikasi**: Pemberitahuan push jika status berubah menjadi "Tidak Layak".
- **Grafik dan Analisis**: Visualisasi data menggunakan FL Chart.
- **Seed Data Dummy**: Untuk testing tanpa sensor fisik.

## Panduan Penggunaan

### 1. Melihat Dashboard
- **Status Daging**: Lihat banner hijau (Layak) atau merah (Tidak Layak) di bagian atas.
- **Kartu Sensor**: Klik pada kartu sensor untuk melihat detail lebih lanjut.
- **Grafik Tren**: Gulir ke bawah untuk melihat grafik perubahan nilai sensor dari waktu ke waktu.
- **Penjelasan Status**: Baca penjelasan di bawah status untuk memahami kondisi daging.

### 2. Menggunakan Fitur Seed Data
Untuk testing tanpa sensor fisik:
1. Klik tombol "Seed Dummy Data" (Data Layak atau Tidak Layak).
2. Data akan ditambahkan ke database dan dashboard akan diperbarui.
3. Gunakan ini untuk mensimulasikan berbagai skenario.

### 3. Melihat Detail Sensor
1. Dari dashboard, klik pada salah satu kartu sensor (MQ2, MQ3, dll.).
2. Halaman detail akan menampilkan:
   - Nilai terkini dan status.
   - Penjelasan fungsi sensor.
   - Riwayat data dalam bentuk list.

### 4. Logout
- Klik ikon logout di app bar untuk keluar dari akun.

## Penjelasan Sensor dan Status

### Sensor yang Digunakan
Aplikasi menggunakan 5 sensor utama:

1. **MQ2 - Gas Umum** (ppm)
   - Mendeteksi gas seperti LPG, propana, hidrogen, metana.
   - Threshold: < 50 ppm (Normal), > 50 ppm (Tinggi - indikasi pembusukan awal).

2. **MQ3 - Alkohol dan VOC** (ppm)
   - Mendeteksi alkohol, benzena, dan senyawa organik volatil.
   - Threshold: < 150 ppm (Normal), > 150 ppm (Tinggi - indikasi pembusukan).

3. **MQ135 - Amonia dan CO₂** (ppm)
   - Mendeteksi amonia dan karbon dioksida dari pembusukan.
   - Threshold: < 100 ppm (Normal), > 100 ppm (Tinggi - pembusukan aktif).

4. **DHT11 - Suhu** (°C)
   - Mengukur suhu lingkungan.
   - Threshold: < 25°C (Optimal), > 25°C (Terlalu panas - risiko pembusukan).

5. **DHT11 - Kelembapan** (%)
   - Mengukur kelembapan udara.
   - Threshold: < 70% (Optimal), > 70% (Terlalu lembab - risiko jamur).

### Penentuan Status Daging
- **Layak**: Semua parameter dalam batas normal. Daging aman dikonsumsi.
- **Tidak Layak**: Salah satu atau lebih parameter melebihi threshold. Indikasi pembusukan awal atau aktif.

Status ditentukan berdasarkan kombinasi semua sensor untuk akurasi maksimal.

## Penyelesaian Masalah

### Masalah Umum dan Solusi

1. **Tidak Bisa Login**
   - Pastikan email dan password benar.
   - Periksa koneksi internet.
   - Jika lupa password, gunakan fitur reset di Firebase (belum diimplementasi di app).

2. **Data Sensor Tidak Muncul**
   - Pastikan perangkat IoT terhubung dan mengirim data ke Firebase.
   - Periksa koneksi internet.
   - Gunakan "Seed Dummy Data" untuk testing.

3. **Aplikasi Crash atau Error**
   - Restart aplikasi.
   - Pastikan Flutter dan dependensi terbaru.
   - Jalankan `flutter clean` dan `flutter pub get` ulang.

4. **Notifikasi Tidak Berfungsi**
   - Periksa pengaturan notifikasi di perangkat.
   - Pastikan izin notifikasi diberikan saat pertama kali membuka app.

5. **Grafik Tidak Tampil**
   - Pastikan ada data sensor di database.
   - Restart aplikasi jika grafik kosong.

### Log Error
Jika mengalami error, periksa log di terminal saat menjalankan `flutter run` atau gunakan DevTools untuk debugging.

## FAQ

**Q: Apakah aplikasi ini bisa digunakan tanpa sensor IoT?**  
A: Ya, Anda bisa menggunakan fitur "Seed Dummy Data" untuk testing dan demonstrasi.

**Q: Bagaimana cara menghubungkan sensor ESP32?**  
A: Konfigurasi ESP32 untuk mengirim data ke Firestore Firebase. Kode ESP32 tersedia terpisah (tidak termasuk dalam app mobile ini).

**Q: Apakah data disimpan secara lokal?**  
A: Tidak, semua data disimpan di cloud Firebase untuk akses real-time.

**Q: Berapa frekuensi pembaruan data sensor?**  
A: Tergantung konfigurasi perangkat IoT, biasanya setiap 5-10 detik.

**Q: Apakah aplikasi mendukung multi-user?**  
A: Ya, setiap pengguna memiliki akun terpisah dan data pribadi.

**Q: Bagaimana cara backup data?**  
A: Data otomatis disimpan di Firebase. Untuk backup manual, ekspor dari Firebase Console.

## Kontak Dukungan

Jika Anda mengalami masalah atau memiliki pertanyaan, hubungi tim pengembang:
- Email: support@meatfreshness.com (fiktif)
- Dokumentasi Lengkap: [GitHub Repository](https://github.com/username/meat-freshness-monitor) (jika tersedia)

---

**Versi Manual**: 1.0  
**Tanggal**: Oktober 2024  
**Pengembang**: Tim IoT & Mobile Development

Terima kasih telah menggunakan Sistem Monitoring Kesegaran Daging Sapi!
