import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/biometric_auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帳號')),
      body: _LoggedInBody(),
    );
  }
}

// ── Logged-in view ────────────────────────────────────────────────────────────

class _LoggedInBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) return const _SignedOutPlaceholder();
    return _UserView(user: user);
  }
}

class _UserView extends StatefulWidget {
  const _UserView({required this.user});
  final User user;

  @override
  State<_UserView> createState() => _UserViewState();
}

class _UserViewState extends State<_UserView> {
  bool _sending = false;
  bool _deleting = false;
  bool _checkingBiometrics = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
  }

  Future<void> _loadBiometrics() async {
    final service = BiometricAuthService.instance;
    final results = await Future.wait([
      service.isAvailable(),
      service.hasCredentialsFor(widget.user.uid),
    ]);
    if (!mounted) return;
    setState(() {
      _biometricAvailable = results[0];
      _biometricEnabled = results[1] && results[0];
      _checkingBiometrics = false;
    });
  }

  Future<void> _toggleBiometrics(bool enabled) async {
    final service = BiometricAuthService.instance;
    if (enabled) {
      final password = await _requestPassword();
      if (password == null || !mounted) return;
      setState(() => _checkingBiometrics = true);
      try {
        final email = widget.user.email!;
        await widget.user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: email, password: password),
        );
        await service.saveLoginCredentials(
          uid: widget.user.uid,
          email: email,
          password: password,
        );
      } on FirebaseAuthException {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('密碼不正確，無法啟用生物辨識登入'),
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('生物辨識驗證未完成，功能尚未開啟'),
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      } finally {
        if (mounted) setState(() => _checkingBiometrics = false);
      }
    } else {
      await service.clearLoginCredentials(widget.user.uid);
    }
    if (mounted) setState(() => _biometricEnabled = enabled);
  }

  Future<String?> _requestPassword() => showDialog<String>(
        context: context,
        builder: (_) => const _PasswordPromptDialog(
          title: '啟用生物辨識登入',
          message: '請輸入目前密碼，以安全儲存登入憑證。',
          confirmLabel: '繼續',
        ),
      );

  String get _initials {
    final email = widget.user.email ?? '';
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  Future<void> _resetPassword() async {
    final email = widget.user.email;
    if (email == null) return;
    setState(() => _sending = true);
    try {
      await AuthService.instance.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('重設密碼信已寄出，請檢查您的信箱'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('寄送失敗，請稍後再試'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      // IMPORTANT: pop with the dialog's own context, not the screen's.
      // The screen context pops GoRouter's shell navigator (removing the
      // /profile page itself → blank screen) instead of the dialog.
      builder: (dialogContext) => AlertDialog(
        title: const Text('登出'),
        content: const Text('確定要登出帳號嗎？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('登出')),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService.instance.signOut();
      // StreamBuilder in main.dart detects auth=null and swaps to AuthScreen instantly
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final password = await _confirmDeleteAccount();
    if (password == null || !mounted) return;

    setState(() => _deleting = true);
    try {
      await AuthService.instance.deleteAccount(password: password);
      // Deletion signs the user out; the top-level StreamBuilder in main.dart
      // detects auth=null and swaps to AuthScreen — no manual navigation needed.
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AuthService.instance.errorMessage(e)),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('刪除帳號失敗，請稍後再試'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  /// Shows the irreversible-deletion warning plus a password field (required
  /// to reauthenticate before Firebase allows account deletion). Returns the
  /// entered password if the user confirms, or null if they cancel.
  Future<String?> _confirmDeleteAccount() => showDialog<String>(
        context: context,
        builder: (_) => const _PasswordPromptDialog(
          title: '刪除帳號',
          warning: '此操作將永久刪除您的帳號與所有資料，包含訓練計畫、完成記錄與登入資訊，且無法復原。',
          message: '請輸入密碼以確認身分：',
          confirmLabel: '永久刪除',
          destructive: true,
          showVisibilityToggle: true,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final email = widget.user.email ?? '';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Avatar + email ────────────────────────────────────────────────
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: scheme.primaryContainer,
                child: Text(_initials,
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer)),
              ),
              const SizedBox(height: 14),
              Text(email,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('已登入',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSecondaryContainer)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // ── Sync info card ────────────────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.cloud_done_outlined,
                    color: scheme.primary, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('雲端同步已開啟',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('訓練計畫與完成記錄將自動備份至 Firebase',
                          style: TextStyle(
                              fontSize: 13, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Actions ───────────────────────────────────────────────────────
        SwitchListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: scheme.outlineVariant)),
          secondary: const Icon(Icons.fingerprint),
          title: const Text('生物辨識登入與解鎖'),
          subtitle: Text(_biometricAvailable
              ? '登出後也可使用 Face ID、Touch ID 或指紋登入'
              : '此裝置尚未設定可用的生物辨識'),
          value: _biometricEnabled,
          onChanged: _checkingBiometrics || !_biometricAvailable
              ? null
              : _toggleBiometrics,
        ),
        const SizedBox(height: 10),

        ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: scheme.outlineVariant)),
          leading: const Icon(Icons.lock_reset),
          title: const Text('變更密碼'),
          subtitle: const Text('寄送重設密碼信至信箱'),
          trailing: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.chevron_right),
          onTap: _sending ? null : _resetPassword,
        ),
        const SizedBox(height: 10),

        ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: scheme.outlineVariant)),
          leading: Icon(Icons.logout, color: scheme.error),
          title: Text('登出', style: TextStyle(color: scheme.error)),
          onTap: () => _signOut(context),
        ),
        const SizedBox(height: 24),

        // ── Danger zone ──────────────────────────────────────────────────
        Text('危險區域',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: scheme.error)),
        const SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: scheme.error.withAlpha(120))),
          tileColor: scheme.errorContainer.withAlpha(40),
          leading: _deleting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: scheme.error))
              : Icon(Icons.delete_forever, color: scheme.error),
          title: Text('刪除帳號', style: TextStyle(color: scheme.error)),
          subtitle: const Text('永久刪除帳號與所有資料，無法復原'),
          onTap: _deleting ? null : () => _deleteAccount(context),
        ),
        const SizedBox(height: 32),

        // ── Footer ────────────────────────────────────────────────────────
        Text('全方位健身 v1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: scheme.outlineVariant)),
      ],
    );
  }
}

/// Reusable "enter your password" dialog. Owns its TextEditingController via
/// the widget's own State lifecycle (created in initState, disposed in
/// dispose) so it is only ever torn down once the dialog is actually removed
/// from the tree — disposing a controller manually right after showDialog
/// returns races the dialog's exit animation and can crash with "a
/// TextEditingController was used after being disposed".
class _PasswordPromptDialog extends StatefulWidget {
  const _PasswordPromptDialog({
    required this.title,
    required this.confirmLabel,
    this.warning,
    this.message,
    this.destructive = false,
    this.showVisibilityToggle = false,
  });

  final String title;
  final String confirmLabel;
  final String? warning;
  final String? message;
  final bool destructive;
  final bool showVisibilityToggle;

  @override
  State<_PasswordPromptDialog> createState() => _PasswordPromptDialogState();
}

class _PasswordPromptDialogState extends State<_PasswordPromptDialog> {
  late final TextEditingController _controller;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.isNotEmpty) {
      Navigator.pop(context, _controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.warning != null) ...[
              Text(widget.warning!, style: TextStyle(color: scheme.error)),
              const SizedBox(height: 16),
            ],
            if (widget.message != null) ...[
              Text(widget.message!),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _controller,
              obscureText: _obscure,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (value.isNotEmpty) Navigator.pop(context, value);
              },
              decoration: InputDecoration(
                labelText: '密碼',
                prefixIcon: const Icon(Icons.lock_outlined),
                border: const OutlineInputBorder(),
                suffixIcon: widget.showVisibilityToggle
                    ? IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          style: widget.destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _SignedOutPlaceholder extends StatelessWidget {
  const _SignedOutPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_off_outlined, size: 48),
          SizedBox(height: 12),
          Text('尚未登入'),
        ],
      ),
    );
  }
}
