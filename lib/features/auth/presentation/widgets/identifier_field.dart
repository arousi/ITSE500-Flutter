import 'package:flutter/material.dart';

class IdentifierField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  const IdentifierField(
      {super.key, required this.controller, required this.focusNode});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: const InputDecoration(
        labelText: 'Username or Email',
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username or email';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
    );
  }
}
