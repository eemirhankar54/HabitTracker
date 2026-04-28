// lib/screens/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(children: [
            const SizedBox(height: 60),
            _buildHeader(),
            const SizedBox(height: 48),
            _buildTabBar(),
            const SizedBox(height: 32),
            SizedBox(
              height: 440,
              child: TabBarView(
                controller: _tab,
                children: const [_LoginForm(), _RegisterForm()],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() => Column(children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 20),
        const Text(AppStrings.appName,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5)),
        const SizedBox(height: 8),
        const Text(AppStrings.appTagline,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      ]);

  Widget _buildTabBar() => Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tab,
          indicator: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: AppStrings.login),
            Tab(text: AppStrings.register)
          ],
        ),
      );
}

// ── Login ─────────────────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  const _LoginForm();
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();

    // DEBUG — backend cevabını görmek için
    print('Login deneniyor: ${_email.text.trim()}');

    final err = await auth.login(
      email: _email.text.trim(),
      password: _password.text,
    );

    print('Login sonucu: $err');
    print('isLoggedIn: ${auth.isLoggedIn}');

    if (err != null && mounted) _showError(err);
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.accent),
      );

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Form(
      key: _form,
      child: Column(children: [
        _Field(
            ctrl: _email,
            label: AppStrings.email,
            hint: 'ornek@mail.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return AppStrings.emailEmpty;
              if (!v.contains('@')) return AppStrings.emailInvalid;
              return null;
            }),
        const SizedBox(height: 16),
        _Field(
            ctrl: _password,
            label: AppStrings.password,
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscure: _obscure,
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return AppStrings.passwordShort;
              return null;
            }),
        const SizedBox(height: 32),
        _GradientButton(
            label: AppStrings.login, loading: loading, onTap: _submit),
      ]),
    );
  }
}

// ── Register ──────────────────────────────────────────────────

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final err = await auth.register(
      email: _email.text.trim(),
      username: _username.text.trim(),
      password: _password.text,
    );
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.accent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Form(
      key: _form,
      child: Column(children: [
        _Field(
            ctrl: _email,
            label: AppStrings.email,
            hint: 'ornek@mail.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return AppStrings.emailEmpty;
              if (!v.contains('@')) return AppStrings.emailInvalid;
              return null;
            }),
        const SizedBox(height: 12),
        _Field(
            ctrl: _username,
            label: AppStrings.username,
            hint: 'kullanici_adi',
            icon: Icons.person_outline,
            validator: (v) {
              if (v == null || v.isEmpty) return AppStrings.usernameEmpty;
              if (v.length < 3) return AppStrings.usernameShort;
              return null;
            }),
        const SizedBox(height: 12),
        _Field(
            ctrl: _password,
            label: AppStrings.password,
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscure: _obscure,
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) {
              if (v == null || v.length < 6) return AppStrings.passwordShort;
              return null;
            }),
        const SizedBox(height: 12),
        _Field(
            ctrl: _confirm,
            label: AppStrings.confirmPw,
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscure: true,
            validator: (v) {
              if (v != _password.text) return AppStrings.passwordMismatch;
              return null;
            }),
        const SizedBox(height: 24),
        _GradientButton(
            label: AppStrings.createAccount, loading: loading, onTap: _submit),
      ]),
    );
  }
}

// ── Ortak Widgetlar ───────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          suffixIcon: suffix,
          filled: true,
          fillColor: AppColors.surface,
          errorStyle: const TextStyle(color: AppColors.accent, fontSize: 11),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.surfaceVar),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _GradientButton(
      {required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: loading ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
          ),
        ),
      );
}
