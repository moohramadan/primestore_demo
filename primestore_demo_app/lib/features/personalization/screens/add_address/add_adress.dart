import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';

/// Stateless UI for the "Add new address" screen, styled with the
/// rounded green-accent look from the mailing-address mockup.
class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  static const Color accentColor = TColors.brand;
  static const Color accentTextColor = Color(0xFF1F3A0A);

  static const InputBorder _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(24)),
    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
  );

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: _fieldBorder,
      enabledBorder: _fieldBorder,
      focusedBorder: _fieldBorder,
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _fieldGroup({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_label(label), child],
      ),
    );
  }

  Widget _dropdown(String hint, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: _decoration(hint),
      icon: const Icon(Icons.keyboard_arrow_down),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: null,
      hint: Text(hint, style: const TextStyle(color: Color(0xFF9E9E9E))),
    );
  }

  Widget _textField(String hint, {TextInputType? keyboardType}) {
    return TextField(
      keyboardType: keyboardType,
      decoration: _decoration(hint),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F1),
      appBar: AppBar(
        
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add new address',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Fill in your address to receive gifts from us.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 20),

                _fieldGroup(
                  label: 'Region',
                  child: _dropdown('Select region', const [
                    'Calabarzon',
                    'Metro Manila',
                  ]),
                ),
                _fieldGroup(
                  label: 'City',
                  child: _dropdown('Select city', const [
                    'General Trias City',
                    'Quezon City',
                  ]),
                ),
                _fieldGroup(
                  label: 'First name',
                  child: _textField('Muhammad'),
                ),
                _fieldGroup(
                  label: 'Last name',
                  child: _textField('Ramadan'),
                ),
                _fieldGroup(
                  label: 'Phone number',
                  child: _textField('8037566796'),
                ),
                _fieldGroup(
                  label: 'Additional phone number',
                  child: _textField('Optional'),
                ),
                _fieldGroup(
                  label: 'Address',
                  child: _textField('Mango St, Skyline Tower'),
                ),
                _fieldGroup(
                  label: 'Additional information',
                  child: _textField('Block, unit, floor'),
                ),

                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: false,
                        onChanged: null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Set as default address',
                        style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 24),

                TRoundedElevatedButton(
  color: Color(0xFF1F3A0A), // or whatever your "destructive action" color is
  text: 'Log out',
  ShowIcon: true,
  icon: Icons.logout, 
  onpressed:  () {},

),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
