import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/country_codes.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _codeSent = false;
  int _countdown = 0;
  Timer? _timer;
  String? _devCode; // 开发模式下的验证码
  CountryCode _selectedCountry = CountryCodes.defaultCountry; // 选中的国家

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendCode() async {
    // 只验证手机号是否为空
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      print('Debug: 手机号为空'); // 调试日志
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入手机号'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 验证手机号格式
    if (!RegExp(_selectedCountry.phonePattern).hasMatch(phone)) {
      print('Debug: 手机号格式错误'); // 调试日志
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入有效的手机号'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // 发送完整的国际格式手机号
    final fullPhone = '${_selectedCountry.dialCode}$phone';
    print('Debug: 发送验证码到手机号: $fullPhone'); // 调试日志
    
    try {
      final devCode = await authProvider.sendPhoneCode(phone: fullPhone);
      print('Debug: 返回的验证码: $devCode, 错误: ${authProvider.error}'); // 调试日志

      if (authProvider.error == null) {
        setState(() {
          _codeSent = true;
          _devCode = devCode;
        });
        _startCountdown();
        print('Debug: 倒计时已启动，_countdown=$_countdown'); // 调试日志

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                devCode != null 
                  ? '验证码已发送（开发模式）: $devCode'
                  : '验证码已发送，请查收短信',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: devCode != null ? 5 : 3),
            ),
          );
        }
      } else if (mounted) {
        print('Debug: 显示错误提示: ${authProvider.error}'); // 调试日志
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Debug: 发送验证码异常: $e'); // 调试日志
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    // 验证手机号
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入手机号'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!RegExp(_selectedCountry.phonePattern).hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入有效的手机号'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 验证验证码
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入验证码'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入6位验证码'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_codeSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先获取验证码'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 使用完整的国际格式手机号
    final fullPhone = '${_selectedCountry.dialCode}$phone';
    final success = await authProvider.phoneLogin(
      phone: fullPhone,
      code: code,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (authProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手机号登录'),
        backgroundColor: const Color(0xFF6B4EE6),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 手机图标
                  const Icon(
                    Icons.phone_android,
                    size: 80,
                    color: Color(0xFF6B4EE6),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '手机号快捷登录',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '输入手机号，获取验证码登录',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // 手机号输入框（带国家选择器）
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 国家选择器
                      InkWell(
                        onTap: () => _showCountryPicker(),
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedCountry.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedCountry.dialCode,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 手机号输入框
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: _selectedCountry.phoneLength,
                          decoration: const InputDecoration(
                            labelText: '手机号',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                          // 移除validator，发送验证码和登录时手动验证
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 验证码输入框
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            labelText: '验证码',
                            prefixIcon: Icon(Icons.message),
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                          // 移除validator，登录时手动验证
                        ),
                      ),
                      const SizedBox(width: 12),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return SizedBox(
                            width: 120,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: (_countdown > 0 || authProvider.isLoading)
                                  ? null
                                  : _handleSendCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B4EE6),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                _countdown > 0
                                    ? '$_countdown秒'
                                    : '获取验证码',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  if (_devCode != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        border: Border.all(color: Colors.amber),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.developer_mode,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '开发模式验证码: $_devCode',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 登录按钮
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF6B4EE6),
                          foregroundColor: Colors.white,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                '登录',
                                style: TextStyle(fontSize: 16),
                              ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 提示信息
                  Center(
                    child: Text(
                      '首次登录将自动注册账号',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
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

  /// 显示国家选择器
  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const Text(
                '选择国家/地区',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: CountryCodes.popularCountries.length,
                  itemBuilder: (context, index) {
                    final country = CountryCodes.popularCountries[index];
                    final isSelected = country.code == _selectedCountry.code;
                    
                    return ListTile(
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(country.name),
                      trailing: Text(
                        country.dialCode,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? const Color(0xFF6B4EE6) : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: const Color(0xFF6B4EE6).withOpacity(0.1),
                      onTap: () {
                        setState(() {
                          _selectedCountry = country;
                          _phoneController.clear(); // 清空已输入的手机号
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
