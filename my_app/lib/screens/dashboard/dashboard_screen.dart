import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/sensor_chart.dart';
import '../../widgets/sensor_card.dart';
import '../../models/sensor_data.dart' as model;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _seeding = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard Kualitas Daging'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: [
          if (user != null)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(user.displayName ?? user.email ?? ''),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white24,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Text(
                            (user.displayName != null &&
                                    user.displayName!.isNotEmpty)
                                ? user.displayName!
                                    .substring(0, 1)
                                    .toUpperCase()
                                : (user.email != null
                                    ? user.email!.substring(0, 1).toUpperCase()
                                    : ''),
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(c).pop(false),
                        child: const Text('Batal')),
                    TextButton(
                        onPressed: () => Navigator.of(c).pop(true),
                        child: const Text('Logout')),
                  ],
                ),
              );

              if (ok == true) {
                await auth.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anda telah logout')),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sensor_data')
            .orderBy('timestamp', descending: true)
            .limit(2)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading sensor: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Render empty-state dashboard shell so UI matches design even when there's no data
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Empty status banner
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200)),
                    child: Row(children: [
                      const Icon(Icons.info, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text('Status Daging: Layak',
                              style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold))),
                    ]),
                  ),

                  // Small metric cards row (zeros)
                  Row(children: [
                    _smallMetricPlaceholder('MQ2', '0.0', 'ppm'),
                    const SizedBox(width: 8),
                    _smallMetricPlaceholder('MQ3', '0.0', 'ppm'),
                    const SizedBox(width: 8),
                    _smallMetricPlaceholder('MQ135', '0.0', 'ppm'),
                    const SizedBox(width: 8),
                    _smallMetricPlaceholder('Suhu', '0.0', '°C'),
                    const SizedBox(width: 8),
                    _smallMetricPlaceholder('Kelembapan', '0.0', '%'),
                  ]),

                  const SizedBox(height: 24),
                  Text('Grafik Tren Sensor',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // action buttons to seed data for development
                  Row(children: [
                    ElevatedButton.icon(
                      onPressed: _seeding
                          ? null
                          : () async {
                              setState(() {
                                _seeding = true;
                              });
                              try {
                                await _databaseService.seedDummyData(
                                    count: 12, makeBad: false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Dummy data seeded')));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Seed failed: $e')));
                              } finally {
                                setState(() {
                                  _seeding = false;
                                });
                              }
                            },
                      icon: const Icon(Icons.bolt),
                      label: Text(_seeding ? 'Seeding...' : 'Seed Dummy Data'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      onPressed: _seeding
                          ? null
                          : () async {
                              setState(() {
                                _seeding = true;
                              });
                              try {
                                await _databaseService.seedDummyData(
                                    count: 12, makeBad: true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Bad dummy data seeded')));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Seed failed: $e')));
                              } finally {
                                setState(() {
                                  _seeding = false;
                                });
                              }
                            },
                      icon: const Icon(Icons.warning),
                      label: Text(_seeding ? 'Seeding...' : 'Seed Bad Data'),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // placeholder large area
                  Container(
                      height: 280,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4)
                          ]),
                      child: const Center(
                          child: Text('No sensor data available'))),
                  const SizedBox(height: 12),
                  Container(
                      height: 180,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4)
                          ]),
                      child: const Center(child: Text('No data'))),
                ],
              ),
            );
          }

          // parse latest
          final docs = snapshot.data!.docs;
          final latest = docs.first.data() as Map<String, dynamic>;

          final sensor = model.SensorData(
            temperature: (latest['temperature'] ?? 0).toDouble(),
            humidity: (latest['humidity'] ?? 0).toDouble(),
            mq2: (latest['mq2'] ?? 0).toDouble(),
            mq3: (latest['mq3'] ?? 0).toDouble(),
            mq135: (latest['mq135'] ?? 0).toDouble(),
            status: latest['status'] ?? 'Layak',
            timestamp: (latest['timestamp'] as Timestamp).toDate(),
          );

          final status = _getStatus(sensor);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(
                    sensor.statusWithEmoji, Color(sensor.statusColor)),
                const SizedBox(height: 16),

                // Informasi keterangan layak dan tidak layak
                _buildStatusExplanation(status),
                const SizedBox(height: 16),

                // DEBUG: tombol seed dummy data untuk testing grafik/status
                if (kDebugMode)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Seed Dummy (Tidak Layak)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () async {
                      await _databaseService.seedDummyData(
                          count: 12, makeBad: true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dummy data seeded')),
                      );
                    },
                  ),

                _buildSensorSummary(sensor),

                const SizedBox(height: 24),
                Text(
                  "Informasi Sensor",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSensorDetails(sensor),

                const SizedBox(height: 24),
                Text(
                  "Grafik Tren Sensor",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // 📊 Grafik dari setiap sensor
                SensorChart(
                  title: "Tren Suhu (°C)",
                  stream: _databaseService.getSensorHistoryStream(),
                  valueGetter: (data) => data.temperature,
                  color: Colors.orangeAccent,
                  chartType: ChartType.bar,
                ),
                SensorChart(
                  title: "Tren Kelembapan (%)",
                  stream: _databaseService.getSensorHistoryStream(),
                  valueGetter: (data) => data.humidity,
                  color: Colors.blueAccent,
                  chartType: ChartType.bar,
                ),
                SensorChart(
                  title: "Tren Gas MQ2",
                  stream: _databaseService.getSensorHistoryStream(),
                  valueGetter: (data) => data.mq2,
                  color: Colors.purpleAccent,
                  chartType: ChartType.bar,
                ),
                SensorChart(
                  title: "Tren Gas MQ3",
                  stream: _databaseService.getSensorHistoryStream(),
                  valueGetter: (data) => data.mq3,
                  color: Colors.teal,
                  chartType: ChartType.bar,
                ),
                SensorChart(
                  title: "Tren Gas MQ135",
                  stream: _databaseService.getSensorHistoryStream(),
                  valueGetter: (data) => data.mq135,
                  color: Colors.pinkAccent,
                  chartType: ChartType.bar,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🟢🟡🔴 Tentukan status daging berdasarkan semua sensor
  String _getStatus(model.SensorData data) {
    // Thresholds untuk Tidak Layak (high risk)
    bool isTidakLayak = data.mq2 > 100 ||
        data.mq3 > 200 ||
        data.mq135 > 200 ||
        data.temperature > 25 ||
        data.humidity > 80;

    // Thresholds untuk Perlu Diperhatikan (medium risk)
    bool isPerluDiperhatikan = data.mq2 > 50 ||
        data.mq3 > 150 ||
        data.mq135 > 100 ||
        data.temperature > 20 ||
        data.humidity > 70;

    if (isTidakLayak) {
      return "Tidak Layak";
    } else if (isPerluDiperhatikan) {
      return "Perlu Diperhatikan";
    } else {
      return "Layak";
    }
  }

  Widget _buildStatusCard(String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 28),
          const SizedBox(width: 12),
          Text(
            "Status Daging: $status",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallMetricPlaceholder(String title, String value, String suffix) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          const SizedBox(height: 6),
          Text('$value $suffix',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red)),
        ]),
      ),
    );
  }

  Widget _buildSensorSummary(model.SensorData data) {
    // Calculate trends (mock for now - in real app compare with previous data)
    TrendDirection getTrend(double current, double threshold) {
      // Simple logic: if current > threshold, trending up (bad), else down (good)
      return current > threshold ? TrendDirection.up : TrendDirection.down;
    }

    final cards = [
      SensorCard(
        title: "MQ2 - Gas Umum",
        value: data.mq2.toStringAsFixed(1),
        unit: "ppm",
        trend: getTrend(data.mq2, 50),
        lastUpdate: data.timestamp,
        onDetailTap: () => _navigateToSensorDetail('MQ2'),
      ),
      SensorCard(
        title: "MQ3 - Alkohol/VOC",
        value: data.mq3.toStringAsFixed(1),
        unit: "ppm",
        trend: getTrend(data.mq3, 150),
        lastUpdate: data.timestamp,
        onDetailTap: () => _navigateToSensorDetail('MQ3'),
      ),
      SensorCard(
        title: "MQ135 - Amonia/CO₂",
        value: data.mq135.toStringAsFixed(1),
        unit: "ppm",
        trend: getTrend(data.mq135, 100),
        lastUpdate: data.timestamp,
        onDetailTap: () => _navigateToSensorDetail('MQ135'),
      ),
      SensorCard(
        title: "DHT11 - Suhu",
        value: data.temperature.toStringAsFixed(1),
        unit: "°C",
        trend: getTrend(data.temperature, 25),
        lastUpdate: data.timestamp,
        onDetailTap: () => _navigateToSensorDetail('Temperature'),
      ),
      SensorCard(
        title: "DHT11 - Kelembapan",
        value: data.humidity.toStringAsFixed(1),
        unit: "%",
        trend: getTrend(data.humidity, 70),
        lastUpdate: data.timestamp,
        onDetailTap: () => _navigateToSensorDetail('Humidity'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }

  void _navigateToSensorDetail(String sensorType) {
    // TODO: Navigate to sensor detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to $sensorType detail')),
    );
  }

  Widget _buildStatusExplanation(String status) {
    String explanation;
    Color color;

    switch (status) {
      case "Layak":
        explanation =
            "Daging dalam kondisi baik dan aman untuk dikonsumsi. Semua parameter sensor berada dalam batas normal.";
        color = Colors.green;
        break;
      case "Perlu Diperhatikan":
        explanation =
            "Daging menunjukkan tanda-tanda awal pembusukan. Periksa kondisi penyimpanan dan segera gunakan.";
        color = Colors.orangeAccent;
        break;
      case "Tidak Layak":
        explanation =
            "Daging tidak aman untuk dikonsumsi. Tingkat gas atau suhu menunjukkan pembusukan yang signifikan.";
        color = Colors.redAccent;
        break;
      default:
        explanation = "Status tidak diketahui.";
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                "Penjelasan Status",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorDetails(model.SensorData data) {
    return Column(
      children: [
        _buildSensorDetailCard(
          "MQ2 - Gas Umum",
          data.mq2,
          "ppm",
          "Mendeteksi gas umum seperti LPG, propana, hidrogen, dan metana. Nilai normal: < 50 ppm",
          data.mq2 > 50 ? "Tinggi - kemungkinan kebocoran gas" : "Normal",
          data.mq2 > 50 ? Colors.redAccent : Colors.green,
        ),
        _buildSensorDetailCard(
          "MQ3 - Alkohol/VOC",
          data.mq3,
          "ppm",
          "Mendeteksi alkohol, benzena, dan senyawa organik volatil. Nilai normal: < 150 ppm",
          data.mq3 > 150 ? "Tinggi - indikasi pembusukan" : "Normal",
          data.mq3 > 150 ? Colors.redAccent : Colors.green,
        ),
        _buildSensorDetailCard(
          "MQ135 - Amonia/CO₂",
          data.mq135,
          "ppm",
          "Mendeteksi amonia dan karbon dioksida dari pembusukan. Nilai normal: < 100 ppm",
          data.mq135 > 100 ? "Tinggi - pembusukan aktif" : "Normal",
          data.mq135 > 100 ? Colors.redAccent : Colors.green,
        ),
        _buildSensorDetailCard(
          "DHT11 - Suhu",
          data.temperature,
          "°C",
          "Mengukur suhu lingkungan penyimpanan. Suhu optimal: 0-4°C untuk pendinginan",
          data.temperature > 25
              ? "Terlalu panas - risiko pembusukan"
              : "Optimal",
          data.temperature > 25 ? Colors.redAccent : Colors.green,
        ),
        _buildSensorDetailCard(
          "DHT11 - Kelembapan",
          data.humidity,
          "%",
          "Mengukur kelembapan udara. Kelembapan optimal: 60-80% untuk penyimpanan",
          data.humidity > 70 ? "Terlalu lembab - risiko jamur" : "Optimal",
          data.humidity > 70 ? Colors.orangeAccent : Colors.green,
        ),
      ],
    );
  }

  Widget _buildSensorDetailCard(String title, double value, String unit,
      String description, String status, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor, width: 1),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "${value.toStringAsFixed(1)} $unit",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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

  // Removed old _buildSensorCard method as it's replaced by SensorCard widget
}
