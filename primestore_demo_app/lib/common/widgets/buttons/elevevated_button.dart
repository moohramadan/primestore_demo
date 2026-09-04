
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TRoundedElevatedButton extends StatelessWidget {
  const TRoundedElevatedButton( {
    super.key, required this.color,
     required this.onpressed, 
     required this.text,
      this.icon = Icons.login_rounded,
      this.ShowIcon = false,
  });
   final Color color;
   final VoidCallback onpressed;
   final String text;
   final bool ShowIcon;
   final IconData icon;
   
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onpressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          
        ),
        child:ShowIcon?  
          SizedBox(
            
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(icon, size: TSizes.lg,),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(text, style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.white, fontWeightDelta: 28),),
            ),
                    ],),
          ):Text(text),
      ),
    );
  }
}