import 'package:flutter/material.dart';

import '../models/coverage_request.dart';
import '../models/coverage_request_detailed.dart';
import '../services/coverage_requests_service.dart';
import 'logging_provider.dart';

class CoverageRequestsProvider extends ChangeNotifier {
  final CoverageRequestsService _service = CoverageRequestsService();

  // ------------------------------------------------
  // Requests List
  // ------------------------------------------------

  List<CoverageRequest>? _requests;

  List<CoverageRequest>? get requests => _requests;

  List<CoverageRequest>? _nearbyRequests;

  List<CoverageRequest>? get nearbyRequests => _nearbyRequests;

  // ------------------------------------------------
  // CONTRIBUTION STATE
  // ------------------------------------------------

  double? _userContribution;
  double? get userContribution => _userContribution;

  bool _isContributionLoading = false;
  bool get isContributionLoading => _isContributionLoading;

  // ------------------------------------------------
  // Filters
  // ------------------------------------------------

  final List<String> filters = [
    "Open",
    "Completed",
    "Cancelled",
    "Nearby",
  ];

  // ------------------------------------------------
  // Active Requests
  // ------------------------------------------------

  int? _activeRequestId;
  int? get activeRequestId => _activeRequestId;

  bool get isAnyRequestLogging => _activeRequestId != null;

  void setActiveRequest(int? requestId) {
    _activeRequestId = requestId;
    notifyListeners();
  }

  // ------------------------------------------------
  // Toggle Logging
  // ------------------------------------------------

  Future<void> toggleRequestLogging({
    required int requestId,
    required String requestTitle,
    required LoggingProvider loggingProvider,
  }) async {
    final isThisActive = _activeRequestId == requestId;

    final isGlobalLogging = loggingProvider.isLogging;

    // already logging THIS request -> stop
    if (isThisActive && isGlobalLogging) {
      await loggingProvider.toggleLogging(
        requestId: requestId,
        requestTitle: requestTitle,
      );
      _activeRequestId = null;
      notifyListeners();
      return;
    }

    // some other logging active -> block
    if (isGlobalLogging && !isThisActive) {
      return;
    }

    // start logging for this request
    await loggingProvider.toggleLogging(
      requestId: requestId,
      requestTitle: requestTitle,
    );
    _activeRequestId = requestId;

    notifyListeners();
  }

  // ------------------------------------------------
  // Load Requests
  // ------------------------------------------------

  Future<void> loadRequests() async {

    _requests = await _service.fetchRequests();
    notifyListeners();
  }

  // ------------------------------------------------
  // Load Nearby Requests
  // ------------------------------------------------

  Future<void> loadNearbyRequests({
    required double latitude,
    required double longitude,

    double radiusKm = 10,
  }) async {

    // prevent unnecessary API calls
    if (_nearbyRequests != null &&
        _nearbyRequests!.isNotEmpty) {
      return;
    }

    _nearbyRequests =
    await _service.fetchNearbyRequests(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );

    notifyListeners();
  }

  void clearNearbyRequests() {
    _nearbyRequests = null;
    notifyListeners();
  }

  // ------------------------------------------------
  // Load Details
  // ------------------------------------------------

  Future<CoverageRequestDetail> fetchRequestDetails(int id) {
    return _service.fetchRequestDetails(id);
  }

  // ------------------------------------------------
  // Get User Contribution
  // ------------------------------------------------

  Future<void> loadUserContribution(int id) async {
    _isContributionLoading = true;

    notifyListeners();

    try {
      _userContribution =
      await _service.fetchUserContribution(id);
    } finally {
      _isContributionLoading = false;

      notifyListeners();
    }
  }

  // ------------------------------------------------
  // Filtering
  // ------------------------------------------------

  List<CoverageRequest> getFilteredRequests(
      String query,
      Set<String> filters,
      ) {

    final useNearby = filters.contains("Nearby");

    final requests = useNearby
        ? (_nearbyRequests ?? [])
        : (_requests ?? []);

    final lowerQuery = query.toLowerCase();

    return requests.where((request) {

      final matchesSearch = request.title
          .toLowerCase()
          .contains(lowerQuery);

      final matchesFilters = filters
          .where((f) => f != "Nearby")
          .every((filter) {

        switch (filter) {
          case "Open":
            return request.status == "OPEN";

          case "Completed":
            return request.status == "COMPLETED";

          case "Cancelled":
            return request.status == "CANCELLED";

          default:
            return true;
        }
      });

      return matchesSearch && matchesFilters;

    }).toList();
  }

  // ------------------------------------------------
  // Sorting (to move active request to the top)
  // ------------------------------------------------

  List<CoverageRequest> getSortedRequests(
      String query,
      Set<String> filters,
      int? activeRequestId,
      ) {
    final list = getFilteredRequests(query, filters);

    list.sort((a, b) {
      if (activeRequestId == null) return 0;

      if (a.id == activeRequestId) return -1;
      if (b.id == activeRequestId) return 1;

      return 0;
    });

    return list;
  }
}
