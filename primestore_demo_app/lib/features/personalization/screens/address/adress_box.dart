import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:iconsax/iconsax.dart';

class TAdressbox extends StatelessWidget {
  const TAdressbox({
    super.key,
    
    required this.name,
    required this.adress,
    required this.state,
    required this.phoneNumber, required this.id,
  });

  
  final String name;
  final String adress;
  final String state;
  final String phoneNumber;
  final String id;
  @override
  Widget build(BuildContext context) {
    final controller =  Get.find<SeclectedaddressController>() ;
    final dark = THelperFunctions.isDarkMode(context);
    return Obx(() {
      
    final selected = controller.selectedId.value == id;

      return GestureDetector(
        onTap: () => controller.selectAddress(id),
        child: Container(
          width: double.infinity,
         decoration: BoxDecoration(
          color: selected? Color.fromARGB(255, 138, 188, 99): dark?TColors.darkerGrey:  Color(0xFFF6F6F1),
          borderRadius: BorderRadius.circular(12),
          border:  Border.all(color:selected ? TColors.black : dark? TColors.darkGrey: TColors.black)
         ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall!.apply(color:selected ? dark? TColors.black: TColors.white : dark? TColors.white: TColors.black, fontSizeDelta: 2),
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: TSizes.xs,),
                 SizedBox(
                  width: 400,
                   child: Text(
                      adress,
                      style: Theme.of(context).textTheme.headlineSmall!.apply(color:selected ? dark? TColors.black: TColors.white : dark? TColors.white: TColors.black, fontSizeDelta: -2),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                 ),
                 SizedBox(height: TSizes.sm,),
                 SizedBox(
                  width: 400,
                   child: Text(
                      state,
                      style: Theme.of(context).textTheme.headlineSmall!.apply(color:selected ? dark? TColors.black: TColors.white : dark? TColors.white: TColors.black, fontSizeDelta: -3),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                 ),
                 SizedBox(
                  width: 400,
                   child: Text(
                      phoneNumber,
                      style: Theme.of(context).textTheme.headlineSmall!.apply( color:selected ? dark? TColors.black: TColors.white : dark? TColors.white: TColors.black, fontSizeDelta: -3),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                 ),
                 if (selected)
                
                 Column(
                   children: [
                    const SizedBox(height: TSizes.sm,),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         Icon(Iconsax.tick_circle, color:dark? TColors.black: TColors.light,),
                         
                       ],
                     ),
                   ],
                 )
                  else
                const SizedBox.shrink(),
                
                
              ],
            ),
          ),
            ),
      );
              });
  }
}
class SeclectedaddressController extends GetxController {
  final RxString selectedId = ''.obs;

  void selectAddress(String id) {
    selectedId.value = id;
  }
}
