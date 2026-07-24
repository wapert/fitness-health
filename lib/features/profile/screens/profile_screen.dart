import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

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
      builder: (_) => AlertDialog(
        title: const Text('登出'),
        content: const Text('確定要登出帳號嗎？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('登出')),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService.instance.signOut();
      // GoRouter auth redirect handles navigation back to /login
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme  = Theme.of(context).colorScheme;
    final email   = widget.user.email ?? '';

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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                              fontSize: 13,
                              color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Actions ───────────────────────────────────────────────────────
        ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: scheme.outlineVariant)),
          leading: const Icon(Icons.lock_reset),
          title: const Text('變更密碼'),
          subtitle: const Text('寄送重設密碼信至信箱'),
          trailing: _sending
              ? const SizedBox(
                  width: 18, height: 18,
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
        const SizedBox(height: 32),

        // ── Footer ────────────────────────────────────────────────────────
        Text('全方位健身 v1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: scheme.outlineVariant)),
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

}
