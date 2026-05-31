import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signal_atlas/screens/profile/widgets/create_account_view.dart';

import '../../providers/profile_provider.dart';
import '../../utilities/theme/app_colors.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/page_wrapper.dart';
import '../../widgets/shimmer_box.dart';
import '../../widgets/table.dart';
import 'widgets/withdraw_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditingUsername = false;
  late final TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();

    final profile = context.read<ProfileProvider>();

    _usernameController = TextEditingController(
      text: profile.username,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profile = context.watch<ProfileProvider>();

    final username = profile.username;
    final credits = profile.credits;
    final devices = profile.devices;
    final transactions = profile.transactions;
    final isUpdating = profile.isUpdatingUsername;

    if (profile.hasAccount == false) {
      return const CreateAccountView();
    }

    return PageWrapper(
      title: "Profile",
      onRefresh: profile.loadProfile,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ------------------------------------------------
            // Account Details
            // ------------------------------------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _isEditingUsername
                              ? TextField(
                            controller: _usernameController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                            ),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : username != null
                                ? Text(
                                  username,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                )
                                : shimmerBox(context, height: 20, width: 140),
                        ),

                        const SizedBox(width: 8),

                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: isUpdating
                              ? null
                              : () {
                            if (_isEditingUsername) {
                              context.read<ProfileProvider>().updateUsername(
                                _usernameController.text,
                              );

                              setState(() {
                                _isEditingUsername = false;
                              });
                            } else {
                              setState(() {
                                _isEditingUsername = true;
                              });

                              // re-sync field with current value every time you enter edit mode
                              _usernameController.text = profile.username ?? "";
                              _usernameController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _usernameController.text.length),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: isUpdating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(
                              _isEditingUsername
                                  ? Icons.check_rounded
                                  : Icons.mode_edit_outline_outlined,
                              size: 20,
                              color: _isEditingUsername
                                  ? AppColors.green
                                  : colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ------------------------------------------------
                    // Credits
                    // ------------------------------------------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Available Credits",
                            style: theme.textTheme.bodyMedium,
                          ),

                          const SizedBox(height: 6),

                          credits != null
                            ? Text(
                              credits.toStringAsFixed(2),
                              style:
                              theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            )
                            : shimmerBox(context, height: 40, width: 120),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child:
                              OutlinedButton.icon(
                                onPressed: !profile.isLoadingCredit
                                    ? () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => WithdrawDialog(
                                      availableCredits: credits ?? 0,
                                    ),
                                  );
                                } : null,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: colorScheme.primary,
                                  ),
                                ),
                                icon: const Icon(Icons.download),
                                label: const Text("Withdraw"),
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------
            // Transactions
            // ------------------------------------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long,
                            color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Last 5 Transactions",
                          style:
                          theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (transactions == null)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      )
                    else
                      ...transactions!.map((tx) {
                      final amount = (tx["amount"] as num).toDouble();
                      final isPositive = amount >= 0;

                      return Container(
                        margin:
                        const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme
                              .surfaceContainerHighest
                              .withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 18,
                              color: isPositive
                                  ? AppColors.green
                                  : colorScheme.error,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tx["title"] as String,
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    tx["date"] as String,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              "${isPositive ? "+" : ""}${amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPositive
                                    ? AppColors.green
                                    : colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------
            // Devices
            // ------------------------------------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // ------------------------------------------------
                    // Header
                    // ------------------------------------------------
                    Row(
                      children: [
                        Icon(Icons.devices_outlined, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Devices",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // Table
                    // ------------------------------------------------

                    devices == null
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          )
                        : AppTable<Map<String, dynamic>>(
                          items: devices!,
                          scrollable: false,
                          columns: [
                            // Device ID
                            TableColumn<Map<String, dynamic>>(
                              title: "Device ID",
                              flex: 4,
                              align: TextAlign.left,
                              valueBuilder: (d) => d["id"],
                            ),

                            // Samples
                            TableColumn<Map<String, dynamic>>(
                              title: "Samples",
                              flex: 2,
                              align: TextAlign.center,
                              valueBuilder: (d) => "${d["samples"]}",
                            ),

                            // Action column (delete)
                            TableColumn<Map<String, dynamic>>(
                              title: "",
                              flex: 1,
                              widgetBuilder: (d) => Center(
                                child: InkWell(
                                  onTap: () {
                                    _showDeleteDialog(context);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: colorScheme.error.withAlpha(180),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Data"),
        content: const Text(
          "Are you sure you want to delete all of this device's data on the server? Coverage request sessions will be kept. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // context.read<ProfileProvider>().deleteDevice(d["id"]);

              showCustomSnackBar(context, "Data deleted");
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

}
