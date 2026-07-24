import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _error;

  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      if (_isLogin) {
        await AuthService.instance.signIn(
            _emailCtrl.text.trim(), _passCtrl.text);
      } else {
        await AuthService.instance.signUp(
            _emailCtrl.text.trim(), _passCtrl.text);
      }
      // GoRouter redirect listens to auth state — navigation happens automatically
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthService.instance.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = '請先輸入 Email 再重設密碼');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.instance.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('重設密碼信已寄出，請檢查您的信箱'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthService.instance.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo ─────────────────────────────────────────────────
                  const Text('🏋️', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 10),
                  Text('全方位健身',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('登入後可跨裝置同步訓練計畫',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 32),

                  // ── Mode toggle ───────────────────────────────────────────
                  _ModeToggle(
                    isLogin: _isLogin,
                    onChanged: (v) => setState(() {
                      _isLogin = v;
                      _error = null;
                    }),
                  ),
                  const SizedBox(height: 24),

                  // ── Form ──────────────────────────────────────────────────
                  Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return '請輸入 Email';
                              if (!v.contains('@')) return 'Email 格式不正確';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            textInputAction: _isLogin
                                ? TextInputAction.done
                                : TextInputAction.next,
                            onFieldSubmitted: _isLogin ? (_) => _submit() : null,
                            decoration: InputDecoration(
                              labelText: '密碼',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return '請輸入密碼';
                              if (!_isLogin && v.length < 6) return '密碼至少需要 6 個字元';
                              return null;
                            },
                          ),

                          // Confirm password (register only)
                          if (!_isLogin) ...[
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirmCtrl,
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: '確認密碼',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                  onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                              validator: (v) {
                                if (v != _passCtrl.text) return '兩次密碼不相符';
                                return null;
                              },
                            ),
                          ],

                          // Error message
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: scheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 18, color: scheme.onErrorContainer),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(_error!,
                                        style: TextStyle(
                                            color: scheme.onErrorContainer)),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Submit button
                          FilledButton(
                            onPressed: _loading ? null : _submit,
                            style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14)),
                            child: _loading
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : Text(_isLogin ? '登入' : '建立帳號',
                                    style: const TextStyle(fontSize: 16)),
                          ),

                          // Forgot password
                          if (_isLogin) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loading ? null : _forgotPassword,
                              child: const Text('忘記密碼？'),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mode toggle ───────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.isLogin, required this.onChanged});
  final bool isLogin;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Chip(label: '登入', active: isLogin,
              onTap: () => onChanged(true)),
          _Chip(label: '建立帳號', active: !isLogin,
              onTap: () => onChanged(false)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
