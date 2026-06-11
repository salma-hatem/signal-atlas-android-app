class DeviceModel {
  final String id;

  int? samples;
  bool isLoadingSamples;
  bool isDeleting;

  DeviceModel({
    required this.id,
    this.samples,
    this.isLoadingSamples = false,
    this.isDeleting = false,
  });
}
