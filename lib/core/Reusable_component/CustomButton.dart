import 'package:flutter/material.dart';
import 'package:pharmago/core/resources/ColorManger.dart';

class CustomButton extends StatelessWidget {
  String title;
  void Function() onClick;

  CustomButton({required this.title, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onClick,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 13),
        backgroundColor: ColorManger.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: ColorManger.white),
      ),
    );
  }
}
