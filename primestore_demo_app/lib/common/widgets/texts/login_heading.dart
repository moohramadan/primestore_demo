import 'package:flutter/material.dart';

class TLoginHeading extends StatelessWidget {
  const TLoginHeading({
    super.key, this.textColor, this.showActionButton = true, required this.title, this.buttonTitle = 'View ALL', this.onPressed,
  });
  final Color? textColor;
  final bool showActionButton;
  final String  title, buttonTitle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium!.apply(color:textColor), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,),
        if(showActionButton)  TextButton(onPressed: onPressed, child: Text(buttonTitle)),
      ],
    );
  }
}
