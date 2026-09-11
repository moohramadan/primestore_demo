import 'package:demo_project/features/autentication/controllers/session__controller.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:demo_project/features/autentication/screens/login/login%20screen.dart';
import 'package:demo_project/features/shop/controllers/wishlist_controller.dart';
import 'package:demo_project/features/shop/screens/navigation%20menu.dart';



import 'package:demo_project/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  Get.put(UserController(), permanent: true);
  Get.put(WishlistController(), permanent: true);

  runApp(MyApp());
}

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController = Get.put(SessionController());

    return FutureBuilder<bool>(
      future: sessionController.autoLoginFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final loggedIn = snapshot.data ?? false;
        return loggedIn ? NavigationMenu() : LoginScreen();
      },
    );
  }
}


 class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: const AppEntryPoint(),
    );
  }
}
