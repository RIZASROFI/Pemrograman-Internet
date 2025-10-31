import 'package:flutter/material.dart';
import '../models/sensor_reading.dart';
import '../services/database_service.dart';

class SensorProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<SensorReading> _readings = [];
  bool _isLoading = false;

  List<SensorReading> get readings => _readings;
  bool get isLoading => _isLoading;

  SensorProvider() {
    start();
  }

  void start() {
    _databaseService.getSensorHistoryStream().listen((data) {
      _readings = data.map((sensorData) => SensorReading(
        temperature: sensorData.temperature,
        humidity: sensorData.humidity,
        mq2: sensorData.mq2,
        mq3: sensorData.mq3,
        mq135: sensorData.mq135,
        timestamp: sensorData.timestamp,
      )).toList();
      notifyListeners();
    });
  }

  void stop() {
    // Stop listening if needed
  }

  String mapPredictionToLabel(SensorReading reading) {
    final status = reading.getStatus();
    switch (status) {
      case MeatStatus.LAYAK:
        return 'Layak';
      case MeatStatus.PERLU_DIPERHATIKAN:
        return 'Perlu Diperhatikan';
      case MeatStatus.TIDAK_LAYAK:
        return 'Tidak Layak';
    }
  }

  String exportCsv() {
    final buffer = StringBuffer();
    buffer.writeln('Timestamp,Temperature,Humidity,MQ2,MQ3,MQ135,Status');
    for (final reading in _readings) {
      buffer.writeln('${reading.timestamp.toIso8601String()},${reading.temperature},${reading.humidity},${reading.mq2},${reading.mq3},${reading.mq135},${mapPredictionToLabel(reading)}');
    }
    return buffer.toString();
  }
}
