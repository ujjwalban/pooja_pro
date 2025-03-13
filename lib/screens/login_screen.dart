import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'signup_screen.dart';
import "../auth/auth_service.dart";

class LoginScreen extends StatefulWidget {
  final String userType;
  const LoginScreen({super.key, required this.userType});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final String userType;
  late final AuthService _authService;
  late AnimationController _animationController;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoginHovered = false;
  bool _isSignupHovered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userType = widget.userType;
    _authService = AuthService(userType: widget.userType);

    _animationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email and password')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signIn(emailController.text.trim(),
          passwordController.text.trim(), userType, context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTemple = userType == "Temple";

    // Background colors based on user type
    final Color primaryColor =
        isTemple ? Colors.deepOrange.shade700 : Colors.orange.shade700;
    final Color secondaryColor =
        isTemple ? Colors.deepOrange.shade600 : Colors.orange.shade600;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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

          // Decorative background mandala
          Positioned(
            right: -100,
            top: -100,
            child: _buildBackgroundMandala(size: 300),
          ),

          // Decorative background mandala 2
          Positioned(
            left: -80,
            bottom: -80,
            child: _buildBackgroundMandala(size: 250, counterClockwise: true),
          ),

          // Main content
          SafeArea(
            child: Stack(
              children: [
                // Back button positioned at the top left
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: primaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Main content with scroll
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              height:
                                  40), // Add space at the top for the back button

                          // User type icon with 3D effect
                          _buildUserTypeIcon(isTemple, primaryColor),

                          const SizedBox(height: 8),

                          // Title with user type
                          Text(
                            '${isTemple ? 'Temple' : 'Devotee'} Login',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            isTemple
                                ? 'Access your temple dashboard to manage services'
                                : 'Connect with temples and access sacred services',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Login form with 3D card effect
                          Container(
                            width: screenSize.width > 600
                                ? 400
                                : screenSize.width * 0.9,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 5,
                                  spreadRadius: 0,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Email field
                                _buildTextField(
                                  controller: emailController,
                                  hint: 'Email',
                                  icon: Icons.email,
                                  primaryColor: primaryColor,
                                ),

                                const SizedBox(height: 18),

                                // Password field with visibility toggle
                                _buildTextField(
                                  controller: passwordController,
                                  hint: 'Password',
                                  icon: Icons.lock,
                                  isPassword: true,
                                  isPasswordVisible: _isPasswordVisible,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  primaryColor: primaryColor,
                                ),

                                const SizedBox(height: 6),

                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // TODO: Implement forgot password
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: primaryColor,
                                    ),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Login button
                                MouseRegion(
                                  onEnter: (_) =>
                                      setState(() => _isLoginHovered = true),
                                  onExit: (_) =>
                                      setState(() => _isLoginHovered = false),
                                  child: GestureDetector(
                                    onTap: _isLoading ? null : _handleLogin,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      height: 50,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _isLoginHovered
                                              ? [secondaryColor, primaryColor]
                                              : [primaryColor, secondaryColor],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: _isLoginHovered
                                            ? [
                                                BoxShadow(
                                                  color: primaryColor
                                                      .withOpacity(0.4),
                                                  spreadRadius: 1,
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 5),
                                                )
                                              ]
                                            : [
                                                BoxShadow(
                                                  color: primaryColor
                                                      .withOpacity(0.2),
                                                  spreadRadius: 1,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                )
                                              ],
                                      ),
                                      transform: _isLoginHovered
                                          ? (Matrix4.identity()
                                            ..translate(0, -2, 0))
                                          : null,
                                      child: Center(
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 3,
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isTemple
                                                        ? Icons.temple_hindu
                                                        : Icons.person,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'Login',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sign up option
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              MouseRegion(
                                onEnter: (_) =>
                                    setState(() => _isSignupHovered = true),
                                onExit: (_) =>
                                    setState(() => _isSignupHovered = false),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SignupScreen(userType: userType),
                                      ),
                                    );
                                  },
                                  child: AnimatedDefaultTextStyle(
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: _isSignupHovered
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      decoration: _isSignupHovered
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                    ),
                                    duration: const Duration(milliseconds: 200),
                                    child: const Text('Sign up'),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3D rotating mandala for background
  Widget _buildBackgroundMandala(
      {required double size, bool counterClockwise = false}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animationController.value *
              2 *
              math.pi *
              (counterClockwise ? -1 : 1),
          child: Opacity(
            opacity: 0.1,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    userType == "Temple"
                        ? Colors.deepOrange.shade300
                        : Colors.orange.shade300,
                    Colors.orange.shade100.withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(size, size),
                  painter: MandalaPainter(
                    color: userType == "Temple"
                        ? Colors.deepOrange.shade700
                        : Colors.orange.shade700,
                    strokeWidth: 1.2,
                    complexity: 1.2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 3D User Type Icon with animation
  Widget _buildUserTypeIcon(bool isTemple, Color primaryColor) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(
                math.sin(_animationController.value * 2 * math.pi) * 0.05),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isTemple ? Icons.temple_hindu : Icons.person,
                color: primaryColor,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  // Custom text field with 3D effects
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    Function()? onVisibilityToggle,
    required Color primaryColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        style: TextStyle(color: Colors.grey[800]),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: primaryColor),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: primaryColor,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// Mandala pattern painter for background decorations
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

    // Draw lotus pattern
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
