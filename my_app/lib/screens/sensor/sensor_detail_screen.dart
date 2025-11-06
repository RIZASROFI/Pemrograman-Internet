import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/sensor_data.dart' as model;

class SensorDetailScreen extends StatefulWidget {
  final String sensorType;

  const SensorDetailScreen({Key? key, required this.sensorType})
      : super(key: key);

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail ${widget.sensorType}'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sensor_data')
            .orderBy('timestamp', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada data sensor'));
          }

          final docs = snapshot.data!.docs;
          final sensorData = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return model.SensorData(
              temperature: (data['temperature'] ?? 0).toDouble(),
              humidity: (data['humidity'] ?? 0).toDouble(),
              mq2: (data['mq2'] ?? 0).toDouble(),
              mq3: (data['mq3'] ?? 0).toDouble(),
              mq135: (data['mq135'] ?? 0).toDouble(),
              status: data['status'] ?? 'Layak',
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            );
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSensorInfo(sensorData.first),
                const SizedBox(height: 24),
                Text(
                  'Riwayat Data ${widget.sensorType}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildHistoryList(sensorData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSensorInfo(model.SensorData data) {
    String title;
    String description;
    double value;
    String unit;
    String status;
    Color statusColor;

    switch (widget.sensorType) {
      case 'MQ2':
        title = 'MQ2 - Gas Umum';
        description =
            'Mendeteksi gas umum seperti LPG, propana, hidrogen, dan metana. Dalam konteks deteksi pembusukan daging sapi, sensor ini mendeteksi peningkatan gas hidrogen (H2) dan metana (CH4) yang dihasilkan oleh bakteri anaerob saat daging mulai membusuk. Nilai normal: < 50 ppm. Peningkatan gas ini menunjukkan tahap awal pembusukan.';
        value = data.mq2;
        unit = 'ppm';
        status = data.mq2 > 50 ? 'Tinggi - indikasi pembusukan awal' : 'Normal';
        statusColor = data.mq2 > 50 ? Colors.redAccent : Colors.green;
        break;
      case 'MQ3':
        title = 'MQ3 - Alkohol dan Volatile Organic Compounds';
        description =
            'Mendeteksi alkohol, benzena, dan senyawa organik volatil (VOC). Dalam konteks deteksi pembusukan daging sapi, sensor ini mendeteksi peningkatan alkohol (etanol) dan VOC seperti asetaldehida, aseton, dan senyawa sulfur yang dihasilkan saat daging mulai membusuk. Nilai normal: < 150 ppm. Peningkatan alkohol menunjukkan aktivitas fermentasi bakteri.';
        value = data.mq3;
        unit = 'ppm';
        status = data.mq3 > 150 ? 'Tinggi - indikasi pembusukan' : 'Normal';
        statusColor = data.mq3 > 150 ? Colors.redAccent : Colors.green;
        break;
      case 'MQ135':
        title = 'MQ135 - Amonia dan CO₂';
        description =
            'Mendeteksi amonia (NH3) dan karbon dioksida (CO2) dari proses pembusukan. Dalam konteks deteksi pembusukan daging sapi, sensor ini mendeteksi peningkatan amonia yang dihasilkan dari dekomposisi protein oleh bakteri proteolitik, dan CO2 dari respirasi mikroorganisme. Nilai normal: < 100 ppm. Amonia tinggi menunjukkan pembusukan aktif dengan dekomposisi protein.';
        value = data.mq135;
        unit = 'ppm';
        status = data.mq135 > 100 ? 'Tinggi - pembusukan aktif' : 'Normal';
        statusColor = data.mq135 > 100 ? Colors.redAccent : Colors.green;
        break;
      case 'Temperature':
        title = 'DHT11 - Suhu';
        description =
            'Mengukur suhu lingkungan penyimpanan daging. Suhu optimal: 0-4°C untuk pendinginan. Dalam konteks deteksi pembusukan daging sapi, suhu >25°C mempercepat pertumbuhan bakteri seperti Salmonella, E. coli, dan Clostridium yang menyebabkan pembusukan. Suhu tinggi mengakselerasi aktivitas enzimatik dan pertumbuhan mikroorganisme.';
        value = data.temperature;
        unit = '°C';
        status = data.temperature > 25
            ? 'Terlalu panas - risiko pembusukan'
            : 'Optimal';
        statusColor = data.temperature > 25 ? Colors.redAccent : Colors.green;
        break;
      case 'Humidity':
        title = 'DHT11 - Kelembapan';
        description =
            'Mengukur kelembapan udara di lingkungan penyimpanan. Kelembapan optimal: 60-80% untuk penyimpanan. Dalam konteks deteksi pembusukan daging sapi, kelembapan >70% mendorong pertumbuhan jamur (mold) dan bakteri seperti Pseudomonas dan Lactobacillus yang menyebabkan pembusukan. Kelembapan tinggi juga mempercepat oksidasi lemak dan perubahan tekstur daging.';
        value = data.humidity;
        unit = '%';
        status =
            data.humidity > 70 ? 'Terlalu lembab - risiko jamur' : 'Optimal';
        statusColor = data.humidity > 70 ? Colors.orangeAccent : Colors.green;
        break;
      default:
        title = widget.sensorType;
        description = 'Informasi sensor tidak tersedia';
        value = 0;
        unit = '';
        status = 'Tidak diketahui';
        statusColor = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${value.toStringAsFixed(1)} $unit',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terakhir update: ${TimeOfDay.fromDateTime(data.timestamp).format(context)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<model.SensorData> sensorData) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sensorData.length,
      itemBuilder: (context, index) {
        final data = sensorData[index];
        double value;
        String unit;

        switch (widget.sensorType) {
          case 'MQ2':
            value = data.mq2;
            unit = 'ppm';
            break;
          case 'MQ3':
            value = data.mq3;
            unit = 'ppm';
            break;
          case 'MQ135':
            value = data.mq135;
            unit = 'ppm';
            break;
          case 'Temperature':
            value = data.temperature;
            unit = '°C';
            break;
          case 'Humidity':
            value = data.humidity;
            unit = '%';
            break;
          default:
            value = 0;
            unit = '';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            title: Text('${value.toStringAsFixed(1)} $unit'),
            subtitle: Text(
              '${data.timestamp.day}/${data.timestamp.month}/${data.timestamp.year} ${TimeOfDay.fromDateTime(data.timestamp).format(context)}',
            ),
            trailing: Text(
              data.status,
              style: TextStyle(
                color: Color(data.statusColor),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
