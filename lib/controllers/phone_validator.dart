import 'package:flutter/material.dart';

// Define a simple CountryCode class to replace the imported one
class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String? flagUri;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    this.flagUri,
  });
}

// A simple country code picker implementation
class CountryCodePicker extends StatefulWidget {
  const CountryCodePicker({Key? key}) : super(key: key);

  @override
  State<CountryCodePicker> createState() => _CountryCodePickerState();
}

class _CountryCodePickerState extends State<CountryCodePicker> {
  // List of common country codes
  static final List<CountryCode> _countryCodes = [
    const CountryCode(name: 'India', code: 'IN', dialCode: '+91'),
    const CountryCode(name: 'United States', code: 'US', dialCode: '+1'),
    const CountryCode(name: 'United Kingdom', code: 'GB', dialCode: '+44'),
    const CountryCode(name: 'Australia', code: 'AU', dialCode: '+61'),
    const CountryCode(name: 'Canada', code: 'CA', dialCode: '+1'),
    const CountryCode(name: 'China', code: 'CN', dialCode: '+86'),
    const CountryCode(name: 'Germany', code: 'DE', dialCode: '+49'),
    const CountryCode(name: 'Japan', code: 'JP', dialCode: '+81'),
    const CountryCode(name: 'Singapore', code: 'SG', dialCode: '+65'),
    const CountryCode(name: 'South Africa', code: 'ZA', dialCode: '+27'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _countryCodes.length,
      itemBuilder: (context, index) {
        final country = _countryCodes[index];
        return ListTile(
          title: Text(country.name),
          subtitle: Text(country.dialCode),
          leading: Text(
            // Simple flag emoji representation (not perfect but avoids dependencies)
            _getFlagEmoji(country.code),
            style: const TextStyle(fontSize: 24),
          ),
          onTap: () => Navigator.pop(context, country),
        );
      },
    );
  }

  // Generate flag emoji from country code
  String _getFlagEmoji(String countryCode) {
    // Convert country code to flag emoji
    // Each letter is converted to its regional indicator symbol
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}

class PhoneNumberValidator extends StatefulWidget {
  final TextEditingController controller;
  final Function(String countryCode, String phoneNumber, bool isValid)
      onChanged;
  final String initialCountryCode;

  const PhoneNumberValidator({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.initialCountryCode = 'IN',
  }) : super(key: key);

  @override
  State<PhoneNumberValidator> createState() => _PhoneNumberValidatorState();
}

class _PhoneNumberValidatorState extends State<PhoneNumberValidator> {
  late CountryCode _selectedCountry;
  final CountryCodePicker _countryCodePicker = const CountryCodePicker();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = CountryCode(
      name: 'India',
      code: widget.initialCountryCode,
      dialCode: '+91',
    );
    _validatePhoneNumber(widget.controller.text);
  }

  // Basic phone number validation
  void _validatePhoneNumber(String value) {
    // Simple length-based validation - this can be improved with a proper library
    final phoneRegex = RegExp(r'^\d{7,15}$');
    final isValid = phoneRegex.hasMatch(value);

    setState(() {
      _isValid = isValid;
    });

    widget.onChanged(_selectedCountry.dialCode, value, isValid);
  }

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          // Country code selector
          InkWell(
            onTap: () async {
              final selectedCountry = await showDialog<CountryCode>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Country'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: _countryCodePicker,
                  ),
                ),
              );

              if (selectedCountry != null) {
                setState(() {
                  _selectedCountry = selectedCountry;
                });
                _validatePhoneNumber(widget.controller.text);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  Text(
                    _selectedCountry.dialCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),

          // Divider
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),

          // Phone number input
          Expanded(
            child: TextField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              onChanged: _validatePhoneNumber,
              decoration: InputDecoration(
                hintText: 'Phone number',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: _isValid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : widget.controller.text.isEmpty
                        ? null
                        : const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
