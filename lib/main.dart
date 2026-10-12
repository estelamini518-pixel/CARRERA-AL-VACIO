import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const CarreraAlVacioApp());
}

class CarreraAlVacioApp extends StatelessWidget {
  const CarreraAlVacioApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Carrera al Vacío',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF050817),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF52E5FF),
            brightness: Brightness.dark,
          ),
        ),
        home: const GameScreen(),
      );
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final math.Random random = math.Random();
  Timer? timer;
  double shipX = 0.5, shadow = 0.04, starX = 0.72, starY = 0.3, holeX = 0.82, holeY = 0.68;
  int score = 0, level = 1, lives = 3;
  bool running = false, gameOver = false, won = false;
  String message = 'Recoge energía, evita la sombra y usa el agujero negro para avanzar.';

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void placeObjects() {
    starX = 0.12 + random.nextDouble() * 0.76;
    starY = 0.18 + random.nextDouble() * 0.60;
    holeX = 0.12 + random.nextDouble() * 0.76;
    holeY = 0.20 + random.nextDouble() * 0.58;
  }

  void startGame() {
    setState(() {
      running = true; gameOver = false; won = false;
      score = 0; level = 1; lives = 3; shipX = 0.5; shadow = 0.04;
      message = ''; placeObjects();
    });
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 80), (_) => tick());
  }

  void tick() {
    if (!mounted || !running) return;
    setState(() {
      shadow += 0.0018 + level * 0.00035;
      final starDistance = math.sqrt(math.pow(shipX - starX, 2) + math.pow(0.52 - starY, 2));
      if (starDistance < 0.075) {
        score += 10 * level;
        placeObjects();
        message = '+${10 * level} puntos: energía recogida';
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && running) setState(() => message = '');
        });
      }
      final holeDistance = math.sqrt(math.pow(shipX - holeX, 2) + math.pow(0.52 - holeY, 2));
      if (holeDistance < 0.095 && shadow > 0.48) {
        score += 100 * level;
        if (level >= 5) {
          won = true; running = false; timer?.cancel();
          message = '¡Victoria! Has cruzado el vacío.';
        } else {
          level++; shadow = 0.04; shipX = 0.5; placeObjects();
          message = '¡Salto de agujero negro! Ahora estás en el nivel $level.';
        }
      } else if (shadow >= 0.78) {
        lives--;
        if (lives <= 0) {
          running = false; gameOver = true; timer?.cancel();
          message = 'La sombra te alcanzó. Puntuación: $score';
        } else {
          shadow = 0.08; shipX = 0.5;
          message = '¡La sombra te rozó! Te quedan $lives vidas.';
        }
      }
    });
  }

  void moveShip(double amount) {
    if (running) setState(() => shipX = (shipX + amount).clamp(0.06, 0.94).toDouble());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Stack(children: [
            Positioned.fill(
              child: CustomPaint(
                painter: SpacePainter(
                  shipX: shipX, shadow: shadow, starX: starX, starY: starY,
                  holeX: holeX, holeY: holeY, level: level, running: running,
                ),
              ),
            ),
            Positioned(
              left: 14, right: 14, top: 10,
              child: Row(children: [
                const Icon(Icons.rocket_launch, color: Color(0xFF65E7FF)),
                const SizedBox(width: 8),
                const Text('CARRERA AL VACÍO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                const Spacer(),
                pill('NIVEL $level', const Color(0xFF7C72FF)),
                const SizedBox(width: 8),
                pill('PUNTOS $score', const Color(0xFF36D7B7)),
                const SizedBox(width: 8),
                pill('VIDAS $lives', const Color(0xFFFF647C)),
              ]),
            ),
            if (message.isNotEmpty)
              Positioned(
                left: 100, right: 100, top: 55,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xDD111936),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF58E6FF)),
                    ),
                    child: Text(message, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            if (!running)
              Center(
                child: Container(
                  width: 310, padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xF20B1028),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF5BE8FF), width: 1.5),
                    boxShadow: const [BoxShadow(color: Color(0x5537CFFF), blurRadius: 28)],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(gameOver ? Icons.warning_amber_rounded : won ? Icons.emoji_events : Icons.rocket_launch,
                        size: 42, color: const Color(0xFF61E8FF)),
                    const SizedBox(height: 8),
                    Text(gameOver ? 'FIN DE LA CARRERA' : won ? '¡MISIÓN COMPLETADA!' : 'CARRERA AL VACÍO',
                        textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(gameOver ? 'Puntos: $score' : won ? 'Puntuación final: $score' :
                      'Sobrevive a la sombra. Recoge estrellas y activa un agujero negro cuando esté cerca para avanzar hasta el nivel 5.',
                      textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 14),
                    FilledButton.icon(onPressed: startGame, icon: const Icon(Icons.play_arrow),
                        label: Text(gameOver || won ? 'JUGAR OTRA VEZ' : 'INICIAR JUEGO')),
                  ]),
                ),
              ),
            if (running)
              Positioned(
                left: 18, right: 18, bottom: 12,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  control(Icons.arrow_left_rounded, () => moveShip(-0.075)),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('La sombra se acerca: ${(shadow * 100).round()}%', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 4),
                    SizedBox(width: 150, child: LinearProgressIndicator(
                      value: shadow.clamp(0, 1), minHeight: 7,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: Colors.white12,
                      color: shadow > 0.55 ? Colors.redAccent : const Color(0xFF55DFF9),
                    )),
                  ]),
                  control(Icons.arrow_right_rounded, () => moveShip(0.075)),
                ]),
              ),
          ]),
        ),
      );

  Widget pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.8)),
        ),
        child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
      );

  Widget control(IconData icon, VoidCallback action) => SizedBox(
        width: 62, height: 48,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xCC162449), foregroundColor: const Color(0xFF6DEAFF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFF4DDDF5))),
          ),
          onPressed: action, child: Icon(icon, size: 34),
        ),
      );
}

class SpacePainter extends CustomPainter {
  final double shipX, shadow, starX, starY, holeX, holeY;
  final int level;
  final bool running;
  SpacePainter({required this.shipX, required this.shadow, required this.starX, required this.starY,
    required this.holeX, required this.holeY, required this.level, required this.running});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF101A43), Color(0xFF050713), Color(0xFF180B2E)],
    ).createShader(rect));

    final rng = math.Random(42 + level * 10);
    for (int i = 0; i < 95; i++) {
      final x = rng.nextDouble() * size.width, y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5 + rng.nextDouble() * 1.6,
          Paint()..color = Colors.white.withValues(alpha: 0.25 + rng.nextDouble() * 0.65));
    }
    canvas.drawCircle(Offset(size.width * 0.13, size.height * 0.30), size.height * 0.10,
        Paint()..color = const Color(0xFF463E8C).withValues(alpha: 0.55));
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.24), size.height * 0.06,
        Paint()..color = const Color(0xFF1C9BAF).withValues(alpha: 0.45));

    final sc = Offset(size.width * (0.5 + (shipX - 0.5) * 0.35), size.height * (0.96 - shadow * 0.52));
    canvas.drawCircle(sc, size.height * 0.30, Paint()..shader = RadialGradient(colors: [
      const Color(0xFF6D245E).withValues(alpha: 0.85),
      const Color(0xFF210D35).withValues(alpha: 0.45), Colors.transparent,
    ]).createShader(Rect.fromCircle(center: sc, radius: size.height * 0.30)));
    final tendril = Paint()..color = const Color(0xFFB62F85).withValues(alpha: 0.45)..strokeWidth = 3..strokeCap = StrokeCap.round;
    for (int i = 0; i < 7; i++) {
      final start = Offset(sc.dx + (i - 3) * 13, sc.dy - 12);
      canvas.drawLine(start, Offset(start.dx + (i - 3) * 6, start.dy - 25 - (i % 3) * 8), tendril);
    }

    final star = Offset(size.width * starX, size.height * starY);
    canvas.drawCircle(star, 15, Paint()..color = const Color(0xFFFFD66B).withValues(alpha: 0.18));
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? 11.0 : 4.5, a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(star.dx + math.cos(a) * r, star.dy + math.sin(a) * r);
      if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFD45D));

    final hole = Offset(size.width * holeX, size.height * holeY);
    canvas.save();
    canvas.translate(hole.dx, hole.dy);
    canvas.rotate(-0.22);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 72, height: 34),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 7
          ..shader = const LinearGradient(colors: [Color(0xFF55E9FF), Color(0xFF9D63FF), Color(0xFFFF6BCB)])
              .createShader(Rect.fromCenter(center: Offset.zero, width: 72, height: 34)));
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 46, height: 20), Paint()..color = const Color(0xFF03040C));
    canvas.drawCircle(Offset.zero, 13, Paint()..color = Colors.black);
    canvas.restore();

    final ship = Offset(size.width * shipX, size.height * 0.52);
    final body = Path()..moveTo(ship.dx, ship.dy - 35)
      ..quadraticBezierTo(ship.dx + 13, ship.dy - 8, ship.dx + 12, ship.dy + 18)
      ..lineTo(ship.dx, ship.dy + 28)..lineTo(ship.dx - 12, ship.dy + 18)
      ..quadraticBezierTo(ship.dx - 13, ship.dy - 8, ship.dx, ship.dy - 35)..close();
    canvas.drawPath(body, Paint()..shader = const LinearGradient(
      colors: [Colors.white, Color(0xFF8FA9C7), Color(0xFF425A7D)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ).createShader(Rect.fromCenter(center: ship, width: 32, height: 70)));
    final wings = Path()..moveTo(ship.dx - 8, ship.dy + 1)..lineTo(ship.dx - 28, ship.dy + 23)
      ..lineTo(ship.dx - 12, ship.dy + 19)..lineTo(ship.dx, ship.dy + 26)
      ..lineTo(ship.dx + 12, ship.dy + 19)..lineTo(ship.dx + 28, ship.dy + 23)
      ..lineTo(ship.dx + 8, ship.dy + 1)..close();
    canvas.drawPath(wings, Paint()..color = const Color(0xFF3A668F));
    canvas.drawPath(wings, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = const Color(0xFF8BEAFF));
    canvas.drawOval(Rect.fromCenter(center: Offset(ship.dx, ship.dy - 12), width: 10, height: 19), Paint()..color = const Color(0xFF55E8FF));
    canvas.drawOval(Rect.fromCenter(center: Offset(ship.dx, ship.dy - 12), width: 5, height: 12), Paint()..color = const Color(0xFFD8FCFF));
    final flame = Path()..moveTo(ship.dx - 5, ship.dy + 25)
      ..lineTo(ship.dx, ship.dy + 43 + (running ? 5 : 0))..lineTo(ship.dx + 5, ship.dy + 25)..close();
    canvas.drawPath(flame, Paint()..color = const Color(0xFFFFA64D));
    canvas.drawPath(Path()..moveTo(ship.dx - 2, ship.dy + 26)..lineTo(ship.dx, ship.dy + 38)
      ..lineTo(ship.dx + 2, ship.dy + 26)..close(), Paint()..color = const Color(0xFFB9F9FF));
  }

  @override
  bool shouldRepaint(covariant SpacePainter oldDelegate) => true;
}
