import 'package:cartiva/features/auth/sign_in_screen.dart';
import 'package:cartiva/features/home_main/home_main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const darkColor = Color(0xFF1A1A1A);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final hasSession = Supabase.instance.client.auth.currentSession != null;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              hasSession ? const HomeMain() : const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkColor,
      body: Stack(
        children: [
          Image.asset('assets/Element.png'),

          Center(
            child: Image.asset('assets/Vector.png', width: 134, height: 134),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _getStarted(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const SignIn()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: WaveBackground(color: Color(0xFFE8E8E8)),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FractionallySizedBox(
                      widthFactor: .78,
                      child: Image.asset(
                        'assets/Image.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person_outline,
                          size: 220,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Text(
                      'Define yourself in your unique way.',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        height: .95,
                        color: darkColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _getStarted(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Get Started'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartivaLogo extends StatelessWidget {
  final Color color;

  const CartivaLogo({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      'CARTIVA',
      style: TextStyle(
        color: color,
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
    );
  }
}

class WaveBackground extends StatelessWidget {
  final Color color;

  const WaveBackground({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _WavePainter(color));
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  const _WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var index = 0; index < 5; index++) {
      final path = Path()
        ..moveTo(-size.width * .15, size.height * (.28 + index * .11))
        ..cubicTo(
          size.width * .28,
          size.height * (.05 + index * .11),
          size.width * .64,
          size.height * (.12 + index * .11),
          size.width * 1.1,
          size.height * (.48 + index * .1),
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => oldDelegate.color != color;
}
