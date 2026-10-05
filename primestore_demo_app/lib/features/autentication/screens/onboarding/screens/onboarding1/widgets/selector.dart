import 'package:get/get.dart';

class InterestController extends GetxController{
  final Interests =const [
    'Sports',
    'Fashion',
    'Tech',
    'Food',
    'Fitness',
    'Health'
  ];
  final selectInterests = <String>{}.obs;
   bool isSelected(String Interest) => selectInterests.contains(Interest);

  void toggleInterest(String Interest){
    if(selectInterests.contains(Interest)){
      selectInterests.remove(Interest);
    }else{
      selectInterests.add(Interest);
    }
  }
}