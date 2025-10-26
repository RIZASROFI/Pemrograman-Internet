import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_data.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream data sensor terkini
  Stream<SensorData> getLatestSensorStream() {
    return _firestore
        .collection('sensor_data')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      // if there are no documents yet, return a default SensorData
      if (snapshot.docs.isEmpty) {
        return SensorData(
          mq2: 0,
          mq3: 0,
          mq135: 0,
          temperature: 0,
          humidity: 0,
          status: 'TIDAK LAYAK',
          timestamp: DateTime.now(),
        );
      }

      final doc = snapshot.docs.first;
      return SensorData.fromFirestore(doc);
    });
  }

  /// Stream data historis untuk grafik tren
  Stream<List<SensorData>> getSensorHistoryStream() {
    return _firestore
        .collection('sensor_data')
        .orderBy('timestamp', descending: false)
        .limit(100)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SensorData.fromFirestore(doc)).toList());
  }

  /// Debug helper: seed dummy data into `sensor_data` collection.
  /// If makeBad=true, values will be high to produce status 'Tidak Layak'.
  Future<void> seedDummyData({int count = 12, bool makeBad = false}) async {
    final batch = _firestore.batch();
    final now = DateTime.now();
    final col = _firestore.collection('sensor_data');

    for (int i = 0; i < count; i++) {
      final ts = now.subtract(Duration(minutes: count - i));
      final docRef = col.doc();

      // generate values; if makeBad then set mq135 very high or temperature high
      final mq135 = makeBad ? 250 + i.toDouble() : (50 + i.toDouble());
      final temperature = makeBad ? 30.0 + i % 5 : 20.0 + (i % 5);

      batch.set(docRef, {
        'mq2': 5.0 + i.toDouble(),
        'mq3': 2.0 + i.toDouble(),
        'mq135': mq135,
        'temperature': temperature,
        'humidity': 60.0 + (i % 5),
        'timestamp': Timestamp.fromDate(ts),
      });
    }

    await batch.commit();
  }
}
