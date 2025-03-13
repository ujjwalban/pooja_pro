import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:pooja_pro/controllers/simple_media_uploader.dart';
import '../controllers/location_picker.dart';
import '../utils/validators.dart';
import '../controllers/phone_validator.dart';
import "../auth/auth_service.dart";
import '../models/temple.dart';
import '../models/customer.dart';
import 'login_screen.dart';
import 'package:email_validator/email_validator.dart';

class SignupScreen extends StatefulWidget {
  final String userType;
  const SignupScreen({super.key, required this.userType});

  @override
  // ignore: library_private_types_in_public_api
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  late final String userType;
  late final AuthService _authService;
  late AnimationController _animationController;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController templeLocationController =
      TextEditingController();
  final TextEditingController templeDescriptionController =
      TextEditingController();
  final TextEditingController templeImageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Store coordinates from location picker
  double latitude = 0.0;
  double longitude = 0.0;

  // Store media files
  List<String> imageUrls = [];
  List<String> videoUrls = [];

  // Validators
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSignupHovered = false;
  bool _isLoginHovered = false;
  bool _isLoading = false;
  bool _isValidEmail = false;
  bool _isValidPhone = false;
  String _countryCode = '+91';
  String _passwordError = '';
  bool _passwordsMatch = true;

  // Expanded sections
  final bool _isBasicInfoExpanded = true;
  final bool _isDetailsExpanded = false;
  final bool _isAccountExpanded = false;
  final bool _isUploadExpanded = false;

  @override
  void initState() {
    super.initState();
    userType = widget.userType;
    _authService = AuthService(userType: widget.userType);

    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    templeLocationController.dispose();
    templeDescriptionController.dispose();
    templeImageController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool get isTemple => userType == 'Temple';

  void _handleLocationSelected(LocationData locationData) {
    setState(() {
      templeLocationController.text = locationData.address;
      latitude = locationData.latitude;
      longitude = locationData.longitude;
    });
  }

  void _handleMediaUpdated(List<String> images, List<String> videos) {
    setState(() {
      imageUrls = images;
      videoUrls = videos;
    });
  }

  void _validateEmail(String email) {
    setState(() {
      _isValidEmail = EmailValidator.validate(email);
    });
  }

  void _validatePassword(String password) {
    final error = Validators.validatePassword(password);
    setState(() {
      _passwordError = error ?? '';
      if (confirmPasswordController.text.isNotEmpty) {
        _passwordsMatch = password == confirmPasswordController.text;
      }
    });
  }

  void _handlePhoneValidation(
      String countryCode, String phoneNumber, bool isValid) {
    setState(() {
      _countryCode = countryCode;
      _isValidPhone = isValid;
    });
  }

  Future<void> _handleSignup() async {
    // Validate passwords match
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _passwordsMatch = false;
      });
      Validators.showValidationError(context, 'Passwords do not match');
      return;
    }

    // Validate email
    if (!_isValidEmail) {
      Validators.showValidationError(
          context, 'Please enter a valid email address');
      return;
    }

    // For devotees, validate phone
    if (!isTemple && !_isValidPhone) {
      Validators.showValidationError(
          context, 'Please enter a valid phone number');
      return;
    }

    // Basic validation for required fields
    if (isTemple) {
      if (nameController.text.isEmpty ||
          templeLocationController.text.isEmpty ||
          templeDescriptionController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        Validators.showValidationError(
            context, 'Please fill in all required fields');
        return;
      }

      // At least one image is required for temples
      if (imageUrls.isEmpty) {
        Validators.showValidationError(
            context, 'Please upload at least one image of your temple');
        return;
      }
    } else {
      if (nameController.text.isEmpty ||
          phoneController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        Validators.showValidationError(
            context, 'Please fill in all required fields');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (isTemple) {
        await _authService.signUp(
          emailController.text.trim(),
          passwordController.text.trim(),
          "Temple",
          Temple(
            id: '',
            name: nameController.text.trim(),
            location: templeLocationController.text.trim(),
            latitude: latitude,
            longitude: longitude,
            description: templeDescriptionController.text.trim(),
            image: imageUrls.isNotEmpty ? imageUrls[0] : '',
            images: imageUrls,
            videos: videoUrls,
            contact: "",
          ),
          null,
          context,
        );
      } else {
        await _authService.signUp(
          emailController.text.trim(),
          passwordController.text.trim(),
          "Customer",
          null,
          Customer(
            id: '',
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            phoneNumber: '$_countryCode${phoneController.text.trim()}',
            photo: "",
          ),
          context,
        );
      }
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

    // Colors based on user type
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
            left: -100,
            bottom: -100,
            child: _buildBackgroundMandala(size: 280, counterClockwise: true),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: primaryColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Header section with user type icon
                      _buildUserTypeIcon(isTemple, primaryColor),
                      const SizedBox(height: 12),

                      // Title with user type
                      Text(
                        '${isTemple ? 'Temple' : 'Devotee'} Signup',
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
                            ? 'Create your temple profile to reach devotees'
                            : 'Join to connect with temples and access services',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Main form container with intuitive linear flow
                      Container(
                        width: screenSize.width > 600
                            ? 500
                            : screenSize.width * 0.9,
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
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Form title with clean section divider
                              Text(
                                'Create Your Account',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Divider(color: Colors.grey.shade200),
                              const SizedBox(height: 16),

                              // Basic Information section
                              Text(
                                'Basic Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Common fields for both temple and devotee
                              _buildTextField(
                                controller: nameController,
                                hint: isTemple ? 'Temple Name' : 'Full Name',
                                icon: isTemple
                                    ? Icons.temple_hindu
                                    : Icons.person,
                                primaryColor: primaryColor,
                              ),
                              const SizedBox(height: 16),

                              // Email with validation
                              _buildTextField(
                                controller: emailController,
                                hint: 'Email',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                primaryColor: primaryColor,
                                onChanged: _validateEmail,
                                suffixIcon: emailController.text.isNotEmpty
                                    ? Icon(
                                        _isValidEmail
                                            ? Icons.check_circle
                                            : Icons.error,
                                        color: _isValidEmail
                                            ? Colors.green
                                            : Colors.red,
                                      )
                                    : null,
                              ),
                              if (emailController.text.isNotEmpty &&
                                  !_isValidEmail)
                                const Padding(
                                  padding: EdgeInsets.only(left: 16, top: 4),
                                  child: Text(
                                    'Please enter a valid email address',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                ),
                              const SizedBox(height: 16),

                              // Temple or Devotee specific fields
                              if (isTemple) ...[
                                // Temple location
                                const Text(
                                  'Temple Location',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LocationPicker(
                                  onLocationSelected: _handleLocationSelected,
                                ),
                                const SizedBox(height: 20),

                                // Temple description
                                _buildTextField(
                                  controller: templeDescriptionController,
                                  hint: 'Temple Description',
                                  icon: Icons.description,
                                  maxLines: 3,
                                  primaryColor: primaryColor,
                                ),
                                const SizedBox(height: 20),

                                // Upload media with clear heading
                                const Text(
                                  'Upload Photos & Videos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Showcase your temple with beautiful images',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SimpleMediaUploader(
                                  mediaUrls: imageUrls,
                                  onMediaChanged: (updatedUrls) {
                                    setState(() {
                                      imageUrls = updatedUrls;
                                    });
                                  },
                                ),
                              ] else ...[
                                // Phone number validation for devotees
                                const Text(
                                  'Phone Number',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                PhoneNumberValidator(
                                  controller: phoneController,
                                  onChanged: _handlePhoneValidation,
                                ),
                              ],

                              const SizedBox(height: 24),

                              // Security section with password fields
                              Text(
                                'Security',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password fields
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
                                onChanged: _validatePassword,
                              ),
                              if (_passwordError.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 16, top: 4),
                                  child: Text(
                                    _passwordError,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: confirmPasswordController,
                                hint: 'Confirm Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                isPasswordVisible: _isConfirmPasswordVisible,
                                onVisibilityToggle: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                                primaryColor: primaryColor,
                                errorText: !_passwordsMatch &&
                                        confirmPasswordController
                                            .text.isNotEmpty
                                    ? 'Passwords do not match'
                                    : null,
                                onChanged: (value) {
                                  setState(() {
                                    _passwordsMatch =
                                        passwordController.text == value ||
                                            value.isEmpty;
                                  });
                                },
                              ),

                              const SizedBox(height: 32),

                              // Create account button
                              Center(
                                child: _buildSignupButton(
                                    primaryColor, secondaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          MouseRegion(
                            onEnter: (_) =>
                                setState(() => _isLoginHovered = true),
                            onExit: (_) =>
                                setState(() => _isLoginHovered = false),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LoginScreen(userType: userType),
                                  ),
                                );
                              },
                              child: AnimatedDefaultTextStyle(
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: _isLoginHovered
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  decoration: _isLoginHovered
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                                duration: const Duration(milliseconds: 200),
                                child: const Text('Login'),
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
          ),
        ],
      ),
    );
  }

  // Signup button
  Widget _buildSignupButton(Color primaryColor, Color secondaryColor) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isSignupHovered = true),
      onExit: (_) => setState(() => _isSignupHovered = false),
      child: GestureDetector(
        onTap: _isLoading ? null : _handleSignup,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isSignupHovered
                  ? [secondaryColor, primaryColor]
                  : [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(_isSignupHovered ? 0.4 : 0.2),
                blurRadius: _isSignupHovered ? 12 : 8,
                spreadRadius: _isSignupHovered ? 2 : 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          transform: _isSignupHovered
              ? (Matrix4.identity()..translate(0, -2, 0))
              : null,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.app_registration,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
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
                    isTemple
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
                    color: isTemple
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
    int maxLines = 1,
    TextInputType? keyboardType,
    String? errorText,
    Function(String)? onChanged,
    Widget? suffixIcon,
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
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
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
              : suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: maxLines > 1 ? 16 : 12,
            horizontal: 16,
          ),
          errorText: errorText,
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
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
