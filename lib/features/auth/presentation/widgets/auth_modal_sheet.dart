import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/features/auth/presentation/cubit/auth_cubit.dart';

/// Menampilkan dialog penawaran Daftar / Login terlebih dahulu, lalu
/// mengarahkan pengguna ke halaman penuh (RegisterPage atau LoginPage).
/// Mengembalikan `true` jika pengguna berhasil masuk/daftar.
Future<bool> showAuthRequiredSheet(
  BuildContext context, {
  String subtitle =
      'Masuk atau daftar sekali saja agar riwayat scan dan progres kulitmu tersimpan otomatis.',
}) async {
  final authCubit = context.read<AuthCubit>();
  if (authCubit.state.isLoggedIn) return true;

  // Langkah 1: Interaksi sistem menawarkan pilihan Daftar atau Login
  final choice = await showDialog<_AuthChoice>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppTheme.coralSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_person_rounded,
              color: AppTheme.coral,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Simpan Progres Kulitmu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.slate,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  Navigator.of(dialogCtx).pop(_AuthChoice.register),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Daftar Akun Baru'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(_AuthChoice.login),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: AppTheme.navy),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Sudah Punya Akun? Masuk',
                style: TextStyle(
                  color: AppTheme.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(null),
            child: const Text(
              'Nanti Saja',
              style: TextStyle(
                color: AppTheme.slate,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  if (choice == null || !context.mounted) return false;

  // Langkah 2: Navigasi ke halaman penuh sesuai pilihan user
  final Widget targetPage = choice == _AuthChoice.register
      ? RegisterPage(subtitle: subtitle)
      : LoginPage(subtitle: subtitle);

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: authCubit,
        child: targetPage,
      ),
    ),
  );

  return result == true;
}

enum _AuthChoice { login, register }

// ============================================================================
// HALAMAN LOGIN (FULL PAGE)
// ============================================================================
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.subtitle = 'Masuk ke akun SkinSense untuk mengakses riwayat scan.',
  });

  final String subtitle;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<AuthCubit>();
    final ok = await cubit.login(
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _goToRegister() {
    final authCubit = context.read<AuthCubit>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: authCubit,
          child: RegisterPage(subtitle: widget.subtitle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.navy),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Masuk Akun',
          style: TextStyle(
            color: AppTheme.navy,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.coralSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.login_rounded,
                    color: AppTheme.coral,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selamat Datang Kembali',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.slate,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'nama@email.com',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!v.contains('@')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi',
                    hintText: 'Minimal 6 karakter',
                    prefixIcon:
                        const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: authState.loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: authState.loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.login_rounded, size: 20),
                        label: const Text('Masuk & Lanjutkan'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(fontSize: 13, color: AppTheme.slate),
                    ),
                    GestureDetector(
                      onTap: _goToRegister,
                      child: const Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.coral,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HALAMAN DAFTAR / REGISTER (FULL PAGE)
// ============================================================================
class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    this.subtitle =
        'Daftar sekali saja agar riwayat scan dan progres kulitmu tersimpan.',
  });

  final String subtitle;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<AuthCubit>();
    final ok = await cubit.register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _goToLogin() {
    final authCubit = context.read<AuthCubit>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: authCubit,
          child: LoginPage(subtitle: widget.subtitle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.navy),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Daftar Akun Baru',
          style: TextStyle(
            color: AppTheme.navy,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.coralSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: AppTheme.coral,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Buat Akun SkinSense',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.slate,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    hintText: 'Contoh: Alya Putri',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'nama@email.com',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!v.contains('@')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi',
                    hintText: 'Minimal 6 karakter',
                    prefixIcon:
                        const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: authState.loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: authState.loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline_rounded,
                                size: 20),
                        label: const Text('Daftar & Simpan Riwayat'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(fontSize: 13, color: AppTheme.slate),
                    ),
                    GestureDetector(
                      onTap: _goToLogin,
                      child: const Text(
                        'Masuk di sini',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.coral,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
