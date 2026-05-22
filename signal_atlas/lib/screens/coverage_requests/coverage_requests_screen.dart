import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/coverage_requests_provider.dart';
import '../../widgets/page_wrapper.dart';
import 'coverage_request_details_page.dart';
import 'widgets/coverage_request_card.dart';

class CoverageRequestsPage extends StatefulWidget {
  const CoverageRequestsPage({super.key});

  @override
  State<CoverageRequestsPage> createState() => _CoverageRequestsPageState();
}

class _CoverageRequestsPageState extends State<CoverageRequestsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Set<String> selectedFilters = {};
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CoverageRequestsProvider>().loadRequests();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 300),
          () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;


    final provider = context.watch<CoverageRequestsProvider>();

    final filteredRequests = provider.getFilteredRequests(
      _searchController.text,
      selectedFilters,
    );

    return PageWrapper(
      title: "Coverage Requests",
      scrollable: false,
      expandable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------
          // Search Bar
          // ------------------------------------------------

          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,

            onTapOutside: (_) {
              _searchFocusNode.unfocus();
            },

            onChanged: _onSearchChanged,
            style: textTheme.bodyLarge,

            decoration: InputDecoration(
              hintText: "Search coverage requests...",
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colorScheme.primary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
                  : null,
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------
          // Filters
          // ------------------------------------------------

          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.filters.length,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = provider.filters[index];

                final isSelected =
                selectedFilters.contains(filter);

                return FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedFilters.add(filter);
                      } else {
                        selectedFilters.remove(filter);
                      }
                    });
                  },
                  selectedColor: colorScheme.primary.withAlpha(30),
                  backgroundColor: colorScheme.surface,
                  checkmarkColor: colorScheme.primary,
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withAlpha(50),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------
          // Requests List
          // ------------------------------------------------

          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.loadRequests,

              child: provider.requests == null
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 400,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  )

                  : filteredRequests.isEmpty
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 400,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 54,
                                color: colorScheme.outline,
                              ),

                              const SizedBox(height: 12),

                              Text(
                                "No requests found",
                                style: textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )

                  : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),

                    itemCount: filteredRequests.length,

                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),

                    itemBuilder: (context, index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoverageRequestDetailsPage(
                                requestId: filteredRequests[index].id,
                              ),
                            ),
                          );
                        },

                        child: CoverageRequestCard(
                          request: filteredRequests[index],
                        ),
                      );
                    },
                  ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      )
    );
  }
}
