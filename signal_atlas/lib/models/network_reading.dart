/* Network Readings file
This contains the class that represents all network readings from android API

Variables:
Device Infomration: Device ID, Location (Latitude, Longitude, Altitude), Timestamp, Country, City
Signal Strength: ASU Level, Level, RSRP, RSRQ, RSSI
Network Information: Network Type, Operator Name, Physical Cell ID, Tracking Area Code

*/
import 'package:signal_atlas/utilities/signal_thresholds.dart';

class NetworkReading {
  // Metadata
  final String deviceId;
  final DateTime timestamp;

  // Location
  final double latitude;
  final double longitude;
  final double altitude;
  final String? city;
  final String? country;
  final double? gpsAccuracy;
  final String? indoorOutdoor;

  // Network KPIs
  final int asu;
  final int level;
  final int rsrp;
  final int rsrq;
  final int rssi;

  // Network Information
  final String networkType;
  final String operatorName;
  final int physicalCellId;
  final int cellId;
  final int trackingAreaCode;
  final int mcc;
  final int mnc;

  NetworkReading({
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.city,
    required this.country,
    required this.gpsAccuracy,
    required this.indoorOutdoor,
    required this.timestamp,
    required this.level,
    required this.rsrp,
    required this.asu,
    required this.rssi,
    required this.rsrq,
    required this.networkType,
    required this.operatorName,
    required this.physicalCellId,
    required this.cellId,
    required this.trackingAreaCode,
    required this.mcc,
    required this.mnc,
  });

  String get latitudeFormatted => decimalToDegrees(latitude);
  String get longitudeFormatted => decimalToDegrees(longitude);
  String get altitudeFormatted => altitude.toStringAsFixed(1);
  int get overallStrength => SignalThresholds.rsrpStrengthLevel(rsrp);


  static String decimalToDegrees(double decimal) {
    int degrees = decimal.truncate();
    int minutes = ((decimal - degrees) * 60).floor();
    int seconds = (((decimal - degrees) * 60 - minutes) * 60).floor();
    return "$degrees° $minutes' $seconds''";
  }


  // Factory Constructor: creates new object using
  // parsed raw platform data after apply filtering
  factory NetworkReading.fromRaw(Map<String, dynamic> raw) {
    // Helper to safely parse numeric values
    T parseValue<T extends num>(dynamic value, {T? min, T? max, T? defaultValue}) {
      if (value == null) return defaultValue as T;
      num? parsed;
      if (value is num) {
        parsed = value;
      } else if (value is String) {
        parsed = T == int ? int.tryParse(value) : double.tryParse(value);
      }
      if (parsed == null) return defaultValue as T;
      if ((min != null && parsed < min) || (max != null && parsed > max)) return defaultValue as T;
      return (T == int ? parsed.toInt() : parsed.toDouble()) as T;
    }
    final rsrpRange = SignalThresholds.kpiRanges['RSRP']!;
    final rsrqRange = SignalThresholds.kpiRanges['RSRQ']!;
    final asuRange = SignalThresholds.kpiRanges['ASU']!;
    final rssiRange = SignalThresholds.kpiRanges['RSSI']!;

    return NetworkReading(
      deviceId: raw['ID']?.toString() ?? 'Unknown',
      latitude: parseValue<double>(raw['Latitude'], defaultValue: 0.0),
      longitude: parseValue<double>(raw['Longitude'], defaultValue: 0.0),
      altitude: parseValue<double>(raw['Altitude'], defaultValue: 0.0),
      city: raw['city']?.toString(),
      country: raw['country']?.toString(),
      gpsAccuracy: raw['Accuracy'],
      indoorOutdoor: raw['IndoorOutdoor']?.toString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          raw['Timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      level: parseValue<int>(raw['Level'], defaultValue: 0),
      rsrp: parseValue<int>(
          raw['RSRP'],
          min: rsrpRange.min,
          max: rsrpRange.max,
          defaultValue: 0,
      ),
      asu: parseValue<int>(
          raw['ASU Level'],
          min: asuRange.min,
          max: asuRange.max,
          defaultValue: 0
      ),
      rssi: parseValue<int>(
          raw['RSSI'],
          min: rssiRange.min,
          max: rssiRange.max,
          defaultValue: 0
      ),
      rsrq: parseValue<int>(
          raw['RSRQ'],
          min: rsrqRange.min,
          max: rsrqRange.max,
          defaultValue: 0
      ),
      networkType: raw['NetworkType']?.toString() ?? '-',
      operatorName: raw['Operator']?.toString() ?? '-',
      physicalCellId: parseValue<int>(raw['PCI'], defaultValue: 0),
      cellId: parseValue<int>(raw['Cell ID'], defaultValue: 0),
      trackingAreaCode: parseValue<int>(raw['TAC'], defaultValue: 0),
      mcc: parseValue<int>(raw['MCC'], defaultValue: 0),
      mnc: parseValue<int>(raw['MNC'], defaultValue: 0),
    );
  }

  // Format for API payload
  Map<String, dynamic> toApiPayload() {
    return {
      'source': deviceId,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'country': country,
      'city': city,
      'gpsAccuracy': gpsAccuracy,
      'level': level,
      'asu': asu,
      'rsrp': rsrp,
      'rssi': rssi,
      'rsrq': rsrq,
      'networkType': networkType,
      'operator': operatorName,
      'cellId': cellId.toString(),
      'physicalCellId': physicalCellId,
      'trackingAreaCode': trackingAreaCode,
    };
  }

}
