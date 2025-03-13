import 'package:flutter/material.dart';
import 'package:pooja_pro/screens/login_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _glowController;

  bool _isTempleHovered = false;
  bool _isUserHovered = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isScreenMobile = screenSize.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepOrange.shade50,
                  Colors.orange.shade50,
                ],
              ),
            ),
          ),

          // Single decorative mandala
          Positioned(
            top: -100,
            right: -100,
            child: _build3DMandala(size: 300, complexity: 1.5),
          ),

          // Main content
          Center(
            child: ScaleTransition(
              scale: _scaleController,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isScreenMobile ? screenSize.width * 0.95 : 800,
                  maxHeight: screenSize.height * 0.9,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: isScreenMobile ? 40 : 60),

                      // App Logo with simplified animations
                      _buildAppLogo(),

                      const SizedBox(height: 16),
                      // App Title with glow effect
                      _buildGlowingTitle(),

                      const SizedBox(height: 6),
                      // Short tagline
                      Text(
                        'Connect with temples, discover sacred services',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 40),
                      // Option Cards - Main call to action
                      SizedBox(
                        width: screenSize.width > 600
                            ? 500
                            : screenSize.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildOptionCard(
                                context: context,
                                title: 'Temple',
                                icon: Icons.temple_hindu,
                                isHovered: _isTempleHovered,
                                onHover: (value) {
                                  setState(() {
                                    _isTempleHovered = value;
                                  });
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen(userType: "Temple"),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildOptionCard(
                                context: context,
                                title: 'Devotee',
                                icon: Icons.person,
                                isHovered: _isUserHovered,
                                onHover: (value) {
                                  setState(() {
                                    _isUserHovered = value;
                                  });
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen(userType: "User"),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      // Subtitle
                      Text(
                        'Choose your path to begin',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),

                      // Fixed height SizedBox instead of a potentially problematic dynamic one
                      SizedBox(height: isScreenMobile ? 40 : 60),

                      // Footer
                      Text(
                        '© 2023 PoojaPro',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Simplified 3D rotating mandala
  Widget _build3DMandala({
    double size = 300,
    double complexity = 1.0,
  }) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: Opacity(
            opacity: 0.15,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.deepOrange.shade300,
                    Colors.orange.shade100.withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(size, size),
                  painter: MandalaPainter(
                    color: Colors.deepOrange.shade700,
                    strokeWidth: 1.5,
                    complexity: complexity,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Simplified app logo
  Widget _buildAppLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange
                .withOpacity(0.2 + _glowController.value * 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(_rotationController.value * math.pi / 4),
              child: Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Simplified title with subtle glow
  Widget _buildGlowingTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Colors.deepOrange.shade700,
          Colors.orange.shade600,
          Colors.deepOrange.shade700,
        ],
        stops: [
          0.0,
          _glowController.value,
          1.0,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: const Text(
        'PoojaPro',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // Simplified option cards
  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isHovered,
    required Function(bool) onHover,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 160,
          decoration: BoxDecoration(
            color: isHovered ? Colors.white : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? Colors.deepOrange.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isHovered ? 15 : 8,
                spreadRadius: isHovered ? 2 : 1,
                offset: isHovered ? const Offset(0, 6) : const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color:
                  isHovered ? Colors.deepOrange.shade300 : Colors.grey.shade200,
              width: isHovered ? 2 : 1,
            ),
          ),
          transform: isHovered
              ? (Matrix4.identity()..translate(0, -5, 0))
              : Matrix4.identity(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isHovered
                        ? [Colors.deepOrange, Colors.orange.shade600]
                        : [Colors.orange.shade400, Colors.orange.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isHovered ? Colors.deepOrange.shade700 : Colors.grey[800],
                ),
              ),

              const SizedBox(height: 12),
              // Login button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isHovered
                        ? [Colors.deepOrange, Colors.orange.shade600]
                        : [Colors.orange.shade400, Colors.orange.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isHovered ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simplified mandala painter
class MandalaPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double complexity;

  MandalaPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.complexity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw concentric circles
    final circleCount = (5 * complexity).round();
    for (int i = 1; i <= circleCount; i++) {
      canvas.drawCircle(center, radius * i / circleCount, paint);
    }

    // Draw radial lines
    final lineCount = (8 * complexity).round();
    for (int i = 0; i < lineCount; i++) {
      final angle = 2 * math.pi * i / lineCount;
      final dx = math.cos(angle);
      final dy = math.sin(angle);

      canvas.drawLine(
        center,
        Offset(center.dx + radius * dx, center.dy + radius * dy),
        paint,
      );
    }

    // Draw lotus pattern - simplified
    final petalCount = (6 * complexity).round();
    for (int i = 0; i < petalCount; i++) {
      final angle = 2 * math.pi * i / petalCount;
      final startAngle = angle - 0.3;
      final endAngle = angle + 0.3;

      final innerRadius = radius * 0.4;
      final outerRadius = radius * 0.7;

      final path = Path();
      path.moveTo(
        center.dx + innerRadius * math.cos(startAngle),
        center.dy + innerRadius * math.sin(startAngle),
      );

      path.cubicTo(
        center.dx + innerRadius * 1.2 * math.cos(angle - 0.15),
        center.dy + innerRadius * 1.2 * math.sin(angle - 0.15),
        center.dx + outerRadius * 0.8 * math.cos(angle + 0.15),
        center.dy + outerRadius * 0.8 * math.sin(angle + 0.15),
        center.dx + outerRadius * math.cos(endAngle),
        center.dy + outerRadius * math.sin(endAngle),
      );

      path.cubicTo(
        center.dx + outerRadius * 1.1 * math.cos(angle),
        center.dy + outerRadius * 1.1 * math.sin(angle),
        center.dx + innerRadius * 1.3 * math.cos(angle),
        center.dy + innerRadius * 1.3 * math.sin(angle),
        center.dx + innerRadius * math.cos(startAngle),
        center.dy + innerRadius * math.sin(startAngle),
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(MandalaPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.complexity != complexity;
  }
}
