import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;
  final String _counterKey = 'counter_value';

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  // Load counter from SharedPreferences (persists on restart)
  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt(_counterKey) ?? 0;
    });
  }

  // Save counter to SharedPreferences
  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, _counter);
  }

  void _increment() {
    setState(() => _counter++);
    _saveCounter();
  }

  void _decrement() {
    setState(() => _counter--);
    _saveCounter();
  }

  void _reset() {
    setState(() => _counter = 0);
    _saveCounter();
  }

  Color get _counterColor {
    if (_counter > 0) return const Color(0xFF6C63FF);
    if (_counter < 0) return Colors.red.shade400;
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Counter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Counter display card
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _counterColor.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_counter',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: _counterColor,
                    ),
                  ),
                  Text(
                    'Count',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Persistence note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_outlined, size: 14, color: Color(0xFF6C63FF)),
                  SizedBox(width: 6),
                  Text(
                    'Value saved automatically',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement
                _CounterButton(
                  icon: Icons.remove,
                  label: 'Decrease',
                  onPressed: _decrement,
                  color: Colors.red.shade400,
                ),
                const SizedBox(width: 20),
                // Reset
                _CounterButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  onPressed: _reset,
                  color: Colors.grey.shade600,
                  isSmall: true,
                ),
                const SizedBox(width: 20),
                // Increment
                _CounterButton(
                  icon: Icons.add,
                  label: 'Increase',
                  onPressed: _increment,
                  color: const Color(0xFF6C63FF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isSmall;

  const _CounterButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isSmall ? 52.0 : 68.0;
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: isSmall ? 22 : 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
