import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  bool _isRegister = false;
  bool _isLoading = false;
  String _name = '';
  final _emailController = TextEditingController(text: 'pmexn030@gmail.com');
  final _passwordController = TextEditingController(text: 'Abc123456');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    Map<String, dynamic> result;

    if (_isRegister) {
      result = await _apiService.register(
        name: _name,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      result = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }


  void _showServerSettingsDialog() {
    final controller = TextEditingController(text: _apiService.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ตั้งค่าที่อยู่ Server (IP / URL)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สำหรับมือถือจริง ให้ใส่ IP ของคอมพิวเตอร์:\nเช่น http://192.168.1.111:3000/api',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Backend API URL',
                hintText: 'http://192.168.1.111:3000/api',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              _apiService.setBaseUrl(controller.text.trim());
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('บันทึกการตั้งค่า Server เรียบร้อยแล้ว'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon / Logo
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4D2563EB),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'IT Service Desk',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _showServerSettingsDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.storage_rounded, size: 13, color: Color(0xFF10B981)),
                            const SizedBox(width: 5),
                            Text(
                              'MySQL: ${_apiService.baseUrl}',
                              style: const TextStyle(
                                color: Color(0xFF047857),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.edit_rounded, size: 12, color: Color(0xFF10B981)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login / Register Form Card
                  Card(
                    elevation: 1,
                    shadowColor: const Color(0x0A000000),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isRegister ? 'สร้างบัญชีผู้ใช้ใหม่' : 'เข้าสู่ระบบ',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 18),

                            if (_isRegister) ...[
                              TextFormField(
                                initialValue: _name,
                                decoration: const InputDecoration(
                                  labelText: 'ชื่อ - นามสกุล',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? 'กรุณากรอกชื่อ'
                                    : null,
                                onSaved: (val) => _name = val?.trim() ?? '',
                              ),
                              const SizedBox(height: 14),
                            ],

                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'อีเมล (Email)',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => val == null || !val.contains('@')
                                  ? 'กรุณากรอกอีเมลที่ถูกต้อง'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'รหัสผ่าน (Password)',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                              obscureText: true,
                              validator: (val) {
                                if (val == null || val.length < 6) {
                                  return 'รหัสผ่านอย่างน้อย 6 ตัวอักษร';
                                }
                                if (_isRegister &&
                                    !RegExp(r'^(?=.*[a-z])(?=.*[A-Z]).{6,}$')
                                        .hasMatch(val)) {
                                  return 'ต้องมีพิมพ์เล็กและพิมพ์ใหญ่อย่างละ 1 ตัว';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),

                            ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(_isRegister ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ'),
                            ),
                            const SizedBox(height: 12),

                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isRegister = !_isRegister;
                                  if (_isRegister) {
                                    _emailController.text = 'user1@example.com';
                                    _passwordController.text = 'Abc123456';
                                  } else {
                                    _emailController.text = 'pmexn030@gmail.com';
                                    _passwordController.text = 'Abc123456';
                                  }
                                });
                              },
                              child: Text(
                                _isRegister
                                    ? 'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ'
                                    : 'ยังไม่มีบัญชี? สมัครสมาชิกที่นี่',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
