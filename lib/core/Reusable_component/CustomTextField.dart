import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../resources/ColorManger.dart';

class CustomTextField extends StatefulWidget {
  TextEditingController controller;
  String? Function(String?) validate;
  String hint;
  String prefixIcon;
  TextInputType keyboardType;
  bool obscure;
  int lines;

  CustomTextField({
    required this.validate,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    required this.keyboardType,
    this.obscure = false,
    this.lines=1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool isVisible;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isVisible = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines:widget.lines,
      validator: widget.validate,
      controller: widget.controller,
      obscureText: isVisible,

      obscuringCharacter: '*',
      style: Theme.of(context).textTheme.titleMedium,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(

        hintText: widget.hint,
        hintStyle: Theme.of(context).textTheme.labelMedium,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ColorManger.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ColorManger.green),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ColorManger.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ColorManger.red),
        ),
        prefixIcon:widget.prefixIcon.isNotEmpty? SvgPicture.asset(
          widget.prefixIcon,
          fit: BoxFit.scaleDown,
          colorFilter: ColorFilter.mode(
            ColorManger.green,
            BlendMode.srcIn,
          ),
        ):null,
        suffixIcon:
        widget.obscure
            ? IconButton(
          onPressed: () {
            setState(() {
              isVisible = !isVisible;
            });
          },
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
          ),
        )
            : null,
      ),
    );
  }
}
