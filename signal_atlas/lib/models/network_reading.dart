/* Network Readings file
This contains the class that represents all network readings from android API

Variables:
Device Infomration: Device ID, Location (Latitude, Longitude, Altitude), Timestamp, Country, City
Signal Strength: ASU Level, Level, RSRP, RSRQ, RSSI
Network Information: Network Type, Operator Name, Physical Cell ID, Tracking Area Code

*/

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
  final int trackingAreaCode;

  NetworkReading({
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.city,
    required this.country,
    required this.timestamp,
    required this.level,
    required this.rsrp,
    required this.asu,
    required this.rssi,
    required this.rsrq,
    required this.networkType,
    required this.operatorName,
    required this.physicalCellId,
    required this.trackingAreaCode,
  });

  String get latitudeFormatted => decimalToDegrees(latitude);
  String get longitudeFormatted => decimalToDegrees(longitude);
  String get altitudeFormatted => altitude.toStringAsFixed(1);
  int get overallStrength => getSignalQuality(rsrp);


  static String decimalToDegrees(double decimal) {
    int degrees = decimal.floor();
    int minutes = ((decimal - degrees) * 60).floor();
    int seconds = (((decimal - degrees) * 60 - minutes) * 60).floor();
    return "$degrees° $minutes' $seconds''";
  }

  int getSignalQuality(int rsrp) {
    if (rsrp >= -85) return 4;
    if (rsrp >= -95) return 3;
    if (rsrp >= -105) return 2;
    if (rsrp >= -120) return 1;
    return 0;
  }

}
