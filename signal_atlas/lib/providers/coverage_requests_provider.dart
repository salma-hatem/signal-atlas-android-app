import 'package:flutter/material.dart';

import '../models/coverage_request.dart';
import '../models/coverage_request_detailed.dart';
import '../services/coverage_requests_service.dart';

class CoverageRequestsProvider extends ChangeNotifier {
  final CoverageRequestsService _service = CoverageRequestsService();

  // ------------------------------------------------
  // Requests List
  // ------------------------------------------------

  List<CoverageRequest>? _requests;

  List<CoverageRequest>? get requests => _requests;

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
  // Load Requests
  // ------------------------------------------------

  Future<void> loadRequests() async {

    _requests = await _service.fetchRequests();
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
    final requests = _requests ?? [];

    final lowerQuery = query.toLowerCase();

    return requests.where((request) {
      final matchesSearch = request.title
          .toLowerCase()
          .contains(lowerQuery);

      final matchesFilters = filters.isEmpty
          ? true
          : filters.every((filter) {
        switch (filter) {
          case "Open":
            return request.status == "Open";

          case "Completed":
            return request.status == "Completed";

          case "Cancelled":
            return request.status == "Cancelled";

          case "Nearby":
            return true;

          default:
            return true;
        }
      });

      return matchesSearch && matchesFilters;
    }).toList();
  }
}
