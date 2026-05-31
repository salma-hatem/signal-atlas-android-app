import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/profile_provider.dart';
import '../../../utilities/constants.dart';

class CreateAccountView extends StatefulWidget {
  const CreateAccountView({super.key});

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  AuthMode _mode = AuthMode.create;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    usernameController.addListener(_onChanged);
    passwordController.addListener(_onChanged);
  }

  void _onChanged() {
    context.read<ProfileProvider>().clearCreateAccountError();

    setState(() {});
  }

  @override
  void dispose() {
    usernameController.removeListener(_onChanged);
    passwordController.removeListener(_onChanged);

    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      usernameController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty;

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _unfocus,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Person Icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withAlpha(76),
                    ),
                  ),
                  child: Icon(
                    _mode == AuthMode.create ? Icons.person_add_alt_1 : Icons.person,
                    size: 44,
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  _mode == AuthMode.create
                      ? "Create Account"
                      : "Register Device",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _mode == AuthMode.create
                          ? "Already have an account?"
                          : "Need a new account?",
                      style: TextStyle(
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 6),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _mode = _mode == AuthMode.create
                              ? AuthMode.attach
                              : AuthMode.create;
                        });
                      },
                      child: Text(
                        _mode == AuthMode.create
                            ? "Register device"
                            : "Create account",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Username
                TextField(
                  controller: usernameController,
                  enabled: !profile.isCreatingAccount,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: colorScheme.primary,
                    ),
                    filled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Password
                TextField(
                  controller: passwordController,
                  enabled: !profile.isCreatingAccount,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: colorScheme.primary,
                    ),
                    filled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: colorScheme.outline,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (profile.createAccountError != null) ...[
                  Text(
                    profile.createAccountError!,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (!_isFormValid || profile.isCreatingAccount)
                        ? null
                        : () {
                      _unfocus();

                      if (_mode == AuthMode.create) {
                        context.read<ProfileProvider>().createAccount(
                          username: usernameController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                      } else {
                        context.read<ProfileProvider>().attachDeviceToAccount(
                          username: usernameController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                      }
                    },
                    child: profile.isCreatingAccount
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _mode == AuthMode.create
                                  ? "Creating Account"
                                  : "Register Device",
                            )
                          ],
                        )
                            : Text(
                          _mode == AuthMode.create
                              ? "Create Account"
                              : "Register Device",
                        ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
