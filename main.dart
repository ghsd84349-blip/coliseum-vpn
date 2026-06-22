import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ColiseumVpnApp());
}

class ColiseumVpnApp extends StatelessWidget {
  const ColiseumVpnApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coliseum VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        primaryColor: const Color(0xFFFF0055),
      ),
      home: const LoginScreen(),
    );
  }
}

// 1. ЭКРАН ЛОГИНА (MOCK)
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VpnDashboardScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.shield_outlined, size: 80, color: Color(0xFFFF0055)),
            const SizedBox(height: 16),
            const Text(
              'COLISEUM VPN',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white),
            ),
            const Text(
              'Private Node Ecosystem',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Имя пользователя',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0055),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('ВОЙТИ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. ГЛАВНЫЙ ЭКРАН VPN (MOCK)
class VpnDashboardScreen extends StatefulWidget {
  const VpnDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VpnDashboardScreen> createState() => _VpnDashboardScreenState();
}

class _VpnDashboardScreenState extends State<VpnDashboardScreen> {
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _sessionTimer;
  Timer? _speedTimer;
  Duration _duration = Duration.zero;
  
  double _downloadSpeed = 0.0;
  double _uploadSpeed = 0.0;

  void _toggleConnection() {
    if (_isConnected) {
      setState(() {
        _isConnected = false;
        _downloadSpeed = 0.0;
        _uploadSpeed = 0.0;
      });
      _sessionTimer?.cancel();
      _speedTimer?.cancel();
    } else {
      setState(() {
        _isConnecting = true;
      });

      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isConnecting = false;
            _isConnected = true;
            _duration = Duration.zero;
          });
          _startSensors();
        }
      });
    }
  }

  void _startSensors() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = _duration + const Duration(seconds: 1);
      });
    });

    final rand = Random();
    _speedTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _downloadSpeed = 15.0 + rand.nextDouble() * 45.0;
        _uploadSpeed = 5.0 + rand.nextDouble() * 15.0;
      });
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _speedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _isConnected ? const Color(0xFF00FFCC) : (_isConnecting ? Colors.orange : const Color(0xFFFF0055));
    final statusText = _isConnected ? 'ЗАЩИЩЕНО' : (_isConnecting ? 'ПОДКЛЮЧЕНИЕ...' : 'НЕ ЗАЩИЩЕНО');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Сервер: NL-Amsterdam #1', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text('Ping: 32ms', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
              const Spacer(),

              GestureDetector(
                onTap: _isConnecting ? null : _toggleConnection,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF161626),
                    border: Border.all(color: statusColor.withOpacity(0.5), width: 4),
                    boxShadow: [
                      BoxShadow(color: statusColor.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isConnected ? Icons.lock_outline : Icons.power_settings_new,
                          size: 50,
                          color: statusColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isConnected ? 'DISCONNECT' : 'CONNECT',
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: statusColor),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(statusText, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(
                _isConnected ? _formatDuration(_duration) : '00:00:00',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              
              const Spacer(),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF161626), borderRadius: BorderRadius.circular(24)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Row(children: [Icon(Icons.arrow_downward, color: Color(0xFF00FFCC), size: 18), SizedBox(width: 4), Text('Download', style: TextStyle(color: Colors.grey))]),
                        const SizedBox(height: 6),
                        Text('${_downloadSpeed.toStringAsFixed(1)} Mbps', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Colors.white10),
                    Column(
                      children: [
                        const Row(children: [Icon(Icons.arrow_upward, color: Color(0xFFFF0055), size: 18), SizedBox(width: 4), Text('Upload', style: TextStyle(color: Colors.grey))]),
                        const SizedBox(height: 6),
                        Text('${_uploadSpeed.toStringAsFixed(1)} Mbps', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              const Text('Активных подключений к вашей сети: 1 из 15', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
